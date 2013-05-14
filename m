From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCHv2 net 2/2] sfc: Reduce RX scatter buffer size, and reduce
 alignment if appropriate
Date: Tue, 14 May 2013 09:09:08 +0200
Message-ID: <CAMuHMdWoSGYZUAHCZ8rjyXcvUoiLx0tv+HuNWXoyZEJHK+ufPw@mail.gmail.com>
References: <1368482311.3305.48.camel@bwh-desktop.uk.solarflarecom.com>
	<1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	linux-s390@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2013 at 12:01 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> efx_start_datapath() asserts that we can fit 2 RX scatter buffers plus
> a software structure, each appropriately aligned, into a single page.
> Where L1_CACHE_BYTES == 256 and PAGE_SIZE == 4096, which is the case
> on s390, this assertion fails.
>
> The current scatter buffer size is also not a multiple of 64 or 128,
> which are more common cache line sizes.  If we can make both the start
> and end of a scatter buffer cache-aligned, this will reduce the need
> for read-modify-write operations on inter- processor links.
>
> Fix the alignment by reducing EFX_RX_USR_BUF_SIZE to 2048 - 256 ==
> 1792.  (We could use 2048 - L1_CACHE_BYTES, but EFX_RX_USR_BUF_SIZE
> also affects user-level networking where a larger amount of
> housekeeping data may be needed.  Although this version of the driver
> does not support user-level networking, I prefer to keep scattering
> behaviour consistent with the out-of-tree version.)
>
> This still doesn't fix the s390 build because like most architectures
> it has NET_IP_ALIGN == 2.  When NET_IP_ALIGN != 0 we cannot achieve
> cache line alignment at either the start or end of a scatter buffer,
> so there is actually no point in padding the buffers to a multiple of
> the cache line size.  All we need is 4-byte alignment of the network
> header, so do that.
>
> Adjust the assertions accordingly.
>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Fixes the s390 build, so
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
