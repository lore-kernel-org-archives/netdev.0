From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net/sun3_82586: Kill array subscript above array bounds warning
Date: Thu, 18 Jul 2013 09:04:36 +0200
Message-ID: <CAMuHMdWeKuFVd-8_XRzWmJNp11cHP6wRj7K96v=D9We2=XyAgw@mail.gmail.com>
References: <1374063905-4050-1-git-send-email-geert@linux-m68k.org>
	<20130717.182237.906875287830581782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sam Creasey <sammy@sammy.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux/m68k" <linux-m68k@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20130717.182237.906875287830581782.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 18, 2013 at 3:22 AM, David Miller <davem@davemloft.net> wrote:
>> drivers/net/ethernet/i825xx/sun3_82586.c: In function 'sun3_82586_timeout':
>> drivers/net/ethernet/i825xx/sun3_82586.c:993:89: warning: array subscript is above array bounds [-Warray-bounds]
>>
>> Using the default NUM_XMIT_BUFFS = 1, there's only one transmit buffer.
>> Hence accessing the second buffer is an out-of-bounds access.
>> Print the command status of the first NOP buffer instead.
>>
>> Fortunately this actually worked fine, as the layout of transmit and NOP
>> buffers is sufficiently similar.
>>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Three more CPP directives in a DEBUG ifdef'd piece of code, yuck.
>
> I'd say just kill this whole DEBUG section entirely.  If people
> want this driver to print this debugging, do it properly with
> netif_err() or similar.

Yeah, this driver could use some major cleanup. I had to protect my eyes while
fixing the compiler warning.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
