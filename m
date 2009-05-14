From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Thu, 14 May 2009 20:37:56 +0200
Message-ID: <4A0C6504.8000704@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de>	 <1242001754.4093.12.camel@obelisk.thedillows.org>	 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>	 <1242077392.3716.15.camel@lap75545.ornl.gov>	 <4A09DC3E.2080807@googlemail.com> <1242268709.4979.7.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:36548 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbZENSiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 14:38:00 -0400
In-Reply-To: <1242268709.4979.7.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Dillow wrote:
> On Tue, 2009-05-12 at 22:29 +0200, Michael Riepe wrote:
> 
>>Hi!
>>
>>David Dillow wrote:
>>
>>
>>>I was saying that I don't think the timeouts are necessarily the NIC
>>>chipset -- or the bridge chip for that matter --  having issues with
>>>MSI. There were some substantial IRQ handling changes in 2.6.28 and my
>>>bisection of the problem seem to lead into that code. I'll try this
>>>later tonight hopefully, but can you try to run 2.6.27 with the current
>>>r8169 driver and see if it is solid for you? That way it is using the
>>>same driver code, but avoids the IRQ changes.
>>
>>Unfortunately, 2.6.27 won't build with r8169.c copied from 2.6.29.
> 
> 
> You are correct, and I should have thought about that. The following
> patch reverts the following commits:
> 
> 288379 net: Remove redundant NAPI functions
> 908a7a net: Remove unused netdev arg from some NAPI interfaces.
> 008298 netdev: add more functions to netdevice ops
> 8b4ab2 r8169: convert to net_device_ops
> babcda drivers/net: Kill now superfluous ->last_rx stores.
> 
> The patched driver runs on 2.6.27 and survives my 5 minutes 'dd
> if=/dev/zero bs=1024k | nc target 9000' test which usually dies in less
> than 90 seconds on 2.6.28+.

Not on my system:

WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x258/0x270()
NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Modules linked in: nfsd lockd nfs_acl sunrpc exportfs autofs4 deflate
zlib_deflate ctr twofish twofish_common camellia serpent blowfish
des_generic cbc aes_x86_64 aes_generic xcbc rmd160 sha256_generic
sha1_generic crypto_null crypto_blkcipher af_key ipt_REJECT
nf_conntrack_ipv6 ip6table_filter ip6_tables xt_tcpudp xt_conntrack
iptable_filter ip_tables x_tables sg nf_conntrack_irc nf_conntrack_ftp
nf_conntrack_ipv4 nf_conntrack rfcomm l2cap bluetooth dm_mod tun eeprom
smsc47m192 hwmon_vid smsc47m1 hwmon cpufreq_stats cpufreq_powersave
video backlight output fan container battery ac usbhid usb_storage
i2c_dev hid evdev intelfb fb i2c_algo_bit ff_memless parport_pc
cfbcopyarea r8169 snd_hda_intel i2c_i801 thermal cfbimgblt serio_raw
ehci_hcd mii button iTCO_wdt snd_pcm processor parport i2c_core
cfbfillrect intel_agp snd_timer snd_page_alloc snd_hwdep snd uhci_hcd
soundcore
Pid: 0, comm: swapper Not tainted 2.6.27-ai-x64-r8169 #1

Call Trace:
 <IRQ>  [<ffffffff802498f7>] warn_slowpath+0xb7/0xf0
 [<ffffffff804b98e0>] ? ip_output+0x90/0xf0
 [<ffffffff804b858f>] ? __ip_local_out+0x9f/0xb0
 [<ffffffff804b85c0>] ? ip_local_out+0x20/0x30
 [<ffffffff804b8e9c>] ? ip_queue_xmit+0x21c/0x3f0
 [<ffffffff80488ddc>] ? pskb_copy+0x1c/0x1a0
 [<ffffffff8048884e>] ? __alloc_skb+0x6e/0x150
 [<ffffffff80512972>] ? fib6_clean_node+0x42/0xc0
 [<ffffffff8054ad04>] ? _write_unlock_bh+0x24/0x30
 [<ffffffff8054aa0f>] ? _spin_lock_irqsave+0x3f/0x50
 [<ffffffff8037baca>] ? strlcpy+0x4a/0x60
 [<ffffffff8049fe78>] dev_watchdog+0x258/0x270
 [<ffffffff80512360>] ? fib6_gc_timer_cb+0x0/0x10
 [<ffffffff8054ad63>] ? _spin_unlock_bh+0x23/0x30
 [<ffffffff8049fc20>] ? dev_watchdog+0x0/0x270
 [<ffffffff80254650>] run_timer_softirq+0x170/0x250
 [<ffffffff8026adff>] ? clockevents_program_event+0x4f/0x90
 [<ffffffff8024fcc4>] __do_softirq+0x84/0x100
 [<ffffffff80213fdc>] call_softirq+0x1c/0x30
 [<ffffffff802161ad>] do_softirq+0x5d/0xa0
 [<ffffffff8024f92d>] irq_exit+0x9d/0xb0
 [<ffffffff80224b84>] smp_apic_timer_interrupt+0x84/0xc0
 [<ffffffff802138b3>] apic_timer_interrupt+0x83/0x90
 <EOI>  [<ffffffff8021b250>] ? mwait_idle+0x40/0x60
 [<ffffffff80211662>] ? enter_idle+0x22/0x30
 [<ffffffff802116dd>] ? cpu_idle+0x6d/0x120
 [<ffffffff80538038>] ? rest_init+0x88/0x90

This happened less than half a minute after the transfer had started.
And it's going to happen earlier if I increase the load. With four
connections to two other hosts, the transmission usually pauses after
less than ten seconds. Sometimes it lasts for only two or three seconds.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
