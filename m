From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 8/8 v2] net: get rid of orig_dev parameter
 of packet handlers
Date: Sat, 5 Mar 2011 23:07:53 +0100
Message-ID: <20110305220752.GJ8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-9-git-send-email-jpirko@redhat.com>
 <20110305153247.GH8573@psychotron.redhat.com>
 <4D726B38.4040403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab1CEWID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 17:08:03 -0500
Content-Disposition: inline
In-Reply-To: <4D726B38.4040403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 05:56:24PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 16:32, Jiri Pirko a =E9crit :
>>Since orig_dev was used in af_packet (where it was replaced) and by
>>bonding ptype handlers (which are no longer with us) only, orig_dev
>>parameter is no longer needed ->  toss it out
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>Reviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>
>[snip]
>
>>diff --git a/net/core/dev.c b/net/core/dev.c
>>index 58daddb..c71bd18 100644
>>--- a/net/core/dev.c
>>+++ b/net/core/dev.c
>[snip]
>>@@ -3216,13 +3214,13 @@ ncls:
>>  		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev =
||
>>  		     ptype->dev =3D=3D orig_dev)) {
>>  			if (pt_prev)
>>-				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>+				ret =3D deliver_skb(skb, pt_prev);
>>  			pt_prev =3D ptype;
>>  		}
>>  	}
>>
>>  	if (pt_prev) {
>>-		ret =3D pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>>+		ret =3D pt_prev->func(skb, skb->dev, pt_prev);
>>  	} else {
>>  		atomic_long_inc(&skb->dev->rx_dropped);
>>  		kfree_skb(skb);
>
>This part does not properly apply on top of current net-next-2.6.
>
>Line 3216 is currently
>
>                    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D=
 skb->dev)) {
>
>	Nicolas.


depends on "net: allow handlers to be processed for orig_dev" which is =
a
regression fixer
