From: Michael Schmitz <schmitz@biophys.uni-duesseldorf.de>
Subject: Re: [PATCH 00/16] sleep_on removal, second try
Date: Thu, 27 Feb 2014 19:37:13 +1300
Message-ID: <2e8474df8cbb7cc583fe1c4e01649835@biophys.uni-duesseldorf.de>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	linux-atm-general@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Axboe <axboe@kernel.dk>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Mauro Carvalho Chehab <m.chehab@samsung.com>,
	linux-media@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd,


> It's been a while since the first submission of these patches,
> but a lot of them have made it into linux-next already, so here
> is the stuff that is not merged yet, hopefully addressing all
> the comments.
>
> Geert and Michael: the I was expecting the ataflop and atari_scsi
> patches to be merged already, based on earlier discussion.
> Can you apply them to the linux-m68k tree, or do you prefer
> them to go through the scsi and block maintainers?

Not sure what we decided to do - I'd prefer to double-check the latest 
ones first, but I'd be OK with these to go via m68k.

Maybe Geert waits for acks from linux-scsi and linux-block? (The rest 
of my patches to Atari SCSI still awaits comment there.)

Geert?

Regards,

	Michael

> Jens: I did not get any comments for the DAC960 and swim3 patches,
> I assume they are good to go in. Please merge.
>
> Hans and Mauro: As I commented on the old thread, I thought the
> four media patches were on their way. I have addressed the one
> comment that I missed earlier now, and used Hans' version for
> the two patches he changed. Please merge or let me know the status
> if you have already put them in some tree, but not yet into linux-next
>
> Greg or Andrew: The parport subsystem is orphaned unfortunately,
> can one of you pick up that patch?
>
> Davem: The two ATM patches got acks, but I did not hear back from
> Karsten regarding the ISDN patches. Can you pick up all six, or
> should we wait for comments about the ISDN patches?
>
> 	Arnd
>
> Cc: Andrew Morton <akpm@osdl.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Mauro Carvalho Chehab <m.chehab@samsung.com>
> Cc: Michael Schmitz <schmitz@biophys.uni-duesseldorf.de>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: linux-atm-general@lists.sourceforge.net
> Cc: linux-media@vger.kernel.org
> Cc: linux-scsi@vger.kernel.org
> Cc: netdev@vger.kernel.org
>
> Arnd Bergmann (16):
>   ataflop: fix sleep_on races
>   scsi: atari_scsi: fix sleep_on race
>   DAC960: remove sleep_on usage
>   swim3: fix interruptible_sleep_on race
>   [media] omap_vout: avoid sleep_on race
>   [media] usbvision: drop unused define USBVISION_SAY_AND_WAIT
>   [media] radio-cadet: avoid interruptible_sleep_on race
>   [media] arv: fix sleep_on race
>   parport: fix interruptible_sleep_on race
>   atm: nicstar: remove interruptible_sleep_on_timeout
>   atm: firestream: fix interruptible_sleep_on race
>   isdn: pcbit: fix interruptible_sleep_on race
>   isdn: hisax/elsa: fix sleep_on race in elsa FSM
>   isdn: divert, hysdn: fix interruptible_sleep_on race
>   isdn: fix multiple sleep_on races
>   sched: remove sleep_on() and friends
>
>  Documentation/DocBook/kernel-hacking.tmpl    | 10 ------
>  drivers/atm/firestream.c                     |  4 +--
>  drivers/atm/nicstar.c                        | 13 ++++----
>  drivers/block/DAC960.c                       | 34 ++++++++++----------
>  drivers/block/ataflop.c                      | 16 +++++-----
>  drivers/block/swim3.c                        | 18 ++++++-----
>  drivers/isdn/divert/divert_procfs.c          |  7 +++--
>  drivers/isdn/hisax/elsa.c                    |  9 ++++--
>  drivers/isdn/hisax/elsa_ser.c                |  3 +-
>  drivers/isdn/hysdn/hysdn_proclog.c           |  7 +++--
>  drivers/isdn/i4l/isdn_common.c               | 13 +++++---
>  drivers/isdn/pcbit/drv.c                     |  6 ++--
>  drivers/media/platform/arv.c                 |  6 ++--
>  drivers/media/platform/omap/omap_vout_vrfb.c |  3 +-
>  drivers/media/radio/radio-cadet.c            | 46 
> ++++++++++++++++------------
>  drivers/media/usb/usbvision/usbvision.h      |  8 -----
>  drivers/parport/share.c                      |  3 +-
>  drivers/scsi/atari_scsi.c                    | 12 ++++++--
>  include/linux/wait.h                         | 11 -------
>  kernel/sched/core.c                          | 46 
> ----------------------------
>  20 files changed, 113 insertions(+), 162 deletions(-)
>
> -- 
> 1.8.3.2
