From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 6/12]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 27 May 2008 15:47:54 +0100
Message-ID: <20080527144752.GI28241@solarflare.com>
References: <1211897851.6967.79.camel@ubuntu804desktop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net, Vladislav Zolotarov <vladz@broadcom.com>,
	Eliezer Tamir <eliezert@broadcom.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:52625 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755586AbYE0OsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:48:11 -0400
Content-Disposition: inline
In-Reply-To: <1211897851.6967.79.camel@ubuntu804desktop.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein wrote:
> bnx2x: =EF=BB=BFAdd TPA, Broadcoms HW LRO
>=20
> =EF=BB=BF=EF=BB=BF=EF=BB=BF=EF=BB=BF=EF=BB=BFSigned-off-by: Vladislav=
 Zolotarov <vladz@broadcom.com>
> =EF=BB=BF=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com=
>

What's with the byte order marks here?

[...]
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 20ecfcb..366764e 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -84,6 +84,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
>  static int use_inta;
>  static int poll;
>  static int debug;
> +static int disable_tpa;
>  static int nomcp;
>  static int load_count[3]; /* 0 common, 1 port0, 2 port1 */
>  static int use_multi;
> @@ -91,6 +92,7 @@ static int use_multi;
>  module_param(use_inta, int, 0);
>  module_param(poll, int, 0);
>  module_param(debug, int, 0);
> +module_param(disable_tpa, int, 0);
>  module_param(nomcp, int, 0);
>  MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
>  MODULE_PARM_DESC(poll, "use polling (for debug)");

It's important that people are able to see how to disable LRO.  Using a
different name for it, and no module parameter description, really does=
n't
help.

You should also implement ethtool get_flags and set_flags methods so th=
at
LRO can be turned on and off later (at least once the ethtool command g=
ets
patched, hint hint).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
