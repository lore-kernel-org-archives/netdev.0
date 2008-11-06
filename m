From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 6 Nov 2008 11:03:16 +0300
Message-ID: <20081106080316.GA32337@ioremap.net>
References: <1225450706.5301.94.camel@localhost> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com> <1225838743.6116.20.camel@fry> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:57555 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbYKFIDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 03:03:20 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali.

On Wed, Nov 05, 2008 at 04:47:03PM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> In either case, the skb given to the destructor will still have the correct values for fragments we specified.  Of course, this is based on 2 assumptions:
> 
> 1.  Nothing further down the line won't add fragments, thereby overwriting frags[0]
> 2.  No-one writes to frags[0].page & frags[0].page_offset
> 
> 1 is reasonable because since the only reason we would be linearizing in the first place is if the device doesn't support scatter/gather, so it would be strange for something down the line to add more fragments that would have to be linearized anyways.
> 
> 2 is reasonable since it would only make sense if something down the line used this as a temporary variable storage, which again should be unlikely.

What if skb was queued in hardware or qdisk and userspace rewrites
mapped page placed in fraglist?

> Another approach may be to store it in the cb as we had done so originally, except with skb_clone to ensure no other layers overwrite it, although I'm not 100% sure of the implications of skb_clone has for things like the cb & users fields and kfree_skb.

It is not allowed to store something in cb block which is intended to
live while skb is processed on different layers. In this particular case
qdisk engine will overwrite skb's cb.

-- 
	Evgeniy Polyakov
