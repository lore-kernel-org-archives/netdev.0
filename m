From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [patch] tulip: cleanup by using ARRAY_SIZE()
Date: Thu, 23 Jan 2014 08:46:18 -0800
Message-ID: <CAP6odji5mepZDe3EHWFJjDrrhjCq2HjMb-_Cf-=Qm8oFOJyyhg@mail.gmail.com>
References: <20140123082637.GC28688@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:43773 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbaAWQqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 11:46:21 -0500
In-Reply-To: <20140123082637.GC28688@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 12:26 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> In this situation then ARRAY_SIZE() and sizeof() are the same, but we're
> really dealing with array indexes and not byte offsets so ARRAY_SIZE()
> is cleaner.

Yup.

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

cheers
grant
>
> diff --git a/drivers/net/ethernet/dec/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
> index 0d0ba725341a..dcf21a36a9cf 100644
> --- a/drivers/net/ethernet/dec/tulip/media.c
> +++ b/drivers/net/ethernet/dec/tulip/media.c
> @@ -457,7 +457,7 @@ void tulip_find_mii(struct net_device *dev, int board_idx)
>         /* Find the connected MII xcvrs.
>            Doing this in open() would allow detecting external xcvrs later,
>            but takes much time. */
> -       for (phyn = 1; phyn <= 32 && phy_idx < sizeof (tp->phys); phyn++) {
> +       for (phyn = 1; phyn <= 32 && phy_idx < ARRAY_SIZE(tp->phys); phyn++) {
>                 int phy = phyn & 0x1f;
>                 int mii_status = tulip_mdio_read (dev, phy, MII_BMSR);
>                 if ((mii_status & 0x8301) == 0x8001 ||
