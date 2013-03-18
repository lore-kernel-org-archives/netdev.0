From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Mon, 18 Mar 2013 14:03:08 -0700
Message-ID: <20130318210308.GD32416@pogo>
References: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com>
 <20130318191340.GA28919@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@venema.h4ckr.net>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<senthilb@qca.qualcomm.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130318191340.GA28919@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 03:13:41PM -0400, John W. Linville wrote:
> Any comments from the ath9k folks?
> 
> On Sat, Mar 16, 2013 at 12:38:14PM -0400, Parag Warudkar wrote:
> > During suspend below warning is seen when ath9k is active.  Attached
> > patch fixes the warning for me. Tested to work across few
> > suspend-resume cycles.
> > 
> > 
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642939] WARNING: at
> > net/mac80211/util.c:599 ieee80211_can_queue_work.isra.7+0x32/0x40
> > [mac80211]()
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642940] Hardware name: iMac12,1
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642941] queueing ieee80211
> > work while going to suspend
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642972] Modules linked in:
> > joydev hid_logitech_dj zfs(POF) bridge stp llc zunicode(POF) zavl(POF)
> > zcommon(POF) znvpair(POF) spl(OF) zlib_deflate be2iscsi
> > iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio
> > libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core
> > iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi rfcomm bnep
> > nls_utf8 hfsplus btusb uvcvideo videobuf2_vmalloc videobuf2_memops
> > videobuf2_core videodev bluetooth media coretemp snd_hda_codec_hdmi
> > snd_hda_codec_cirrus snd_hda_intel snd_hda_codec snd_hwdep snd_seq
> > snd_seq_device snd_pcm snd_page_alloc snd_timer snd soundcore arc4
> > ath9k ath9k_common microcode ath9k_hw ath mac80211 iTCO_wdt
> > iTCO_vendor_support cfg80211 lpc_ich mei mfd_core rfkill i2c_i801
> > applesmc apple_bl input_polldev vhost_net tun macvtap macvlan
> > kvm_intel kvm binfmt_misc uinput usb_storage crc32c_intel radeon ttm
> > i915 ghash_clmulni_intel firewire_ohci firewire_core i2c_algo_bit
> > drm_kms_helper crc_itu_t drm tg3 ptp pps_core i2c_core video sunrpc
> > [last unloaded: iptable_mangle]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642985] Pid: 0, comm:
> > swapper/0 Tainted: PF          O 3.8.2-206.fc18.x86_64 #1
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642986] Call Trace:
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642992]  <IRQ>
> > [<ffffffff8105e61f>] warn_slowpath_common+0x7f/0xc0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643009]
> > [<ffffffffa0581420>] ? ath_start_rx_poll+0x70/0x70 [ath9k]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643011]
> > [<ffffffff8105e716>] warn_slowpath_fmt+0x46/0x50
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643018]
> > [<ffffffffa045b542>] ieee80211_can_queue_work.isra.7+0x32/0x40
> > [mac80211]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643024]
> > [<ffffffffa045b5de>] ieee80211_queue_work+0x2e/0x50 [mac80211]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643027]
> > [<ffffffffa0581438>] ath_rx_poll+0x18/0x20 [ath9k]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643029]
> > [<ffffffff8106d0aa>] call_timer_fn+0x3a/0x120
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643032]
> > [<ffffffffa0581420>] ? ath_start_rx_poll+0x70/0x70 [ath9k]
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643034]
> > [<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643035]
> > [<ffffffff8106ee3e>] run_timer_softirq+0x1fe/0x2b0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643037]
> > [<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643038]
> > [<ffffffff81066cd0>] __do_softirq+0xd0/0x210
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643040]
> > [<ffffffff8101b913>] ? native_sched_clock+0x13/0x80
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643041]
> > [<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643043]
> > [<ffffffff8165985c>] call_softirq+0x1c/0x30
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643045]
> > [<ffffffff810162a5>] do_softirq+0x75/0xb0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643046]
> > [<ffffffff81066fa5>] irq_exit+0xb5/0xc0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643048]
> > [<ffffffff8165a1de>] smp_apic_timer_interrupt+0x6e/0x99
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643049]
> > [<ffffffff8165911d>] apic_timer_interrupt+0x6d/0x80
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643052]  <EOI>
> > [<ffffffff810868ce>] ? __hrtimer_start_range_ns+0x1be/0x400
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643053]
> > [<ffffffff814fbc30>] ? cpuidle_wrap_enter+0x50/0xa0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643054]
> > [<ffffffff814fbc29>] ? cpuidle_wrap_enter+0x49/0xa0
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643056]
> > [<ffffffff814fbc90>] cpuidle_enter_tk+0x10/0x20
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643057]
> > [<ffffffff814fb8c9>] cpuidle_idle_call+0xa9/0x260
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643058]
> > [<ffffffff8101d45f>] cpu_idle+0xaf/0x120
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643061]
> > [<ffffffff81634522>] rest_init+0x72/0x80
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643063]
> > [<ffffffff81d00c40>] start_kernel+0x3d1/0x3de
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643065]
> > [<ffffffff81d0066e>] ? repair_env_string+0x5e/0x5e
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643066]
> > [<ffffffff81d00356>] x86_64_start_reservations+0x131/0x135
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643068]
> > [<ffffffff81d0045a>] x86_64_start_kernel+0x100/0x10f
> > Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643068] ---[ end trace
> > 5595a7f5dd9a2949 ]---
> > 
> > Signed-off-by: Parag Warudkar <parag.lkml@gmail.com>
> > 
> > diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h
> > b/drivers/net/wireless/ath/ath9k/ath9k.h
> > index a56b241..b3088a1 100644
> > --- a/drivers/net/wireless/ath/ath9k/ath9k.h
> > +++ b/drivers/net/wireless/ath/ath9k/ath9k.h
> > @@ -764,6 +764,7 @@ struct ath_softc {
> >   atomic_t wow_got_bmiss_intr;
> >   atomic_t wow_sleep_proc_intr; /* in the middle of WoW sleep ? */
> >   u32 wow_intr_before_sleep;
> > + bool suspending;
> >  #endif
> >  };
> > 
> > diff --git a/drivers/net/wireless/ath/ath9k/link.c
> > b/drivers/net/wireless/ath/ath9k/link.c
> > index ade3afb..fa77e19 100644
> > --- a/drivers/net/wireless/ath/ath9k/link.c
> > +++ b/drivers/net/wireless/ath/ath9k/link.c
> > @@ -158,7 +158,8 @@ void ath_start_rx_poll(struct ath_softc *sc, u8 nbeacon)
> >  {
> >   if (!AR_SREV_9300(sc->sc_ah))
> >   return;
> > -
> > + if (sc->suspending)
> > + return;

Thanks for the patch! Please note the style issue here, you should
use a tab, but other than that lets review what happened.

> >   if (!test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags))
> >   return;

