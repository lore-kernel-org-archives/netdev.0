From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: minstrel_tx_status mac80211 WARNINGs in vanilla 2.6.34.1
Date: Thu, 22 Jul 2010 21:07:01 +0200
Message-ID: <4C4896D5.8010802@openwrt.org>
References: <20100722123000.GA16657@geggus.net> <20100722144723.GA2616@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sven Geggus <sven-jQqlrKAAsj0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100722144723.GA2616-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-07-22 4:47 PM, John W. Linville wrote:
> On Thu, Jul 22, 2010 at 02:30:01PM +0200, Sven Geggus wrote:
>> Hello,
>> 
>> running vanilla 2.6.34.1 I get the following warnings in  kernel log:
>> 
>> WARNING: at net/mac80211/rc80211_minstrel.c:70 minstrel_tx_status+0x67/0xd1 [mac80211]()
>> Hardware name: SCENIC E300/E600
>> Modules linked in: i915 drm_kms_helper drm video backlight output lp loop
>> snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
>> snd_seq_dummy zd1211rw snd_seq_oss usbhid mac80211 option cfg80211
>> snd_seq_midi usbserial snd_rawmidi snd_seq_midi_event snd_seq snd_timer
>> snd_seq_device snd parport_pc ehci_hcd uhci_hcd soundcore intel_agp parport
>> usbcore nls_base snd_page_alloc agpgart rng_core floppy sg
>> Pid: 0, comm: swapper Tainted: G        W  2.6.34.1 #3
>> Call Trace:
>>  [<c102af25>] warn_slowpath_common+0x60/0x90
>>  [<c102af62>] warn_slowpath_null+0xd/0x10
>>  [<f83cbd48>] minstrel_tx_status+0x67/0xd1 [mac80211]
>>  [<f83b6eb1>] ieee80211_tx_status+0x1f6/0x5ac [mac80211]
>>  [<c1261533>] ? skb_dequeue+0x45/0x4c
>>  [<f83b6896>] ieee80211_tasklet_handler+0x61/0xd6 [mac80211]
>>  [<c102ed7d>] tasklet_action+0x62/0x9f
>>  [<c102f331>] __do_softirq+0x77/0xe5
>>  [<c102f3c5>] do_softirq+0x26/0x2b
>>  [<c102f52f>] irq_exit+0x29/0x66
>>  [<c1003e90>] do_IRQ+0x85/0x9b
>>  [<c1002d29>] common_interrupt+0x29/0x30
>>  [<c10083ac>] ? default_idle+0x2d/0x42
>>  [<c1001a9b>] cpu_idle+0x44/0x71
>>  [<c12e00de>] rest_init+0x96/0x98
>>  [<c1498862>] start_kernel+0x2a5/0x2aa
>>  [<c14980b7>] i386_start_kernel+0xb7/0xbf
>> ---[ end trace f22ceacef336878f ]---
>> 
>> Wireless driver is zd1211rw.
>> 
>> Did not test with older kernel because this device has not been in user on
>> this machine before.
>> 
>> WLAN does however seem to work anyway.
> 
> Well, I just took a quick look -- so, I'm not 100% sure...
> 
> But, it looks to me like zd1211rw is reporting tx status on a rate
> that minstrel didn't expect it to use.  It seems like the hardware
> is pre-wired to do retries on sequentially lower rates, which seems
> a bit incompatible with minstrel's worldview.
> 
> Felix, can we accomodate this?  The "WLAN does however seem to work
> anyway" seems to suggest things work, so can we at least not yell
> about it?
I think we should just drop that WARN_ON(). It's not problematic if
minstrel gets feedback for rates that it doesn't have in its list, it
should just ignore it.

- Felix
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
