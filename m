From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: WARNING: at net/sched/sch_generic.c:219
 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Tue, 11 Nov 2008 12:31:07 +0100
Message-ID: <1226403067.7685.1598.camel@twins>
References: <491954E1.2050002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Roger Heflin <rogerheflin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45713 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814AbYKKLbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 06:31:09 -0500
In-Reply-To: <491954E1.2050002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(netdev CC'ed)

On Tue, 2008-11-11 at 03:48 -0600, Roger Heflin wrote:
> I have duplicate this with kernel 2.6.27.2 and 2.6.27.5, no
> extra modules, tg3 Gbit networking.   I have not yet tested
> earlier kernels to see if this has been around for a while.

How do more recent kernels do?

> So far I have had this error happen 5 times (MTBF is maybe
> 12 hours), 4 of the 5 times resulted in the networking being
> broken, one time things came back by itself without a reboot,
> I believe in this case the hang was traffic coming into the
> machine vs the other times going out of the machine.
> 
> Unloading all of the network modules and reloading them did
> not correct the problem.
> 
> Searching google finds a couple of other people getting the
> same error but they have a different network chipset (e1000
> and a rt811C chipset), which makes me thing that there is
> something interacting bad with the network.    Or does this
> error truly mean that the network chipset for some unknown reason
> locked itself up?
> 
> http://www.google.com/url?sa=U&start=4&q=http://kerneltrap.org/mailarchive/linux-netdev/2008/8/6/2838184&ei=rU8ZScysAon8edz5xKgO&sig2=Wxp7IkUtdgORGZiflxvppg&usg=AFQjCNHzPwsCOmLGKmtX4q_FEpk6oubxxg
> http://article.gmane.org/gmane.linux.network/110238
> 
> The changes I made recently were to upgrade my MB (old
> was E100 on a 100Mbit network,new is tg3 on a Gbit network,
> cpu and memory are the same, MB chipset is a intel 955
> chipset vs the old being a intel 915 chipset).
> 
> Autoneg is turned on all around, the GBit switch is a
> 8-port Dlink switch.   The network seems to otherwise be working
> correctly.
> 
> I did test the network under decent load and the error did not
> appear to be any more likely under load, and typically the network
> is under very light load 2-3MB/second.
> 
> The machine originally had 2 HT CPU's showing up, I turned off HT
> so that only one cpu was showing, but this did not change the error.
> 
> I am first turning off all offload capabilities on tg3 and going
> to see if that changes anything.
> 
> The next thing I am going to be doing is to turn of GB capability
> on the networking and see if that does anything.
> 
> I also have a second tg3 port that is slightly different, so I may
> try that eventually.
> 
> What else can I look at?
> 
> 
> 
> 
> 
> 
> Nov 11 00:44:39 computer kernel: ------------[ cut here ]------------
> Nov 11 00:44:39 computer kernel: WARNING: at net/sched/sch_generic.c:219 
> dev_watchdog+0xfe/0x17e()
> Nov 11 00:44:39 computer kernel: NETDEV WATCHDOG: eth0 (tg3): transmit timed out
> Nov 11 00:44:39 computer kernel: Modules linked in: nfsd auth_rpcgss exportfs 
> w83627ehf hwmon_vid hwmon nfs lockd nfs_acl sunrpc ipv6 xfs raid456 async_xor 
> async_memcpy async_tx xor video output sbs sbshc battery ac lgdt330x cx88_dvb 
> wm8775 cx88_vp3054_i2c cx25840 tuner_simple tuner_types tda9887 tda8290 tuner 
> mt2131 s5h1409 snd_hda_intel snd_seq_dummy ivtv cx8800 snd_seq_oss cx88_alsa 
> cx8802 cx88xx cx23885 snd_seq_midi_event snd_seq ir_common videodev v4l1_compat 
> i2c_algo_bit cx2341x firewire_ohci iTCO_wdt snd_seq_device compat_ioctl32 
> videobuf_dvb i2c_i801 firewire_core tveeprom floppy iTCO_vendor_support 
> v4l2_common snd_pcm_oss dvb_core pcspkr tg3 sata_sil i2c_core btcx_risc 
> videobuf_dma_sg crc_itu_t snd_mixer_oss libphy videobuf_core snd_pcm parport_pc 
> parport snd_timer snd soundcore button snd_page_alloc sg dm_snapshot dm_zero 
> dm_mirror dm_log dm_mod ahci ata_piix ata_generic libata sd_mod scsi_mod ext3 
> jbd mbcache ehci_hcd ohci_hcd uhci_hcd [last unloaded: eeprom]
> Nov 11 00:44:39 computer kernel: Pid: 0, comm: swapper Not tainted 2.6.27.5 #2
> Nov 11 00:44:39 computer kernel:  [<c042524f>] warn_slowpath+0x61/0x83
> Nov 11 00:44:39 computer kernel:  [<c05663a4>] usb_hcd_submit_urb+0x75c/0x811
> Nov 11 00:44:39 computer kernel:  [<c0594972>] hiddev_hid_event+0x0/0x64
> Nov 11 00:44:39 computer kernel:  [<c058ce80>] hid_process_event+0x58/0x5f
> Nov 11 00:44:39 computer kernel:  [<c04e13d6>] __next_cpu+0x12/0x21
> Nov 11 00:44:39 computer kernel:  [<c041cbe3>] find_busiest_group+0x23e/0x672
> Nov 11 00:44:39 computer kernel:  [<c0439d1e>] clocksource_get_next+0x39/0x3f
> Nov 11 00:44:39 computer kernel:  [<c0438e51>] update_wall_time+0x567/0x70c
> Nov 11 00:44:39 computer kernel:  [<c040783e>] read_tsc+0x6/0x22
> Nov 11 00:44:39 computer kernel:  [<c04387e8>] getnstimeofday+0x37/0xc1
> Nov 11 00:44:39 computer kernel:  [<f8829a83>] uhci_scan_schedule+0x11b/0x6b0 
> [uhci_hcd]
> Nov 11 00:44:39 computer kernel:  [<c05b16ba>] dev_watchdog+0xfe/0x17e
> Nov 11 00:44:39 computer kernel:  [<c042c66f>] __mod_timer+0x99/0xa3
> Nov 11 00:44:39 computer kernel:  [<c05654b6>] rh_timer_func+0x0/0x5
> Nov 11 00:44:39 computer kernel:  [<c05654ae>] usb_hcd_poll_rh_status+0x12b/0x133
> Nov 11 00:44:39 computer kernel:  [<c043bca8>] tick_dev_program_event+0x1e/0x81
> Nov 11 00:44:39 computer kernel:  [<c05b15bc>] dev_watchdog+0x0/0x17e
> Nov 11 00:44:39 computer kernel:  [<c042c2b4>] run_timer_softirq+0x10e/0x167
> Nov 11 00:44:39 computer kernel:  [<c05b15bc>] dev_watchdog+0x0/0x17e
> Nov 11 00:44:39 computer kernel:  [<c0428d3e>] __do_softirq+0x5d/0xc1
> Nov 11 00:44:39 computer kernel:  [<c0428dd4>] do_softirq+0x32/0x36
> Nov 11 00:44:39 computer kernel:  [<c0412939>] smp_apic_timer_interrupt+0x6e/0x79
> Nov 11 00:44:39 computer kernel:  [<c040431c>] apic_timer_interrupt+0x28/0x30
> Nov 11 00:44:39 computer kernel:  [<c0408582>] mwait_idle+0x32/0x38
> Nov 11 00:44:39 computer kernel:  [<c040255d>] cpu_idle+0xbd/0xd5
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
