From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] wimax: fix printk format warnings
Date: Sat, 21 Jul 2012 23:02:14 +0200
Message-ID: <CAMuHMdU4ob-+w31QyTyfa29U68_S71piZ9csgzXArQG45WqGrw@mail.gmail.com>
References: <500B170B.4000000@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <500B170B.4000000@xenotime.net>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 21, 2012 at 10:54 PM, Randy Dunlap <rdunlap@xenotime.net> wrote:
> Fix printk format warnings in drivers/net/wimax/i2400m:
>
> drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]
> drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 5 has type 'ssize_t' [-Wformat]
> drivers/net/wimax/i2400m/usb-fw.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]
>
> I don't see these warnings on x86.  The warnings that are quoted above
> are from Geert's kernel build reports.

Yeah, while technically they are correct (size_t and ssize_t differ in
signedness),
they only happen for cris, which has different base types for (s)size_t
(size_t = unsigned int, ssize_t = long), which is actually incorrect. Still
on my list of things to fix...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
