From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi: Create _rtl_dbg_trace function to reduce
 RT_TRACE code size
Date: Mon, 27 Jun 2016 20:55:16 -0700
Message-ID: <1467086116.24287.11.camel@perches.com>
References: <90cd7c8f12b51571db565fd496a2fcf610e2e484.1466894688.git.joe@perches.com>
	 <5771CA6C.1060403@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5771CA6C.1060403@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-27 at 19:53 -0500, Larry Finger wrote:
> On 06/25/2016 05:46 PM, Joe Perches wrote:
> >=20
> > This debugging macro can expand to a lot of code.
> > Make it a function to reduce code size.
> >=20
> > (x86-64 defconfig w/ all rtlwifi drivers and allyesconfig)
> > $ size drivers/net/wireless/realtek/rtlwifi/built-in.o*
> > =A0=A0=A0=A0text	=A0=A0=A0data	=A0=A0=A0=A0bss	=A0=A0=A0=A0dec	=A0=A0=
=A0=A0hex	filename
> > =A0 900083	=A0200499	=A0=A0=A01907	1102489	=A010d299	drivers/net/wi=
reless/realtek/rtlwifi/built-in.o.defconfig.new
> > 1113597	=A0200499	=A0=A0=A01907	1316003	=A01414a3	drivers/net/wirel=
ess/realtek/rtlwifi/built-in.o.defconfig.old
> > 1746879	=A0453503	=A0=A0=A08512	2208894	=A021b47e	drivers/net/wirel=
ess/realtek/rtlwifi/built-in.o.new
> > 2051965	=A0503311	=A0=A0=A08512	2563788	=A0271ecc	drivers/net/wirel=
ess/realtek/rtlwifi/built-in.o.old
> >=20
> > Signed-off-by: Joe Perches <joe@perches.com>
> I acked this before; however there is a bug that breaks the build if=A0
> CONFIG_RTLWIFI_DEBUG is not defined. The rest of the code calls=A0
> _rtl_dbg_trace(), but that symbol is never defined. The problem can b=
e fixed in=A0
> debug.c or debug.h.

Confused a bit. =A0What breaks again?

debug.h:

#ifdef CONFIG_RTLWIFI_DEBUG
[]
__printf(5, 6)
void _rtl_dbg_trace(struct rtl_priv *rtlpriv, int comp, int level,
		=A0=A0=A0=A0const char *modname, const char *fmt, ...);

#define RT_TRACE(rtlpriv, comp, level, fmt, ...)			\
	_rtl_dbg_trace(rtlpriv, comp, level,				\
		=A0=A0=A0=A0=A0=A0=A0KBUILD_MODNAME, fmt, ##__VA_ARGS__)
[]
#else
[]
__printf(4, 5)
static inline void RT_TRACE(struct rtl_priv *rtlpriv,
			=A0=A0=A0=A0int comp, int level,
			=A0=A0=A0=A0const char *fmt, ...)
{
}
[]
#endif
