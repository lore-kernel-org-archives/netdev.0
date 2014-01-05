From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] isdn: Build telespci and hfc_pci only for little endian CPUs
Date: Sun, 5 Jan 2014 19:30:25 +0100
Message-ID: <CAMuHMdVfr0ExtrU7bNUttJwkMXv-ZRo0A=j3gJ-=9nakP0uP+g@mail.gmail.com>
References: <1388944204-13008-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-kbuild <linux-kbuild@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1388944204-13008-1-git-send-email-linux@roeck-us.net>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 5, 2014 at 6:50 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> -       depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +       depends on CPU_LITTLE_ENDIAN && PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || MIPS || FRV || XTENSA))

Unfortunately CPU_LITTLE_ENDIAN is only available on architectures
that support two endiannesses. So the above will preclude e.g. x86, which is
where most ISDN users are.

One solution is to move CPU_LITTLE_ENDIAN and CPU_BIG_ENDIAN to the
common Kconfig parts. After that, the dependency above can just become

    depends on CPU_LITTLE_ENDIAN && PCI.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