Note that what this will do is call later mod_timer() for
rx_poll_timer, the right thing to do then, which would
be equivalent to your patch is to modify the ath_start_rx_poll()
to instead use the new API mod_timer_pending() added on v2.6.30
via commit 74019224. This would not re-arm the timer if it was
previously removed.

commit 74019224ac34b044b44a31dd89a54e3477db4896
Author: Ingo Molnar <mingo@elte.hu>
Date:   Wed Feb 18 12:23:29 2009 +0100

    timers: add mod_timer_pending()
    
    Impact: new timer API
    
    Based on an idea from Martin Josefsson with the help of
    Patrick McHardy and Stephen Hemminger:
    
    introduce the mod_timer_pending() API which is a mod_timer()
    offspring that is an invariant on already removed timers.
    
    (regular mod_timer() re-activates non-pending timers.)
    
    This is useful for the networking code in that it can
    allow unserialized mod_timer_pending() timer-forwarding
    calls, but a single del_timer*() will stop the timer
    from being reactivated again.
    
    Also while at it:
    
    - optimize the regular mod_timer() path some more, the
      timer-stat and a debug check was needlessly duplicated
      in __mod_timer().
    
    - make the exports come straight after the function, as
      most other exports in timer.c already did.
    
    - eliminate __mod_timer() as an external API, change the
      users to mod_timer().
    
    The regular mod_timer() code path is not impacted
    significantly, due to inlining optimizations and due to
    the simplifications.
    
    Based-on-patch-from: Stephen Hemminger <shemminger@vyatta.com>
    Acked-by: Stephen Hemminger <shemminger@vyatta.com>
    Cc: "David S. Miller" <davem@davemloft.net>
    Cc: Patrick McHardy <kaber@trash.net>
    Cc: netdev@vger.kernel.org
    Cc: Oleg Nesterov <oleg@redhat.com>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

> > 
> > diff --git a/drivers/net/wireless/ath/ath9k/main.c
> > b/drivers/net/wireless/ath/ath9k/main.c
> > index 6e66f9c..0cf88b7 100644
> > --- a/drivers/net/wireless/ath/ath9k/main.c
> > +++ b/drivers/net/wireless/ath/ath9k/main.c
> > @@ -2150,7 +2150,7 @@ static int ath9k_suspend(struct ieee80211_hw *hw,
> >   int ret = 0;
> > 
> >   mutex_lock(&sc->mutex);
> > -
> > + sc->suspending = 1;
> >   ath_cancel_work(sc);
> >   ath_stop_ani(sc);
> >   del_timer_sync(&sc->rx_poll_timer);

See here we use del_timer_sync().

Can you try this instead for example:

diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/ath/ath9k/link.c
index ade3afb..fbd8b4c 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -162,8 +162,8 @@ void ath_start_rx_poll(struct ath_softc *sc, u8 nbeacon)
 	if (!test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags))
 		return;
 
-	mod_timer(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
-		  (nbeacon * sc->cur_beacon_conf.beacon_interval));
+	mod_timer_pending(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
+			  (nbeacon * sc->cur_beacon_conf.beacon_interval));
 }
 
 void ath_rx_poll(unsigned long data)

Looking at this makes me think we should review all usage of
mod_timer all over our 802.11 drivers, and mac80211, cfg80211 as
well.

  Luis
