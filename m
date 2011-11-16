From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [patch -next v2] 6LoWPAN: double free in lowpan_fragment_xmit()
Date: Wed, 16 Nov 2011 11:42:07 +0300
Message-ID: <CAJmB2rBTHCTcetstpZkNkxX4CAxYF3Sd=Vrg3dmTMDzFQK0vqg@mail.gmail.com>
References: <20111116083254.GB4349@mwanda>
	<20111116083643.GA25612@mwanda>
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
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45643 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132Ab1KPImI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 03:42:08 -0500
In-Reply-To: <20111116083643.GA25612@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/16 Dan Carpenter <dan.carpenter@oracle.com>:
> dev_queue_xmit() consumes its own skb, so the call to dev_kfree_skb()
> in lowpan_fragment_xmit() is a double free.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: fixed commit message.
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 602f318..e4ecc1e 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -980,9 +980,6 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *hea=
d,
>
> =A0 =A0 =A0 =A0ret =3D dev_queue_xmit(frag);
>
> - =A0 =A0 =A0 if (ret < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(frag);
> -
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
>
>

Acked-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
