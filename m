From: Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Mon, 15 May 2017 21:02:36 +0200
Message-ID: <20170515190235.GA1740@makrotopia.org>
References: <20170515134711.2770374-1-arnd@arndb.de>
 <20170515142520.GA13996@redhat.com>
 <CAK8P3a1xYah7_4=DAcN+M83noUQyLZ9hV=WWD0Q79sQrFsoroA@mail.gmail.com>
 <20170515.104052.1376354562934671974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd-r2nGTMty4D4@public.gmane.org, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dev-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vasilugin-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org, roman-9zmcapQ0v8Q@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170515.104052.1376354562934671974.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 10:40:52AM -0400, David Miller wrote:
> From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Date: Mon, 15 May 2017 16:36:45 +0200
> 
> > On Mon, May 15, 2017 at 4:28 PM, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
> >>> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
> >>> stack usage (with a private patch set I have to turn on this warning,
> >>> which I intend to get into the next kernel release):
> >>>
> >>> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
> >>> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> >>>
> >>> The problem is that KASAN inserts a redzone around each local variable that
> >>> gets passed by reference, and the newly added function has a lot of them.
> >>> We can easily avoid that here by changing the calling convention to have
> >>> the output as the return value of the function. This should also results in
> >>> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
> >>> KASAN.
> >>>
> >>> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
> >>> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> >>> ---
> >>>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
> >>>  1 file changed, 164 insertions(+), 155 deletions(-)
> >>
> >> We have read(, &val) calling convention since forever in rt2x00 and that
> >> was never a problem. I dislike to change that now to make some tools
> >> happy, I think problem should be fixed in the tools instead.
> > 
> > How about adding 'depends on !KASAN' in Kconfig instead?
> 
> Please let's not go down that route and make such facilities less
> useful due to decreased coverage.

Being the one to blame for submitting the patch adding most of the
problem's footprint: Arnd's change looks good to me and I believe it
should be merged.
This is the type of feedback I was hoping for when submitting all the
long-forgotten and rotting patches from OpenWrt's mac80211 driver
patches! Thanks to Arnd for your efforts!

Consider this as
Acked-by: Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>
for Arnd's original patch (and for NOT adding 'depends on !KASAN')

Cheers


Daniel

> 
> Thanks.
