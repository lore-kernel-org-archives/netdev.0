From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Thu, 20 Aug 2015 06:11:09 -0700
Message-ID: <1440076269.6610.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
	 <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8257BD@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36600 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbHTNLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:11:12 -0400
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E8257BD@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 06:21 +0000, Grumbach, Emmanuel wrote:
> 
> On 08/19/2015 11:39 PM, Eric Dumazet wrote:
> > On Wed, 2015-08-19 at 19:17 +0000, Grumbach, Emmanuel wrote:
> > 
> >> Hm.. how would net/core/tso.c avoid this?
> > 
> > Because a driver using these helpers keep around the original LSO packet
> > and frees it normally at TX completion time.
> > 
> 
> Which is why I can't really use it. The complexity is that I have to
> (ieee802.11 specification) split an LSO is several 802.11 packets. The
> maximal 802.11 packet I can send under ideal condition is 11K long or
> so. So I *must* generate several 802.11 frames from one single LSO
> packet. OTOH, I can have more than MSS bytes in a 802.11 A-MSDU.
> 

Who said you had to free original packet ? Just keep it around.

TCP will work better ( check skb_still_in_host_queue() helper if you
want to know why)

> Maybe what would help would be to be able to dynamically change the
> maximal size of an LSO packet. That would allow the wifi driver to
> ensure that the LSO can fit in a single 802.11 packet. Note that since
> the maximal length of the A-MSDU can vary based on link conditions
> (since there is only one CRC for the whole A-MSDU, you don't want long
> A-MSDUs in bad link conditions) the driver would need to be able to tell
> the TCP stack to modify the length of an LSO packet.
> To me, this sounds to be ... an overkill?

It is already doable. Check dev->gso_max_size ( and
netif_set_gso_max_size())

Make sure you do not reinvent the wheel ;)
