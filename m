From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Wed, 19 Aug 2015 09:08:35 -0700
Message-ID: <1440000515.6610.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439993647.6610.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8250B6@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35368 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbbHSQIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:08:37 -0400
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E8250B6@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 15:07 +0000, Grumbach, Emmanuel wrote:

> I'll look at it.
> I was almost starting to implement that but then I thought with another
> (good?) reason to use LSO. LSO gives me the guarantee that the packet is
> directed to one peer, which might not be the case with xmit_more since
> we have one Qdisc for several clients in case we are in AP mode.
> Building an A-MSDU for several clients is not possible, at least not for
> several client in the L2 (different MAC addresses).
> LSO avoids this problem completely.

Then, simply calling skb_gso_segment() from the driver might be enough,
and less work for you.

This would even support TSO on IPv6

segs = skb_gso_segment(skb, tp->dev->features &
                            ~(NETIF_F_TSO | NETIF_F_TSO6));
