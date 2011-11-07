From: Michael Riesch <michael@riesch.at>
Subject: Re: [PATCH] usbnet: fix oops in usbnet_start_xmit
Date: Mon, 07 Nov 2011 14:29:13 +0100
Message-ID: <1320672553.2909.41.camel@malcolm>
References: <20111106183337.5379.4356.stgit@zurg>
Reply-To: michael@riesch.at
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, devel@openvz.org
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.29]:44726 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab1KGNoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 08:44:09 -0500
In-Reply-To: <20111106183337.5379.4356.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2011-11-06 at 22:33 +0300, Konstantin Khlebnikov wrote:
> This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
> SKB can be NULL at this point, at least for cdc-ncm.

OK, I didn't think of that, but...

> Let's call skb_tx_timestamp() after driver specific tx-fixup hacks.

... the reason I put the skb_tx_timestamp() call before the tx_fixup is
that these hacks often perform skb_push/skb_pull or any other kind of
framing. This may result (at least in the case of the asix drivers) in
perfectly correct PTP packets being not recognized as such by the packet
filter.

Can we do a check like this:
	if(skb) skb_tx_timestamp()
	tx_fixup()
?

Regards, Michael
