From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] Add error check to hex2bin().
Date: Mon, 18 Jul 2011 22:49:22 +0200
Message-ID: <CAMuHMdVxR7AC7H_Yys8SiaGqM2JsNXLsRpujqojMYd_CXWxcAw@mail.gmail.com>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
	<1310991796.3903.6.camel@smile>
	<201107182148.AGD21306.FOLtJVMSOOFQHF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107182148.AGD21306.FOLtJVMSOOFQHF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2011 at 14:48, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Currently, security/keys/ is the only user of hex2bin().
> Should I keep hex2bin() unmodified in case of bad input?
> If so, I'd like to make it as hex2bin_safe().
> ----------------------------------------
> [PATCH] Add error check to hex2bin().
>
> Since converting 2 hexadecimal letters into a byte with error checks =
is
> commonly used, we can replace multiple hex_to_bin() calls with single=
 hex2bin()
> call by changing hex2bin() to do error checks.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I=3Dlove.SAKURA.ne.jp>
> ---
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 953352a..186e9fc 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -374,7 +374,7 @@ static inline char *pack_hex_byte(char *buf, u8 b=
yte)
> =C2=A0}
>
> =C2=A0extern int hex_to_bin(char ch);
> -extern void hex2bin(u8 *dst, const char *src, size_t count);
> +extern bool hex2bin(u8 *dst, const char *src, size_t count);
>
> =C2=A0/*
> =C2=A0* General tracing related utility functions - trace_printk(),
> diff --git a/lib/hexdump.c b/lib/hexdump.c
> index f5fe6ba..1524002 100644
> --- a/lib/hexdump.c
> +++ b/lib/hexdump.c
> @@ -38,14 +38,22 @@ EXPORT_SYMBOL(hex_to_bin);
> =C2=A0* @dst: binary result
> =C2=A0* @src: ascii hexadecimal string
> =C2=A0* @count: result length
> + *
> + * Returns true on success, false in case of bad input.

What about making it return the number of unprocessed bytes left instea=
d?
Then the caller knows where the problem lies. And zero would mean succe=
ss.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
