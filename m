From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow
	registers.
Date: Wed, 24 Dec 2008 18:35:31 +0000
Message-ID: <1230143731.3070.2.camel@achroite>
References: <20081224181834.GA15470@susedev.qlogic.org>
	 <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:53814 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751273AbYLXSfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:35:34 -0500
In-Reply-To: <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-12-24 at 10:21 -0800, Ron Mercer wrote:
> Shadow registers are host memory locations that the chip echos queue =
indexes to.
> The chip does this in little endian values, so they need to be swappe=
d before referencing.
>=20
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>  mode change 100644 =3D> 100755 drivers/net/qlge/qlge.h
>=20
> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
> old mode 100644
> new mode 100755
> index ba2e1c5..f1751a2
> --- a/drivers/net/qlge/qlge.h
> +++ b/drivers/net/qlge/qlge.h
> @@ -1477,9 +1477,9 @@ static inline void ql_write_db_reg(u32 val, voi=
d __iomem *addr)
>   * update the relevant index register and then copy the value to the
>   * shadow register in host memory.
>   */
> -static inline unsigned int ql_read_sh_reg(const volatile void  *addr=
)
> +static inline u32 ql_read_sh_reg(const volatile void  *addr)
>  {
> -	return *(volatile unsigned int __force *)addr;
> +	return le32_to_cpu(*(volatile unsigned int __force *)addr);

I think that should be:
	=EF=BB=BFreturn le32_to_cpu(*(const volatile __le32 *)addr);

Ben.

>  }
> =20
>  extern char qlge_driver_name[];

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

