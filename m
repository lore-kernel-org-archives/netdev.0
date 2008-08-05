From: "John P Poet" <jppoet@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Mon, 4 Aug 2008 21:42:46 -0600
Message-ID: <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
	 <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:55794 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760140AbYHEDms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 23:42:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1176312fgg.17
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 20:42:46 -0700 (PDT)
In-Reply-To: <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 4, 2008 at 8:00 PM, John P Poet <jppoet@gmail.com> wrote:
> On Mon, Aug 4, 2008 at 7:12 PM, John P Poet <jppoet@gmail.com> wrote:
>> I recently bought a new motherboard with Realtek 8111C nics.  The nic
>> is detected as:
>>
>> dmesg:
>> r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
>> ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 18 (level, low) -> IRQ 18
>> PCI: Setting latency timer of device 0000:06:00.0 to 64
>> eth0: RTL8168c/8111c at 0xffffc2000063e000, 00:1f:d0:20:01:57, XID
>> 3c4000c0 IRQ 2292
>>
>> lspci -v:
>> 06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
>> RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
>>        Subsystem: Giga-byte Technology Unknown device e000
>>        Flags: bus master, fast devsel, latency 0, IRQ 2292
>>        I/O ports at b000 [size=256]
>>        Memory at de010000 (64-bit, prefetchable) [size=4K]
>>        Memory at de000000 (64-bit, prefetchable) [size=64K]
>>        [virtual] Expansion ROM at de020000 [disabled] [size=64K]
>>        Capabilities: [40] Power Management version 3
>>        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
>> Queue=0/1 Enable+
>>        Capabilities: [70] Express Endpoint, MSI 01
>>        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
>>        Capabilities: [d0] Vital Product Data <?>
>>        Capabilities: [100] Advanced Error Reporting <?>
>>        Capabilities: [140] Virtual Channel <?>
>>        Capabilities: [160] Device Serial Number 78-56-34-12-78-56-34-12
>>        Kernel driver in use: r8169
>>        Kernel modules: r8169
>>
>> I have been having two problems with this nic:
>>
>> 1) On a cold boot, the nic is not brought up correctly.  It seems to
>> stay at 100mbit instead of going into gbit mode, and it fails to ping
>> the router even though it seems to get a valid IP address.  If I then
>> warm boot the computer, then then nic comes up in gbit just fine, and
>> generally works.
>>
>> 2) I am getting a lot of timeouts:
>>
>> Aug  4 17:49:35 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> Aug  4 17:49:35 saphire kernel: r8169: eth0: link up
>> Aug  4 17:50:05 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> Aug  4 17:50:05 saphire kernel: r8169: eth0: link up
>> ...
>> Aug  4 18:52:17 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> Aug  4 18:52:17 saphire kernel: r8169: eth0: link up
>> ...
>> Aug  4 18:55:59 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> Aug  4 18:55:59 saphire kernel: r8169: eth0: link up
>> ...
>> Aug  4 18:57:47 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> Aug  4 18:57:47 saphire kernel: r8169: eth0: link up
>>
>> While the booting problem is annoying, the timeouts are actually even
>> more so.  I am a mythtv users, and those timeouts cause my video/audio
>> streaming to fail.
>>
>> Is there anything I can do about these problems?
>
> I probably should have mentioned that I am running the 2.6.26 kernel.

I just tried applying ALL the patches found here:

http://userweb.kernel.org/~romieu/r8169/2.6.27-rc1/20080803.tar.bz2

against 2.6.26.1.  Worked for a while, I then I got:

Aug  4 21:23:24 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 21:23:24 saphire kernel: ------------[ cut here ]------------
Aug  4 21:23:24 saphire kernel: WARNING: at
net/sched/sch_generic.c:222 dev_watchdog+0xb6/0x116()
Aug  4 21:23:24 saphire kernel: Modules linked in: hdpvr videodev
v4l1_compat v4l2_common nfs nfsd lockd nfs_acl auth_rpcgss exportfs
autofs4 coretemp hwmon fuse sunrpc ipv6 acpi_cpufreq xfs dm_mirror
dm_log dm_multipath dm_mod raid456 async_xor async_memcpy async_tx xor
snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
sr_mod snd_seq_device i2c_i801 serio_raw i2c_core snd_pcm_oss pcspkr
cdrom snd_mixer_oss snd_pcm snd_timer snd_page_alloc r8169 snd_hwdep
snd mii pl2303 usbserial soundcore sg button sata_mv sata_sil24 ahci
libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd
[last unloaded: microcode]
Aug  4 21:23:24 saphire kernel: Pid: 12472, comm: cc1plus Not tainted
2.6.26.1 #1
Aug  4 21:23:24 saphire kernel:
Aug  4 21:23:24 saphire kernel: Call Trace:
Aug  4 21:23:24 saphire kernel:  <IRQ>  [<ffffffff81031fa8>]
warn_on_slowpath+0x58/0x86
Aug  4 21:23:24 saphire kernel:  [<ffffffff8103a78e>] ? __mod_timer+0xc1/0xd3
Aug  4 21:23:24 saphire kernel:  [<ffffffff81041458>] ?
queue_delayed_work_on+0xc3/0xd6
Aug  4 21:23:24 saphire kernel:  [<ffffffff81216891>] ? dev_watchdog+0x0/0x116
Aug  4 21:23:24 saphire kernel:  [<ffffffff810414a7>] ?
queue_delayed_work+0x21/0x23
Aug  4 21:23:24 saphire kernel:  [<ffffffff810414c2>] ?
schedule_delayed_work+0x19/0x1b
Aug  4 21:23:24 saphire kernel:  [<ffffffffa00f70d2>] ?
:r8169:rtl8169_schedule_work+0x23/0x25
Aug  4 21:23:24 saphire kernel:  [<ffffffff81216947>] dev_watchdog+0xb6/0x116
Aug  4 21:23:24 saphire kernel:  [<ffffffff8103a230>]
run_timer_softirq+0x16c/0x1e1
Aug  4 21:23:24 saphire kernel:  [<ffffffff81036a93>] __do_softirq+0x57/0xc7
Aug  4 21:23:24 saphire kernel:  [<ffffffff8100d06c>] call_softirq+0x1c/0x28
Aug  4 21:23:24 saphire kernel:  [<ffffffff8100e7b6>] do_softirq+0x34/0x72
Aug  4 21:23:24 saphire kernel:  [<ffffffff81036a3a>] irq_exit+0x3f/0x41
Aug  4 21:23:24 saphire kernel:  [<ffffffff8101a078>]
smp_apic_timer_interrupt+0x8b/0xa7
Aug  4 21:23:24 saphire kernel:  [<ffffffff8100cb16>]
apic_timer_interrupt+0x66/0x70
Aug  4 21:23:24 saphire kernel:  <EOI>
Aug  4 21:23:24 saphire kernel: ---[ end trace 0d5c00894ac85a19 ]---
Aug  4 21:23:24 saphire kernel: r8169: eth0: link up


John
-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
