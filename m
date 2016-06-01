From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] ethtool: fix a kernel infoleak in ethtool_get_pauseparam
Date: Wed, 1 Jun 2016 15:57:33 +0100
Message-ID: <574EF7DD.9060905@solarflare.com>
References: <1464791961-8169-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ben@decadent.org.uk>, <kan.liang@intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<taesoo@gatech.edu>, <csong84@gatech.edu>,
	Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29126 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbcFAO62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 10:58:28 -0400
In-Reply-To: <1464791961-8169-1-git-send-email-kjlu@gatech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/16 15:39, Kangjie Lu wrote:
> The field autoneg of pauseparam is not initialized in some
> implementations of get_pauseparam(), but the whole object is
> copied to userland.
>
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
> ---
>  net/core/ethtool.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index f426c5a..84544bd 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1723,7 +1723,10 @@ static noinline_for_stack int ethtool_set_chan=
nels(struct net_device *dev,
> =20
>  static int ethtool_get_pauseparam(struct net_device *dev, void __use=
r *useraddr)
>  {
> -	struct ethtool_pauseparam pauseparam =3D { ETHTOOL_GPAUSEPARAM };
AIUI an incomplete compound initialiser will fill all unspecified field=
s
with zeroes of the appropriate type.  So this patch is unnecessary.

Per C99, =C2=A76.7.8.21:
> If there are fewer initializers in a brace-enclosed list than there a=
re elements or members of an aggregate [...] the remainder of the aggre=
gate shall be initialized implicitly the same as objects that have stat=
ic storage duration.

-Ed

> +	struct ethtool_pauseparam pauseparam;
> +
> +	memset(&pauseparam, 0, sizeof(pauseparam));
> +	pauseparam.cmd =3D ETHTOOL_GPAUSEPARAM;
> =20
>  	if (!dev->ethtool_ops->get_pauseparam)
>  		return -EOPNOTSUPP;
