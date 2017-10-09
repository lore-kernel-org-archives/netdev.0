From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from
 DEFINE_TIMER
Date: Mon, 9 Oct 2017 15:27:22 +0200
Message-ID: <20171009132722.GI20977@linux-mips.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Mark Gross <mark.gross@intel.com>,
        "Martin K. Petersen"
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:47710 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbdJIN1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:27:44 -0400
Content-Disposition: inline
In-Reply-To: <1507159627-127660-11-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 04:27:04PM -0700, Kees Cook wrote:

> Subject: [PATCH 10/13] timer: Remove expires and data arguments from
>  DEFINE_TIMER
> 
> Drop the arguments from the macro and adjust all callers with the
> following script:
> 
>   perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>     $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> # for m68k parts
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

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Thanks,

  Ralf
