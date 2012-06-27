From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [patch -next] 6lowpan: double unlock on an error path
Date: Wed, 27 Jun 2012 10:57:18 +0400
Message-ID: <CAJmB2rCwYo1KR_gOQFrvMn2A2px1mPEN5DV+KGtjV914p-o7NA@mail.gmail.com>
References: <20120627065309.GA25774@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62757 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165Ab2F0G5U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 02:57:20 -0400
In-Reply-To: <20120627065309.GA25774@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/27 Dan Carpenter <dan.carpenter@oracle.com>:
> We already unlocked a few lines earlier here, so we can go directly t=
o
> drop without passing through unlock. =A0This was introduced recently =
in
> c5d3687f6c ('6lowpan: read data from skb safely').
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index ad0c226..cd5007f 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -771,7 +771,7 @@ lowpan_process_data(struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(frame);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (lowpan_fetch_skb_u=
8(skb, &iphc0))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto un=
lock_and_drop;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto dr=
op;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

Acked-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
