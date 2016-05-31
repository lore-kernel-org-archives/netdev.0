From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: Re: codel/fq_codel triggers heaps of WARNs in net/sched/sch_hfsc.c:1426
Date: Tue, 31 May 2016 14:31:56 +0200
Message-ID: <CAO0uZ+-uNHjYyEZzYnO0HcHE+y6MXw0+YFzYEwj9HOPMrhkNRw@mail.gmail.com>
References: <CAO0uZ+-SvYncQ+OUbDn5B7-_W3j6Wge8=t0EKi6xCb1ruXUwiQ@mail.gmail.com>
	<20160531100052.GA2431@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34450 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbcEaMb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 08:31:58 -0400
Received: by mail-lf0-f66.google.com with SMTP id 65so16917409lfq.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 05:31:57 -0700 (PDT)
In-Reply-To: <20160531100052.GA2431@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Both HFSC and fq_codel have problems, but I'm not sure if these are
> relevant for your 4.5.5 kernel.
> I'll submit a hfsc patch soon (it does fix a real problem).
I'm actually QoSing around 5 Gbit/s on some machines with HFSC,
without any problems, with SFQ though. Feel free to contact me if you
need some testing ground.

>
> If you have any config knobs enabled on the fq_codel leaf qdiscs it
> would be good to know what parameters are used.

"all default". Codels look like this:

qdisc codel 573b: dev ifb1 parent 1:573b limit 1000p target 5.0ms
interval 100.0ms
 Sent 64451468 bytes 43164 pkt (dropped 29, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  count 3 lastcount 1 ldelay 2us drop_next 0us
  maxpacket 1536 ecn_mark 0 drop_overlimit 0

>
> Can you try this patch (it doesn't fix anything but might provide more info):
> [...patch...]


The output is attached below. If I got it correctly from my weak
knowledge of HFSC internals there's a packet that somehow appears in
the queue without having the fit time set?

-mk

[ 1476.685712] ------------[ cut here ]------------
[ 1476.685728] WARNING: CPU: 16 PID: 0 at net/sched/sch_hfsc.c:1426
hfsc_dequeue+0x30f/0x3a0 [sch_hfsc]()
[ 1476.685731] Modules linked in: sch_fq_codel(E) act_mirred(E)
act_gact(E) sch_ingress(E) sch_codel(E) sch_sfq(E) cls_u32(E)
sch_hfsc(E) ext4(E) x86_pkg_temp_thermal(E) crc16(E) mbcache(E)
jbd2(E) intel_powerclamp(E) coretemp(E) kvm_intel(E) kvm(E)
irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E)
ghash_clmulni_intel(E) hmac(E) drbg(E) ansi_cprng(E) aesni_intel(E)
aes_x86_64(E) joydev(E) lrw(E) gf128mul(E) sg(E) iTCO_wdt(E)
iTCO_vendor_support(E) glue_helper(E) mgag200(E) snd_pcm(E)
snd_timer(E) snd(E) soundcore(E) ipmi_devintf(E) ablk_helper(E)
cryptd(E) ttm(E) drm_kms_helper(E) drm(E) i2c_algo_bit(E) evdev(E)
wmi(E) acpi_power_meter(E) 8250_fintek(E) pcspkr(E) acpi_pad(E)
ipmi_si(E) ipmi_msghandler(E) sb_edac(E) button(E) shpchp(E)
edac_core(E) mei_me(E) mei(E) tpm_tis(E) lpc_ich(E) mfd_core(E) tpm(E)
[ 1476.685779]  processor(E) ifb(E) autofs4(E) xfs(E) libcrc32c(E)
hid_generic(E) usbhid(E) hid(E) sd_mod(E) sr_mod(E) cdrom(E)
crc32c_intel(E) ixgbe(E) dca(E) vxlan(E) ip6_udp_tunnel(E)
udp_tunnel(E) mdio(E) ahci(E) libahci(E) ehci_pci(E) libata(E) tg3(E)
ehci_hcd(E) ptp(E) pps_core(E) usbcore(E) libphy(E) megaraid_sas(E)
usb_common(E) scsi_mod(E) fjes(E)
[ 1476.685808] CPU: 16 PID: 0 Comm: swapper/16 Tainted: G            E
  4.5.5 #1
[ 1476.685810] Hardware name:    /08DM12, BIOS 2.1.2 01/20/2014
[ 1476.685812]  0000000000000286 2a3bd3d7e60bafde ffffffff81302ff5
0000000000000000
[ 1476.685815]  ffffffffc04fb049 ffffffff81078ced 0000000000000000
0000000000000000
[ 1476.685818]  ffff880c13411000 ffff880c13411490 ffff88003679a300
ffffffffc04f955f
[ 1476.685821] Call Trace:
[ 1476.685823]  <IRQ>  [<ffffffff81302ff5>] ? dump_stack+0x5c/0x77
[ 1476.685834]  [<ffffffff81078ced>] ? warn_slowpath_common+0x7d/0xb0
[ 1476.685838]  [<ffffffffc04f955f>] ? hfsc_dequeue+0x30f/0x3a0 [sch_hfsc]
[ 1476.685842]  [<ffffffff814db925>] ? __qdisc_run+0x65/0x190
[ 1476.685848]  [<ffffffff814b33f6>] ? net_tx_action+0xd6/0x230
[ 1476.685854]  [<ffffffff8107d4c8>] ? __do_softirq+0xf8/0x290
[ 1476.685857]  [<ffffffff8107d7ab>] ? irq_exit+0x9b/0xa0
[ 1476.685861]  [<ffffffff815b519e>] ? smp_apic_timer_interrupt+0x3e/0x50
[ 1476.685864]  [<ffffffff815b34a2>] ? apic_timer_interrupt+0x82/0x90
[ 1476.685865]  <EOI>  [<ffffffff8147dbf8>] ? cpuidle_enter_state+0x118/0x2c0
[ 1476.685870]  [<ffffffff8147dbe5>] ? cpuidle_enter_state+0x105/0x2c0
[ 1476.685874]  [<ffffffff810b8837>] ? cpu_startup_entry+0x287/0x340
[ 1476.685884]  [<ffffffff8104d40a>] ? start_secondary+0x15a/0x190
[ 1476.685887] ---[ end trace 3c736fc106257086 ]---
[ 1476.685890] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.685901] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.685973] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.685982] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.685992] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.685997] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.686000] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
[ 1476.686004] qlen 1 droplist_empty: 1, cfmin 0, minel 0, root_empty 1
