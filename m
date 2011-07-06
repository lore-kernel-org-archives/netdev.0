From: Marc MERLIN <marc@merlins.org>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Wed, 6 Jul 2011 10:25:38 -0700
Message-ID: <20110706172538.GI18238@merlins.org>
References: <20110629033025.GA32153@merlins.org> <20110629042345.GB18344@kroah.com> <20110703031309.GL3224@merlins.org> <20110705153519.GA6198@kroah.com> <20110629033025.GA32153@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:40110 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099Ab1GFRZp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 13:25:45 -0400
Content-Disposition: inline
In-Reply-To: <20110705153519.GA6198@kroah.com> <20110629033025.GA32153@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy netdev folks,

On Tue, Jul 05, 2011 at 08:35:19AM -0700, Greg KH wrote:
> I looked at this and it seems they took a very old version of the driver
> (from 2003) and somehow changed it to work for this device.  I can't
> really tell what they changed unless I were to dig through the original
> version.
> 
> I suggest you post your original message to the 
> mailing list.  The network developers there should be able to help you
> out as I can't at the moment due to real-work and travel.

Here are the details. If somehow their driver could be integrated in
mainline by putting the relevant bits in the current driver, that would be
fantastic :)
(obviously it would have been better if they had done that themselves to
start with, no idea why they didn't).

----------------------------------------------------------------------------

I just bought a USB gige ethernet adapter from 'winstars' called 'delphi g
usb 2.0 gigabit lan'.

Linux 2.6.39.1 says:
usb 8-1: Product: AX88178 
usb 8-1: Manufacturer: ASIX Elec. Corp.
usb 8-1: SerialNumber: 000002
asix 8-1:1.0: eth1: register 'asix' at usb-0000:00:1d.7-1, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix

but that driver brings up an eth1 that cannot send data.

Google showed me the vendor website with a working linux driver:
http://www.asix.com.tw/FrootAttach/driver/AX88772_772A_178_LINUX2.6.9_REV122.zip

Their driver which compiled out of tree easily and said:
ASIX USB Ethernet Adapter:v4.1.0 19:16:59 Jun 28 2011
<6>    http://www.asix.com.tw
eth%d: status ep1in, 8 bytes period 11
eth1: register 'asix' at usb-0000:00:1d.7-1, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
eth1: rxqlen 0 --> 5
eth1: ax88178 - Link status is: 0
eth1: kevent 4 scheduled
eth1: ax88178 - Link status is: 1
eth1: no IPv6 routers present

It worked fine with dhcp (which the stock driver sure didn't).

Is there someone who can see if that driver can be merged in mainline to
replace the non working one?

For comparison, the mainline one also outputted a traceback. The full relevant logs are below:

usb 8-1: new high speed USB device number 8 using ehci_hcd
usb 8-1: New USB device found, idVendor=0b95, idProduct=1780
usb 8-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 8-1: Product: AX88178 
usb 8-1: Manufacturer: ASIX Elec. Corp.
usb 8-1: SerialNumber: 000002
asix 8-1:1.0: eth1: register 'asix' at usb-0000:00:1d.7-1, ASIX AX88178 USB 2.0 Ethernet, 00:0e:c6:88:7c:ae
usbcore: registered new interface driver asix
asix 8-1:1.0: eth1: link down
ADDRCONF(NETDEV_UP): eth1: link is not ready
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
asix 8-1:1.0: eth1: link up, 1000Mbps, full-duplex, lpa 0xC5E1
eth1: no IPv6 routers present

gandalfthegrey:~# ifconfig eth1 192.168.205.10
gandalfthegrey:~# ping 192.168.205.254
PING 192.168.205.254 (192.168.205.254) 56(84) bytes of data.
>From 192.168.205.10 icmp_seq=3 Destination Host Unreachable
>From 192.168.205.10 icmp_seq=4 Destination Host Unreachable
(tcpdump showed some traffic though)

Later, I found this in dmesg:
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x113/0x1a9()
Hardware name: 4063FM6
NETDEV WATCHDOG: eth1 (asix): transmit queue 0 timed out
Modules linked in: asix usbnet nfs fscache usb_storage usb_libusual uas xt_tcpudp xt_state nls_iso8859_1 nls_cp437 vfat fat vboxnetadp vboxnetflt vboxdrv fuse nfsd lockd nfs_acl auth_rpcgss sunrpc autofs4 acpi_cpufreq mperf cpufreq_conservative cpufreq_powersave ipt_REJECT cpufreq_stats cpufreq_userspace cpufreq_ondemand freq_table ipt_MASQUERADE ipt_LOG iptable_mangle iptable_filter rfcomm bnep binfmt_misc fbcon tileblit font bitblit fbcon_rotate fbcon_cw fbcon_ud fbcon_ccw softcursor iptable_nat nf_nat nf_conntrack_ipv4 i915 drm_kms_helper nf_conntrack drm fb fbdev nf_defrag_ipv4 i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect ip_tables x_tables ipv6 btusb bluetooth snd_hda_codec_conexant msr snd_hda_intel coretemp snd_hda_codec snd_hwdep snd_pcm_oss input_polldev snd_mixer_oss thinkpad_a
 cpi snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq uvcvideo videodev media pcmcia arc4 snd_timer snd_seq_device r852 sm_common nand nand_ids yenta_socket pcmcia_rsrc iwlagn mac80211 nand_bch pcmcia_core rtc_cmos snd ppdev ehci_hcd bch sdhci_pci sdhci nand_ecc mtd mmc_core parport_pc r592 rtc_core uhci_hcd memstick cfg80211 snd_page_alloc rfkill e1000e soundcore processor battery rtc_lib usbcore psmouse lp ac nvram tpm_tis serio_raw sr_mod cdrom wmi evdev sg parport raid10 raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx multipath sha256_generic dm_crypt dm_mod aes_i586 aes_generic ecb cbc intel_agp intel_gtt video agpgart backlight thermal thermal_sys hwmon button
Pid: 0, comm: swapper Not tainted 2.6.39.1-core2-volpreempt-noide-hm64-20110620 #2
Call Trace:
 [<c0133599>] warn_slowpath_common+0x60/0x75
 [<c0133612>] warn_slowpath_fmt+0x26/0x2a
 [<c03c8a35>] dev_watchdog+0x113/0x1a9
 [<c012dd94>] ? try_to_wake_up+0x321/0x32c
 [<c024f023>] ? jbd2_journal_force_commit_nested+0x6e/0x6e
 [<c03c8922>] ? __netdev_watchdog_up+0x52/0x52
 [<c013c8c1>] run_timer_softirq+0x139/0x1b5
 [<c01380c1>] __do_softirq+0x7a/0x110
 [<c0138047>] ? __local_bh_enable+0x6c/0x6c
 <IRQ>  [<c0137f7a>] ? irq_exit+0x3d/0x8b
 [<c01039f1>] ? do_IRQ+0x7b/0x91
 [<c0443bb0>] ? common_interrupt+0x30/0x38
 [<c014007b>] ? get_signal_to_deliver+0x18d/0x32a
 [<f8b82fc9>] ? acpi_idle_enter_simple+0x136/0x16a [processor]
 [<c03a1a6f>] ? cpuidle_idle_call+0x6f/0xa0
 [<c0101b91>] ? cpu_idle+0x8b/0xa6
 [<c042a560>] ? rest_init+0x58/0x5a
 [<c06257d6>] ? start_kernel+0x313/0x318
 [<c06250a8>] ? i386_start_kernel+0xa8/0xb0
---[ end trace 0c6c364f0d69b5d1 ]---
device eth1 entered promiscuous mode
device eth1 left promiscuous mode
usbcore: deregistering interface driver asix
asix 8-1:1.0: eth1: unregister 'asix' usb-0000:00:1d.7-1, ASIX AX88178 USB 2.0 Ethernet

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
