From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/2] net: add support for NS8390 based eth controllers on
 some ColdFire CPU boards
Date: Wed, 4 Jul 2012 09:52:14 +0200
Message-ID: <CAMuHMdVYiQyurOQOoeLbd6zXnaVK8Y9bUC=wXkHxhQO+cQwecQ@mail.gmail.com>
References: <1341377789-12970-1-git-send-email-gerg@snapgear.com>
	<1341377789-12970-3-git-send-email-gerg@snapgear.com>
	<1341379091.3627.15.camel@joe2Laptop>
	<4FF3E031.5040703@snapgear.com>
	<1341383999.3627.20.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Ungerer <gerg@snapgear.com>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1341383999.3627.20.camel@joe2Laptop>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 4, 2012 at 8:39 AM, Joe Perches <joe@perches.com> wrote:
>> >> +static int mcf8390_init(struct net_device *dev)
>> >> +{
>> >> +  static u32 offsets[] = {
>> >> +          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
>> >> +          0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
>> >> +  };
>> >
>> > const?  u8?
>>
>> That is assigned to the "reg_offset" field of "struct ei_device"
>> (defined in the existing 8390.h) and that is:
>>
>>      u32 *reg_offset;         /* Register mapping table */
>>
>> So I can't change this.
>
> Sure you can, you can assign a u8 to a u32 just fine.

It's not the value that's assigned, but a pointer to the table, so
for now it must be non-const u32 *.

> The value fits in a u8.  Might as well make it take
> less data space.  static const makes it read-only and
> makes the compiler assign it just once instead of at
> function invocation.

That needs changes to drivers/net/ethernet/8390/8390.h, and
also probably to some drivers that assign values to the array.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
