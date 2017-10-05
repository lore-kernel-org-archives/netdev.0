From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from
 DEFINE_TIMER
Date: Wed, 4 Oct 2017 17:13:45 -0700
Message-ID: <a9e69acc-0ae6-db44-a611-3a633372118a@roeck-us.net>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
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
        Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507159627-127660-11-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/04/2017 04:27 PM, Kees Cook wrote:
> Drop the arguments from the macro and adjust all callers with the
> following script:
> 
>    perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>      $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
> 
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Acked-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> # for m68k parts

For watchdog:

Acked-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>

> ---
>   arch/arm/mach-ixp4xx/dsmg600-setup.c      | 2 +-
>   arch/arm/mach-ixp4xx/nas100d-setup.c      | 2 +-
>   arch/m68k/amiga/amisound.c                | 2 +-
>   arch/m68k/mac/macboing.c                  | 2 +-
>   arch/mips/mti-malta/malta-display.c       | 2 +-
>   arch/parisc/kernel/pdc_cons.c             | 2 +-
>   arch/s390/mm/cmm.c                        | 2 +-
>   drivers/atm/idt77105.c                    | 4 ++--
>   drivers/atm/iphase.c                      | 2 +-
>   drivers/block/ataflop.c                   | 8 ++++----
>   drivers/char/dtlk.c                       | 2 +-
>   drivers/char/hangcheck-timer.c            | 2 +-
>   drivers/char/nwbutton.c                   | 2 +-
>   drivers/char/rtc.c                        | 2 +-
>   drivers/input/touchscreen/s3c2410_ts.c    | 2 +-
>   drivers/net/cris/eth_v10.c                | 6 +++---
>   drivers/net/hamradio/yam.c                | 2 +-
>   drivers/net/wireless/atmel/at76c50x-usb.c | 2 +-
>   drivers/staging/speakup/main.c            | 2 +-
>   drivers/staging/speakup/synth.c           | 2 +-
>   drivers/tty/cyclades.c                    | 2 +-
>   drivers/tty/isicom.c                      | 2 +-
>   drivers/tty/moxa.c                        | 2 +-
>   drivers/tty/rocket.c                      | 2 +-
>   drivers/tty/vt/keyboard.c                 | 2 +-
>   drivers/tty/vt/vt.c                       | 2 +-
>   drivers/watchdog/alim7101_wdt.c           | 2 +-
>   drivers/watchdog/machzwd.c                | 2 +-
>   drivers/watchdog/mixcomwd.c               | 2 +-
>   drivers/watchdog/sbc60xxwdt.c             | 2 +-
>   drivers/watchdog/sc520_wdt.c              | 2 +-
>   drivers/watchdog/via_wdt.c                | 2 +-
>   drivers/watchdog/w83877f_wdt.c            | 2 +-
>   drivers/xen/grant-table.c                 | 2 +-
>   fs/pstore/platform.c                      | 2 +-
>   include/linux/timer.h                     | 4 ++--
>   kernel/irq/spurious.c                     | 2 +-
>   lib/random32.c                            | 2 +-
>   net/atm/mpc.c                             | 2 +-
>   net/decnet/dn_route.c                     | 2 +-
>   net/ipv6/ip6_flowlabel.c                  | 2 +-
>   net/netrom/nr_loopback.c                  | 2 +-
>   security/keys/gc.c                        | 2 +-
>   sound/oss/midibuf.c                       | 2 +-
>   sound/oss/soundcard.c                     | 2 +-
>   sound/oss/sys_timer.c                     | 2 +-
>   sound/oss/uart6850.c                      | 2 +-
>   47 files changed, 54 insertions(+), 54 deletions(-)
> 
> diff --git a/arch/arm/mach-ixp4xx/dsmg600-setup.c b/arch/arm/mach-ixp4xx/dsmg600-setup.c
> index b3bd0e137f6d..b3689a141ec6 100644
> --- a/arch/arm/mach-ixp4xx/dsmg600-setup.c
> +++ b/arch/arm/mach-ixp4xx/dsmg600-setup.c
> @@ -174,7 +174,7 @@ static int power_button_countdown;
>   #define PBUTTON_HOLDDOWN_COUNT 4 /* 2 secs */
>   
>   static void dsmg600_power_handler(unsigned long data);
> -static DEFINE_TIMER(dsmg600_power_timer, dsmg600_power_handler, 0, 0);
> +static DEFINE_TIMER(dsmg600_power_timer, dsmg600_power_handler);
>   
>   static void dsmg600_power_handler(unsigned long data)
>   {
> diff --git a/arch/arm/mach-ixp4xx/nas100d-setup.c b/arch/arm/mach-ixp4xx/nas100d-setup.c
> index 4e0f762bc651..562d05f9888e 100644
> --- a/arch/arm/mach-ixp4xx/nas100d-setup.c
> +++ b/arch/arm/mach-ixp4xx/nas100d-setup.c
> @@ -197,7 +197,7 @@ static int power_button_countdown;
>   #define PBUTTON_HOLDDOWN_COUNT 4 /* 2 secs */
>   
>   static void nas100d_power_handler(unsigned long data);
> -static DEFINE_TIMER(nas100d_power_timer, nas100d_power_handler, 0, 0);
> +static DEFINE_TIMER(nas100d_power_timer, nas100d_power_handler);
>   
>   static void nas100d_power_handler(unsigned long data)
>   {
> diff --git a/arch/m68k/amiga/amisound.c b/arch/m68k/amiga/amisound.c
> index 90a60d758f8b..a23f48181fd6 100644
> --- a/arch/m68k/amiga/amisound.c
> +++ b/arch/m68k/amiga/amisound.c
> @@ -66,7 +66,7 @@ void __init amiga_init_sound(void)
>   }
>   
>   static void nosound( unsigned long ignored );
> -static DEFINE_TIMER(sound_timer, nosound, 0, 0);
> +static DEFINE_TIMER(sound_timer, nosound);
>   
>   void amiga_mksound( unsigned int hz, unsigned int ticks )
>   {
> diff --git a/arch/m68k/mac/macboing.c b/arch/m68k/mac/macboing.c
> index ffaa1f6439ae..9a52aff183d0 100644
> --- a/arch/m68k/mac/macboing.c
> +++ b/arch/m68k/mac/macboing.c
> @@ -56,7 +56,7 @@ static void ( *mac_special_bell )( unsigned int, unsigned int, unsigned int );
>   /*
>    * our timer to start/continue/stop the bell
>    */
> -static DEFINE_TIMER(mac_sound_timer, mac_nosound, 0, 0);
> +static DEFINE_TIMER(mac_sound_timer, mac_nosound);
>   
>   /*
>    * Sort of initialize the sound chip (called from mac_mksound on the first
> diff --git a/arch/mips/mti-malta/malta-display.c b/arch/mips/mti-malta/malta-display.c
> index ac813158b9b8..063de44675ce 100644
> --- a/arch/mips/mti-malta/malta-display.c
> +++ b/arch/mips/mti-malta/malta-display.c
> @@ -37,7 +37,7 @@ void mips_display_message(const char *str)
>   }
>   
>   static void scroll_display_message(unsigned long unused);
> -static DEFINE_TIMER(mips_scroll_timer, scroll_display_message, 0, 0);
> +static DEFINE_TIMER(mips_scroll_timer, scroll_display_message);
>   
>   static void scroll_display_message(unsigned long unused)
>   {
> diff --git a/arch/parisc/kernel/pdc_cons.c b/arch/parisc/kernel/pdc_cons.c
> index 10a5ae9553fd..27a2dd616a7d 100644
> --- a/arch/parisc/kernel/pdc_cons.c
> +++ b/arch/parisc/kernel/pdc_cons.c
> @@ -92,7 +92,7 @@ static int pdc_console_setup(struct console *co, char *options)
>   #define PDC_CONS_POLL_DELAY (30 * HZ / 1000)
>   
>   static void pdc_console_poll(unsigned long unused);
> -static DEFINE_TIMER(pdc_console_timer, pdc_console_poll, 0, 0);
> +static DEFINE_TIMER(pdc_console_timer, pdc_console_poll);
>   static struct tty_port tty_port;
>   
>   static int pdc_console_tty_open(struct tty_struct *tty, struct file *filp)
> diff --git a/arch/s390/mm/cmm.c b/arch/s390/mm/cmm.c
> index 829c63dbc81a..2dbdcd85b68f 100644
> --- a/arch/s390/mm/cmm.c
> +++ b/arch/s390/mm/cmm.c
> @@ -56,7 +56,7 @@ static DEFINE_SPINLOCK(cmm_lock);
>   
>   static struct task_struct *cmm_thread_ptr;
>   static DECLARE_WAIT_QUEUE_HEAD(cmm_thread_wait);
> -static DEFINE_TIMER(cmm_timer, NULL, 0, 0);
> +static DEFINE_TIMER(cmm_timer, NULL);
>   
>   static void cmm_timer_fn(unsigned long);
>   static void cmm_set_timer(void);
> diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
> index 082aa02abc57..57af9fd198e4 100644
> --- a/drivers/atm/idt77105.c
> +++ b/drivers/atm/idt77105.c
> @@ -49,8 +49,8 @@ static void idt77105_stats_timer_func(unsigned long);
>   static void idt77105_restart_timer_func(unsigned long);
>   
>   
> -static DEFINE_TIMER(stats_timer, idt77105_stats_timer_func, 0, 0);
> -static DEFINE_TIMER(restart_timer, idt77105_restart_timer_func, 0, 0);
> +static DEFINE_TIMER(stats_timer, idt77105_stats_timer_func);
> +static DEFINE_TIMER(restart_timer, idt77105_restart_timer_func);
>   static int start_timer = 1;
>   static struct idt77105_priv *idt77105_all = NULL;
>   
> diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
> index fc72b763fdd7..ad6b582c268e 100644
> --- a/drivers/atm/iphase.c
> +++ b/drivers/atm/iphase.c
> @@ -76,7 +76,7 @@ static IADEV *ia_dev[8];
>   static struct atm_dev *_ia_dev[8];
>   static int iadev_count;
>   static void ia_led_timer(unsigned long arg);
> -static DEFINE_TIMER(ia_timer, ia_led_timer, 0, 0);
> +static DEFINE_TIMER(ia_timer, ia_led_timer);
>   static int IA_TX_BUF = DFL_TX_BUFFERS, IA_TX_BUF_SZ = DFL_TX_BUF_SZ;
>   static int IA_RX_BUF = DFL_RX_BUFFERS, IA_RX_BUF_SZ = DFL_RX_BUF_SZ;
>   static uint IADebugFlag = /* IF_IADBG_ERR | IF_IADBG_CBR| IF_IADBG_INIT_ADAPTER
> diff --git a/drivers/block/ataflop.c b/drivers/block/ataflop.c
> index 92da886180aa..ae596e55bcb6 100644
> --- a/drivers/block/ataflop.c
> +++ b/drivers/block/ataflop.c
> @@ -373,10 +373,10 @@ static void floppy_release(struct gendisk *disk, fmode_t mode);
>   
>   /************************* End of Prototypes **************************/
>   
> -static DEFINE_TIMER(motor_off_timer, fd_motor_off_timer, 0, 0);
> -static DEFINE_TIMER(readtrack_timer, fd_readtrack_check, 0, 0);
> -static DEFINE_TIMER(timeout_timer, fd_times_out, 0, 0);
> -static DEFINE_TIMER(fd_timer, check_change, 0, 0);
> +static DEFINE_TIMER(motor_off_timer, fd_motor_off_timer);
> +static DEFINE_TIMER(readtrack_timer, fd_readtrack_check);
> +static DEFINE_TIMER(timeout_timer, fd_times_out);
> +static DEFINE_TIMER(fd_timer, check_change);
>   	
>   static void fd_end_request_cur(blk_status_t err)
>   {
> diff --git a/drivers/char/dtlk.c b/drivers/char/dtlk.c
> index 58471394beb9..1a0385ed6417 100644
> --- a/drivers/char/dtlk.c
> +++ b/drivers/char/dtlk.c
> @@ -84,7 +84,7 @@ static int dtlk_has_indexing;
>   static unsigned int dtlk_portlist[] =
>   {0x25e, 0x29e, 0x2de, 0x31e, 0x35e, 0x39e, 0};
>   static wait_queue_head_t dtlk_process_list;
> -static DEFINE_TIMER(dtlk_timer, dtlk_timer_tick, 0, 0);
> +static DEFINE_TIMER(dtlk_timer, dtlk_timer_tick);
>   
>   /* prototypes for file_operations struct */
>   static ssize_t dtlk_read(struct file *, char __user *,
> diff --git a/drivers/char/hangcheck-timer.c b/drivers/char/hangcheck-timer.c
> index 5406b90bf626..5b8db2ed844d 100644
> --- a/drivers/char/hangcheck-timer.c
> +++ b/drivers/char/hangcheck-timer.c
> @@ -124,7 +124,7 @@ static unsigned long long hangcheck_tsc, hangcheck_tsc_margin;
>   
>   static void hangcheck_fire(unsigned long);
>   
> -static DEFINE_TIMER(hangcheck_ticktock, hangcheck_fire, 0, 0);
> +static DEFINE_TIMER(hangcheck_ticktock, hangcheck_fire);
>   
>   static void hangcheck_fire(unsigned long data)
>   {
> diff --git a/drivers/char/nwbutton.c b/drivers/char/nwbutton.c
> index e6d0d271c58c..44006ed9558f 100644
> --- a/drivers/char/nwbutton.c
> +++ b/drivers/char/nwbutton.c
> @@ -27,7 +27,7 @@ static void button_sequence_finished (unsigned long parameters);
>   
>   static int button_press_count;		/* The count of button presses */
>   /* Times for the end of a sequence */
> -static DEFINE_TIMER(button_timer, button_sequence_finished, 0, 0);
> +static DEFINE_TIMER(button_timer, button_sequence_finished);
>   static DECLARE_WAIT_QUEUE_HEAD(button_wait_queue); /* Used for blocking read */
>   static char button_output_buffer[32];	/* Stores data to write out of device */
>   static int bcount;			/* The number of bytes in the buffer */
> diff --git a/drivers/char/rtc.c b/drivers/char/rtc.c
> index 974d48927b07..616871e68e09 100644
> --- a/drivers/char/rtc.c
> +++ b/drivers/char/rtc.c
> @@ -137,7 +137,7 @@ static DECLARE_WAIT_QUEUE_HEAD(rtc_wait);
>   #ifdef RTC_IRQ
>   static void rtc_dropped_irq(unsigned long data);
>   
> -static DEFINE_TIMER(rtc_irq_timer, rtc_dropped_irq, 0, 0);
> +static DEFINE_TIMER(rtc_irq_timer, rtc_dropped_irq);
>   #endif
>   
>   static ssize_t rtc_read(struct file *file, char __user *buf,
> diff --git a/drivers/input/touchscreen/s3c2410_ts.c b/drivers/input/touchscreen/s3c2410_ts.c
> index 3b3db8c868e0..d3265b6b58b8 100644
> --- a/drivers/input/touchscreen/s3c2410_ts.c
> +++ b/drivers/input/touchscreen/s3c2410_ts.c
> @@ -145,7 +145,7 @@ static void touch_timer_fire(unsigned long data)
>   	}
>   }
>   
> -static DEFINE_TIMER(touch_timer, touch_timer_fire, 0, 0);
> +static DEFINE_TIMER(touch_timer, touch_timer_fire);
>   
>   /**
>    * stylus_irq - touchscreen stylus event interrupt
> diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
> index 017f48cdcab9..1fcc86fa4e05 100644
> --- a/drivers/net/cris/eth_v10.c
> +++ b/drivers/net/cris/eth_v10.c
> @@ -165,8 +165,8 @@ static unsigned int network_rec_config_shadow = 0;
>   static unsigned int network_tr_ctrl_shadow = 0;
>   
>   /* Network speed indication. */
> -static DEFINE_TIMER(speed_timer, NULL, 0, 0);
> -static DEFINE_TIMER(clear_led_timer, NULL, 0, 0);
> +static DEFINE_TIMER(speed_timer, NULL);
> +static DEFINE_TIMER(clear_led_timer, NULL);
>   static int current_speed; /* Speed read from transceiver */
>   static int current_speed_selection; /* Speed selected by user */
>   static unsigned long led_next_time;
> @@ -174,7 +174,7 @@ static int led_active;
>   static int rx_queue_len;
>   
>   /* Duplex */
> -static DEFINE_TIMER(duplex_timer, NULL, 0, 0);
> +static DEFINE_TIMER(duplex_timer, NULL);
>   static int full_duplex;
>   static enum duplex current_duplex;
>   
> diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
> index 7a7c5224a336..104f71fa9c5e 100644
> --- a/drivers/net/hamradio/yam.c
> +++ b/drivers/net/hamradio/yam.c
> @@ -157,7 +157,7 @@ static struct net_device *yam_devs[NR_PORTS];
>   
>   static struct yam_mcs *yam_data;
>   
> -static DEFINE_TIMER(yam_timer, NULL, 0, 0);
> +static DEFINE_TIMER(yam_timer, NULL);
>   
>   /* --------------------------------------------------------------------- */
>   
> diff --git a/drivers/net/wireless/atmel/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
> index 94bf01f8b2a8..ede89d4ffc88 100644
> --- a/drivers/net/wireless/atmel/at76c50x-usb.c
> +++ b/drivers/net/wireless/atmel/at76c50x-usb.c
> @@ -519,7 +519,7 @@ static int at76_usbdfu_download(struct usb_device *udev, u8 *buf, u32 size,
>   /* LED trigger */
>   static int tx_activity;
>   static void at76_ledtrig_tx_timerfunc(unsigned long data);
> -static DEFINE_TIMER(ledtrig_tx_timer, at76_ledtrig_tx_timerfunc, 0, 0);
> +static DEFINE_TIMER(ledtrig_tx_timer, at76_ledtrig_tx_timerfunc);
>   DEFINE_LED_TRIGGER(ledtrig_tx);
>   
>   static void at76_ledtrig_tx_timerfunc(unsigned long data)
> diff --git a/drivers/staging/speakup/main.c b/drivers/staging/speakup/main.c
> index 67956e24779c..b61e9becb612 100644
> --- a/drivers/staging/speakup/main.c
> +++ b/drivers/staging/speakup/main.c
> @@ -1165,7 +1165,7 @@ static const int NUM_CTL_LABELS = (MSG_CTL_END - MSG_CTL_START + 1);
>   
>   static void read_all_doc(struct vc_data *vc);
>   static void cursor_done(u_long data);
> -static DEFINE_TIMER(cursor_timer, cursor_done, 0, 0);
> +static DEFINE_TIMER(cursor_timer, cursor_done);
>   
>   static void do_handle_shift(struct vc_data *vc, u_char value, char up_flag)
>   {
> diff --git a/drivers/staging/speakup/synth.c b/drivers/staging/speakup/synth.c
> index a1ca68c76579..6ddd3fc3f08d 100644
> --- a/drivers/staging/speakup/synth.c
> +++ b/drivers/staging/speakup/synth.c
> @@ -158,7 +158,7 @@ static void thread_wake_up(u_long data)
>   	wake_up_interruptible_all(&speakup_event);
>   }
>   
> -static DEFINE_TIMER(thread_timer, thread_wake_up, 0, 0);
> +static DEFINE_TIMER(thread_timer, thread_wake_up);
>   
>   void synth_start(void)
>   {
> diff --git a/drivers/tty/cyclades.c b/drivers/tty/cyclades.c
> index d272bc4e7fb5..dac8a1a8e4ac 100644
> --- a/drivers/tty/cyclades.c
> +++ b/drivers/tty/cyclades.c
> @@ -283,7 +283,7 @@ static void cyz_poll(unsigned long);
>   /* The Cyclades-Z polling cycle is defined by this variable */
>   static long cyz_polling_cycle = CZ_DEF_POLL;
>   
> -static DEFINE_TIMER(cyz_timerlist, cyz_poll, 0, 0);
> +static DEFINE_TIMER(cyz_timerlist, cyz_poll);
>   
>   #else				/* CONFIG_CYZ_INTR */
>   static void cyz_rx_restart(unsigned long);
> diff --git a/drivers/tty/isicom.c b/drivers/tty/isicom.c
> index 61ecdd6b2fc2..40af32108ff5 100644
> --- a/drivers/tty/isicom.c
> +++ b/drivers/tty/isicom.c
> @@ -177,7 +177,7 @@ static struct tty_driver *isicom_normal;
>   static void isicom_tx(unsigned long _data);
>   static void isicom_start(struct tty_struct *tty);
>   
> -static DEFINE_TIMER(tx, isicom_tx, 0, 0);
> +static DEFINE_TIMER(tx, isicom_tx);
>   
>   /*   baud index mappings from linux defns to isi */
>   
> diff --git a/drivers/tty/moxa.c b/drivers/tty/moxa.c
> index 7f3d4cb0341b..93d37655d928 100644
> --- a/drivers/tty/moxa.c
> +++ b/drivers/tty/moxa.c
> @@ -428,7 +428,7 @@ static const struct tty_port_operations moxa_port_ops = {
>   };
>   
>   static struct tty_driver *moxaDriver;
> -static DEFINE_TIMER(moxaTimer, moxa_poll, 0, 0);
> +static DEFINE_TIMER(moxaTimer, moxa_poll);
>   
>   /*
>    * HW init
> diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
> index 20d79a6007d5..aa695fda1084 100644
> --- a/drivers/tty/rocket.c
> +++ b/drivers/tty/rocket.c
> @@ -111,7 +111,7 @@ static struct r_port *rp_table[MAX_RP_PORTS];	       /*  The main repository of
>   static unsigned int xmit_flags[NUM_BOARDS];	       /*  Bit significant, indicates port had data to transmit. */
>   						       /*  eg.  Bit 0 indicates port 0 has xmit data, ...        */
>   static atomic_t rp_num_ports_open;	               /*  Number of serial ports open                           */
> -static DEFINE_TIMER(rocket_timer, rp_do_poll, 0, 0);
> +static DEFINE_TIMER(rocket_timer, rp_do_poll);
>   
>   static unsigned long board1;	                       /* ISA addresses, retrieved from rocketport.conf          */
>   static unsigned long board2;
> diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
> index f4166263bb3a..f974d6340d04 100644
> --- a/drivers/tty/vt/keyboard.c
> +++ b/drivers/tty/vt/keyboard.c
> @@ -250,7 +250,7 @@ static void kd_nosound(unsigned long ignored)
>   	input_handler_for_each_handle(&kbd_handler, &zero, kd_sound_helper);
>   }
>   
> -static DEFINE_TIMER(kd_mksound_timer, kd_nosound, 0, 0);
> +static DEFINE_TIMER(kd_mksound_timer, kd_nosound);
>   
>   void kd_mksound(unsigned int hz, unsigned int ticks)
>   {
> diff --git a/drivers/tty/vt/vt.c b/drivers/tty/vt/vt.c
> index 2ebaba16f785..602d71630952 100644
> --- a/drivers/tty/vt/vt.c
> +++ b/drivers/tty/vt/vt.c
> @@ -228,7 +228,7 @@ static int scrollback_delta;
>    */
>   int (*console_blank_hook)(int);
>   
> -static DEFINE_TIMER(console_timer, blank_screen_t, 0, 0);
> +static DEFINE_TIMER(console_timer, blank_screen_t);
>   static int blank_state;
>   static int blank_timer_expired;
>   enum {
> diff --git a/drivers/watchdog/alim7101_wdt.c b/drivers/watchdog/alim7101_wdt.c
> index 3c1f6ac68ea9..18e896eeca62 100644
> --- a/drivers/watchdog/alim7101_wdt.c
> +++ b/drivers/watchdog/alim7101_wdt.c
> @@ -71,7 +71,7 @@ MODULE_PARM_DESC(use_gpio,
>   		"Use the gpio watchdog (required by old cobalt boards).");
>   
>   static void wdt_timer_ping(unsigned long);
> -static DEFINE_TIMER(timer, wdt_timer_ping, 0, 0);
> +static DEFINE_TIMER(timer, wdt_timer_ping);
>   static unsigned long next_heartbeat;
>   static unsigned long wdt_is_open;
>   static char wdt_expect_close;
> diff --git a/drivers/watchdog/machzwd.c b/drivers/watchdog/machzwd.c
> index 9826b59ef734..8a616a57bb90 100644
> --- a/drivers/watchdog/machzwd.c
> +++ b/drivers/watchdog/machzwd.c
> @@ -127,7 +127,7 @@ static int zf_action = GEN_RESET;
>   static unsigned long zf_is_open;
>   static char zf_expect_close;
>   static DEFINE_SPINLOCK(zf_port_lock);
> -static DEFINE_TIMER(zf_timer, zf_ping, 0, 0);
> +static DEFINE_TIMER(zf_timer, zf_ping);
>   static unsigned long next_heartbeat;
>   
>   
> diff --git a/drivers/watchdog/mixcomwd.c b/drivers/watchdog/mixcomwd.c
> index be86ea359eee..c9e38096ea91 100644
> --- a/drivers/watchdog/mixcomwd.c
> +++ b/drivers/watchdog/mixcomwd.c
> @@ -105,7 +105,7 @@ static unsigned long mixcomwd_opened; /* long req'd for setbit --RR */
>   
>   static int watchdog_port;
>   static int mixcomwd_timer_alive;
> -static DEFINE_TIMER(mixcomwd_timer, mixcomwd_timerfun, 0, 0);
> +static DEFINE_TIMER(mixcomwd_timer, mixcomwd_timerfun);
>   static char expect_close;
>   
>   static bool nowayout = WATCHDOG_NOWAYOUT;
> diff --git a/drivers/watchdog/sbc60xxwdt.c b/drivers/watchdog/sbc60xxwdt.c
> index 2eef58a0cf05..8d589939bc84 100644
> --- a/drivers/watchdog/sbc60xxwdt.c
> +++ b/drivers/watchdog/sbc60xxwdt.c
> @@ -113,7 +113,7 @@ MODULE_PARM_DESC(nowayout,
>   				__MODULE_STRING(WATCHDOG_NOWAYOUT) ")");
>   
>   static void wdt_timer_ping(unsigned long);
> -static DEFINE_TIMER(timer, wdt_timer_ping, 0, 0);
> +static DEFINE_TIMER(timer, wdt_timer_ping);
>   static unsigned long next_heartbeat;
>   static unsigned long wdt_is_open;
>   static char wdt_expect_close;
> diff --git a/drivers/watchdog/sc520_wdt.c b/drivers/watchdog/sc520_wdt.c
> index 1cfd3f6a13d5..3e9bbaa37bf4 100644
> --- a/drivers/watchdog/sc520_wdt.c
> +++ b/drivers/watchdog/sc520_wdt.c
> @@ -124,7 +124,7 @@ MODULE_PARM_DESC(nowayout,
>   static __u16 __iomem *wdtmrctl;
>   
>   static void wdt_timer_ping(unsigned long);
> -static DEFINE_TIMER(timer, wdt_timer_ping, 0, 0);
> +static DEFINE_TIMER(timer, wdt_timer_ping);
>   static unsigned long next_heartbeat;
>   static unsigned long wdt_is_open;
>   static char wdt_expect_close;
> diff --git a/drivers/watchdog/via_wdt.c b/drivers/watchdog/via_wdt.c
> index 5f9cbc37520d..ad3c3be13b40 100644
> --- a/drivers/watchdog/via_wdt.c
> +++ b/drivers/watchdog/via_wdt.c
> @@ -68,7 +68,7 @@ static struct resource wdt_res;
>   static void __iomem *wdt_mem;
>   static unsigned int mmio;
>   static void wdt_timer_tick(unsigned long data);
> -static DEFINE_TIMER(timer, wdt_timer_tick, 0, 0);
> +static DEFINE_TIMER(timer, wdt_timer_tick);
>   					/* The timer that pings the watchdog */
>   static unsigned long next_heartbeat;	/* the next_heartbeat for the timer */
>   
> diff --git a/drivers/watchdog/w83877f_wdt.c b/drivers/watchdog/w83877f_wdt.c
> index f0483c75ed32..ba6b680af100 100644
> --- a/drivers/watchdog/w83877f_wdt.c
> +++ b/drivers/watchdog/w83877f_wdt.c
> @@ -98,7 +98,7 @@ MODULE_PARM_DESC(nowayout,
>   				__MODULE_STRING(WATCHDOG_NOWAYOUT) ")");
>   
>   static void wdt_timer_ping(unsigned long);
> -static DEFINE_TIMER(timer, wdt_timer_ping, 0, 0);
> +static DEFINE_TIMER(timer, wdt_timer_ping);
>   static unsigned long next_heartbeat;
>   static unsigned long wdt_is_open;
>   static char wdt_expect_close;
> diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
> index 2c6a9114d332..a8721d718186 100644
> --- a/drivers/xen/grant-table.c
> +++ b/drivers/xen/grant-table.c
> @@ -305,7 +305,7 @@ struct deferred_entry {
>   };
>   static LIST_HEAD(deferred_list);
>   static void gnttab_handle_deferred(unsigned long);
> -static DEFINE_TIMER(deferred_timer, gnttab_handle_deferred, 0, 0);
> +static DEFINE_TIMER(deferred_timer, gnttab_handle_deferred);
>   
>   static void gnttab_handle_deferred(unsigned long unused)
>   {
> diff --git a/fs/pstore/platform.c b/fs/pstore/platform.c
> index 2b21d180157c..ec7199e859d2 100644
> --- a/fs/pstore/platform.c
> +++ b/fs/pstore/platform.c
> @@ -62,7 +62,7 @@ MODULE_PARM_DESC(update_ms, "milliseconds before pstore updates its content "
>   static int pstore_new_entry;
>   
>   static void pstore_timefunc(unsigned long);
> -static DEFINE_TIMER(pstore_timer, pstore_timefunc, 0, 0);
> +static DEFINE_TIMER(pstore_timer, pstore_timefunc);
>   
>   static void pstore_dowork(struct work_struct *);
>   static DECLARE_WORK(pstore_work, pstore_dowork);
> diff --git a/include/linux/timer.h b/include/linux/timer.h
> index a33220311361..91e5a2cc81b5 100644
> --- a/include/linux/timer.h
> +++ b/include/linux/timer.h
> @@ -73,9 +73,9 @@ struct timer_list {
>   			__FILE__ ":" __stringify(__LINE__))	\
>   	}
>   
> -#define DEFINE_TIMER(_name, _function, _expires, _data)		\
> +#define DEFINE_TIMER(_name, _function)				\
>   	struct timer_list _name =				\
> -		__TIMER_INITIALIZER(_function, _expires, _data, 0)
> +		__TIMER_INITIALIZER(_function, 0, 0, 0)
>   
>   void init_timer_key(struct timer_list *timer, unsigned int flags,
>   		    const char *name, struct lock_class_key *key);
> diff --git a/kernel/irq/spurious.c b/kernel/irq/spurious.c
> index 061ba7eed4ed..c805e8691c22 100644
> --- a/kernel/irq/spurious.c
> +++ b/kernel/irq/spurious.c
> @@ -20,7 +20,7 @@ static int irqfixup __read_mostly;
>   
>   #define POLL_SPURIOUS_IRQ_INTERVAL (HZ/10)
>   static void poll_spurious_irqs(unsigned long dummy);
> -static DEFINE_TIMER(poll_spurious_irq_timer, poll_spurious_irqs, 0, 0);
> +static DEFINE_TIMER(poll_spurious_irq_timer, poll_spurious_irqs);
>   static int irq_poll_cpu;
>   static atomic_t irq_poll_active;
>   
> diff --git a/lib/random32.c b/lib/random32.c
> index fa594b1140e6..6e91b75c113f 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> @@ -214,7 +214,7 @@ core_initcall(prandom_init);
>   
>   static void __prandom_timer(unsigned long dontcare);
>   
> -static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
> +static DEFINE_TIMER(seed_timer, __prandom_timer);
>   
>   static void __prandom_timer(unsigned long dontcare)
>   {
> diff --git a/net/atm/mpc.c b/net/atm/mpc.c
> index 5677147209e8..63138c8c2269 100644
> --- a/net/atm/mpc.c
> +++ b/net/atm/mpc.c
> @@ -121,7 +121,7 @@ static struct notifier_block mpoa_notifier = {
>   
>   struct mpoa_client *mpcs = NULL; /* FIXME */
>   static struct atm_mpoa_qos *qos_head = NULL;
> -static DEFINE_TIMER(mpc_timer, NULL, 0, 0);
> +static DEFINE_TIMER(mpc_timer, NULL);
>   
>   
>   static struct mpoa_client *find_mpc_by_itfnum(int itf)
> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index 0bd3afd01dd2..6538632fbd03 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -131,7 +131,7 @@ static struct dn_rt_hash_bucket *dn_rt_hash_table;
>   static unsigned int dn_rt_hash_mask;
>   
>   static struct timer_list dn_route_timer;
> -static DEFINE_TIMER(dn_rt_flush_timer, dn_run_flush, 0, 0);
> +static DEFINE_TIMER(dn_rt_flush_timer, dn_run_flush);
>   int decnet_dst_gc_interval = 2;
>   
>   static struct dst_ops dn_dst_ops = {
> diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> index 8081bafe441b..b39d0908be2e 100644
> --- a/net/ipv6/ip6_flowlabel.c
> +++ b/net/ipv6/ip6_flowlabel.c
> @@ -47,7 +47,7 @@ static atomic_t fl_size = ATOMIC_INIT(0);
>   static struct ip6_flowlabel __rcu *fl_ht[FL_HASH_MASK+1];
>   
>   static void ip6_fl_gc(unsigned long dummy);
> -static DEFINE_TIMER(ip6_fl_gc_timer, ip6_fl_gc, 0, 0);
> +static DEFINE_TIMER(ip6_fl_gc_timer, ip6_fl_gc);
>   
>   /* FL hash table lock: it protects only of GC */
>   
> diff --git a/net/netrom/nr_loopback.c b/net/netrom/nr_loopback.c
> index 94d4e922af53..989ae647825e 100644
> --- a/net/netrom/nr_loopback.c
> +++ b/net/netrom/nr_loopback.c
> @@ -18,7 +18,7 @@
>   static void nr_loopback_timer(unsigned long);
>   
>   static struct sk_buff_head loopback_queue;
> -static DEFINE_TIMER(loopback_timer, nr_loopback_timer, 0, 0);
> +static DEFINE_TIMER(loopback_timer, nr_loopback_timer);
>   
>   void __init nr_loopback_init(void)
>   {
> diff --git a/security/keys/gc.c b/security/keys/gc.c
> index 87cb260e4890..8673f7f58ead 100644
> --- a/security/keys/gc.c
> +++ b/security/keys/gc.c
> @@ -30,7 +30,7 @@ DECLARE_WORK(key_gc_work, key_garbage_collector);
>    * Reaper for links from keyrings to dead keys.
>    */
>   static void key_gc_timer_func(unsigned long);
> -static DEFINE_TIMER(key_gc_timer, key_gc_timer_func, 0, 0);
> +static DEFINE_TIMER(key_gc_timer, key_gc_timer_func);
>   
>   static time_t key_gc_next_run = LONG_MAX;
>   static struct key_type *key_gc_dead_keytype;
> diff --git a/sound/oss/midibuf.c b/sound/oss/midibuf.c
> index 701c7625c971..1277df815d5b 100644
> --- a/sound/oss/midibuf.c
> +++ b/sound/oss/midibuf.c
> @@ -52,7 +52,7 @@ static struct midi_parms parms[MAX_MIDI_DEV];
>   static void midi_poll(unsigned long dummy);
>   
>   
> -static DEFINE_TIMER(poll_timer, midi_poll, 0, 0);
> +static DEFINE_TIMER(poll_timer, midi_poll);
>   
>   static volatile int open_devs;
>   static DEFINE_SPINLOCK(lock);
> diff --git a/sound/oss/soundcard.c b/sound/oss/soundcard.c
> index b70c7c8f9c5d..4391062e5cfd 100644
> --- a/sound/oss/soundcard.c
> +++ b/sound/oss/soundcard.c
> @@ -662,7 +662,7 @@ static void do_sequencer_timer(unsigned long dummy)
>   }
>   
>   
> -static DEFINE_TIMER(seq_timer, do_sequencer_timer, 0, 0);
> +static DEFINE_TIMER(seq_timer, do_sequencer_timer);
>   
>   void request_sound_timer(int count)
>   {
> diff --git a/sound/oss/sys_timer.c b/sound/oss/sys_timer.c
> index d17019d25b99..8a4b5625dba6 100644
> --- a/sound/oss/sys_timer.c
> +++ b/sound/oss/sys_timer.c
> @@ -28,7 +28,7 @@ static unsigned long prev_event_time;
>   
>   static void     poll_def_tmr(unsigned long dummy);
>   static DEFINE_SPINLOCK(lock);
> -static DEFINE_TIMER(def_tmr, poll_def_tmr, 0, 0);
> +static DEFINE_TIMER(def_tmr, poll_def_tmr);
>   
>   static unsigned long
>   tmr2ticks(int tmr_value)
> diff --git a/sound/oss/uart6850.c b/sound/oss/uart6850.c
> index eda32d7eddbd..a9d3f7568525 100644
> --- a/sound/oss/uart6850.c
> +++ b/sound/oss/uart6850.c
> @@ -78,7 +78,7 @@ static void (*midi_input_intr) (int dev, unsigned char data);
>   static void poll_uart6850(unsigned long dummy);
>   
>   
> -static DEFINE_TIMER(uart6850_timer, poll_uart6850, 0, 0);
> +static DEFINE_TIMER(uart6850_timer, poll_uart6850);
>   
>   static void uart6850_input_loop(void)
>   {
> 
