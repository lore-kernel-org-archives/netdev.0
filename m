From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH v2 00/41] CAPI: Major rework, tons of bug fixes
Date: Tue, 9 Feb 2010 13:54:23 +0100
Message-ID: <201002091354.23389.isdn@linux-pingi.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Montag, 8. Februar 2010 21:12:04 Jan Kiszka wrote:
> Here is the second take of my CAPI rework. I tried to address all
> feedback on v1, so this one comes with the following changes:
> 
>  o rebased over net-next
>  o reworked locking of the NCCI TTY using latest and greatest tty_port
>    features and kref, hopefully in the right way
>  o more fine-grained patch steps for the tricky TTY rework
>  o dynamic major for NCCI TTYs, ie. CAPI no longer claims 191
>  o dynamic TTY minor registrations, completely obsoleting capifs
>  o schedule capifs for removal
>  o some small additional cleanups
> 
> I kept my capifs fixes though this thing should die in the future. The
> work is done, and people may still use it due to their distro
> configuration (and the hard-wired loading by capiinit - needs fixing).
> 
> You can pull this series from
> 
> 	git://git.kiszka.org/linux-2.6.git capi
> 
Thank you for that effort, it looks very good for me.

I will acknowlegde them, after a few tests.


> Jan
> 
> Jan Kiszka (41):
>   CAPI: Fix leaks in capifs_new_ncci
>   CAPI: Sanitize capifs API
>   CAPI: Eliminate capifs_root variable
>   CAPI: Pin capifs instead of mounting it
>   CAPI: Reduce chattiness during module loading/removal
>   CAPI: Call a controller 'controller', not 'card'
>   CAPI: Convert capi drivers rwlock into mutex
>   CAPI: Rework capi_ctr_ready/down
>   CAPI: Rework controller state notifier
>   CAPI: Rework locking of controller data structures
>   CAPI: Rework application locking
>   CAPI: Reduce #ifdef mess around CONFIG_ISDN_CAPI_MIDDLEWARE
>   CAPI: Convert capidev_list_lock into a mutex
>   CAPI: Clean up capi_open/release
>   CAPI: Rework locking of capidev members
>   CAPI: Use non-atomic allocation during NCCI setup
>   CAPI: Fix racy capi_read
>   CAPI: Switch NCCI list to standard doubly linked list
>   CAPI: Switch capiminor list to array
>   CAPI: Clean up capinc_tty_init/exit
>   CAPI: Dynamically register minor devices
>   CAPI: Use dynamic major for NCCI TTYs by default
>   CAPI: Use kref on capiminor
>   CAPI: Establish install/cleanup handlers for capiminor TTYs
>   CAPI: Use tty_port to keep track of capiminor's tty
>   CAPI: Drop remaining NULL checks on tty->driver_data
>   CAPI: Issue synchronous hangup on capincci_free_minor
>   CAPI: Drop obsolete nccip from capiminor struct
>   CAPI: Clean up capiminors_lock
>   CAPI: Drop atomic ttyopencount
>   CAPI: Drop handle_minor_recv from capinc_tty_write
>   CAPI: Rework capiminor RX handler
>   CAPI: Rename datahandle_queue -> ackqueue_entry
>   CAPI: Use atomics for capiminor's datahandle and msgid
>   CAPI: Drop capiminor's unused inbytes counter
>   CAPI: Fix locking around capiminor's output queue and drop
>     workaround_lock
>   CAPI: Clean up capiminor_*_ack
>   CAPI: Drop return value of handle_minor_send
>   CAPI: Drop special controller lookup from capi20_put_message
>   CAPI: Schedule capifs for removal
>   CAPI: Remove experimental tag from middleware feature
> 
>  Documentation/feature-removal-schedule.txt |   10 +
>  drivers/isdn/capi/Kconfig                  |   16 +-
>  drivers/isdn/capi/capi.c                   | 1108
>  ++++++++++++++-------------- drivers/isdn/capi/capidrv.c                | 
>   48 +-
>  drivers/isdn/capi/capifs.c                 |  126 ++--
>  drivers/isdn/capi/capifs.h                 |   21 +-
>  drivers/isdn/capi/kcapi.c                  |  805 +++++++++++---------
>  drivers/isdn/capi/kcapi.h                  |   13 +-
>  drivers/isdn/capi/kcapi_proc.c             |   41 +-
>  include/linux/isdn/capilli.h               |    5 +-
>  include/linux/kernelcapi.h                 |   17 +-
>  11 files changed, 1151 insertions(+), 1059 deletions(-)
> 
