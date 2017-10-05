From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from
 DEFINE_TIMER
Date: Thu, 5 Oct 2017 07:28:28 +0200
Message-ID: <20171005052828.GA14470@kroah.com>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Harish Patil <harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Julian Wiedmann <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Manish Chopra <manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Martin Schwidefsky
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1507159627-127660-11-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2017 at 04:27:04PM -0700, Kees Cook wrote:
> Drop the arguments from the macro and adjust all callers with the
> following script:
> 
>   perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>     $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
> 
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Acked-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> # for m68k parts
> ---
>  arch/arm/mach-ixp4xx/dsmg600-setup.c      | 2 +-
>  arch/arm/mach-ixp4xx/nas100d-setup.c      | 2 +-
>  arch/m68k/amiga/amisound.c                | 2 +-
>  arch/m68k/mac/macboing.c                  | 2 +-
>  arch/mips/mti-malta/malta-display.c       | 2 +-
>  arch/parisc/kernel/pdc_cons.c             | 2 +-
>  arch/s390/mm/cmm.c                        | 2 +-
>  drivers/atm/idt77105.c                    | 4 ++--
>  drivers/atm/iphase.c                      | 2 +-
>  drivers/block/ataflop.c                   | 8 ++++----
>  drivers/char/dtlk.c                       | 2 +-
>  drivers/char/hangcheck-timer.c            | 2 +-
>  drivers/char/nwbutton.c                   | 2 +-
>  drivers/char/rtc.c                        | 2 +-
>  drivers/input/touchscreen/s3c2410_ts.c    | 2 +-
>  drivers/net/cris/eth_v10.c                | 6 +++---
>  drivers/net/hamradio/yam.c                | 2 +-
>  drivers/net/wireless/atmel/at76c50x-usb.c | 2 +-
>  drivers/staging/speakup/main.c            | 2 +-
>  drivers/staging/speakup/synth.c           | 2 +-
>  drivers/tty/cyclades.c                    | 2 +-
>  drivers/tty/isicom.c                      | 2 +-
>  drivers/tty/moxa.c                        | 2 +-
>  drivers/tty/rocket.c                      | 2 +-
>  drivers/tty/vt/keyboard.c                 | 2 +-
>  drivers/tty/vt/vt.c                       | 2 +-
>  drivers/watchdog/alim7101_wdt.c           | 2 +-
>  drivers/watchdog/machzwd.c                | 2 +-
>  drivers/watchdog/mixcomwd.c               | 2 +-
>  drivers/watchdog/sbc60xxwdt.c             | 2 +-
>  drivers/watchdog/sc520_wdt.c              | 2 +-
>  drivers/watchdog/via_wdt.c                | 2 +-
>  drivers/watchdog/w83877f_wdt.c            | 2 +-
>  drivers/xen/grant-table.c                 | 2 +-
>  fs/pstore/platform.c                      | 2 +-
>  include/linux/timer.h                     | 4 ++--
>  kernel/irq/spurious.c                     | 2 +-
>  lib/random32.c                            | 2 +-
>  net/atm/mpc.c                             | 2 +-
>  net/decnet/dn_route.c                     | 2 +-
>  net/ipv6/ip6_flowlabel.c                  | 2 +-
>  net/netrom/nr_loopback.c                  | 2 +-
>  security/keys/gc.c                        | 2 +-
>  sound/oss/midibuf.c                       | 2 +-
>  sound/oss/soundcard.c                     | 2 +-
>  sound/oss/sys_timer.c                     | 2 +-
>  sound/oss/uart6850.c                      | 2 +-
>  47 files changed, 54 insertions(+), 54 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
