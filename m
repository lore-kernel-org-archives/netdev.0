From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v4 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO
 core
Date: Thu, 22 Oct 2015 14:29:39 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8ACBF7@hasmsx107.ger.corp.intel.com>
References: <1445519232-11111-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"ido@wizery.com" <ido@wizery.com>
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46412 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757887AbbJVO3o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:29:44 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/22/2015 04:08 PM, Grumbach, Emmanuel wrote:
> When the op_mode sends an skb whose payload is bigger than
> MSS, PCIe will create an A-MSDU out of it. PCIe assumes
> that the skb that is coming from the op_mode can fit in one
> A-MSDU. It is the op_mode's responsibility to make sure
> that this guarantee holds.
> 
> Additional headers need to be built for the subframes.
> The TSO core code takes care of the IP / TCP headers and
> the driver takes care of the 802.11 subframe headers.
> 
> These headers are stored on a per-cpu page that is re-used
> for all the packets handled on that same CPU. Each skb
> holds a reference to that page and releases the page when
> it is reclaimed. When the page gets full, it is released
> and a new one is allocated.
> 
> Since any SKB that doesn't go through the fast-xmit path
> of mac80211 will be segmented, we can assume here that the
> packet is not WEP / TKIP and has a proper SNAP header.
> 
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> ---
> v4: * Create a helper to free the skb's ref to the hdr page
>     * add comment on that clarifies that the headers fit in a page
>     * return -ENOMEM if the per_cpu variable allocation failed
>     * don't zero the per_cpu struct after allocation
> ---

Meh... Someone internally founds a few bugs... Don't waste your time on
this one. V5 will come later tonight.
