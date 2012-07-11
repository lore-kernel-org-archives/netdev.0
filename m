From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Wed, 11 Jul 2012 01:18:48 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com>
 <4FFCCA22.8060006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFCCA22.8060006@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Tuesday, July 10, 2012 5:35 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/11/12 03:02, Dave, Tushar N wrote:
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org
>>> [mailto:netdev-owner@vger.kernel.org]
>>> On Behalf Of Joe Jin
>>> Sent: Tuesday, July 10, 2012 12:40 AM
>>> To: Joe Jin
>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>> kernel@vger.kernel.org
>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>
>>> When I debug the driver I found before Detected HW hang, driver
>>> unable to clean and reclaim the resources:
>>>
>>> 1457         while ((eop_desc->upper.data &
>>> cpu_to_le32(E1000_TXD_STAT_DD)) &&  <== at here upper.data always is
>0x300
>>> 1458                (count < tx_ring->count)) {
>>>     <--- snip --->
>>> 1487         }
>>>
>>>
>>> I checked all driver codes I did not found anywhere will set the
>>> upper.data with E1000_TXD_STAT_DD, I guess upper.data be set by
>hardware?
>>
>> Yes upper.data (part of it is STATUS byte) is set by HW. Basically
>driver checks E1000_TXD_STAT_DD (Descriptor Done) bit. If this bit is set
>that means HW has processed that descriptor and driver can now clean that
>descriptor.
>> With value 0x300 , DD bit is not set. That means HW has not processed
>that descriptor.
>
>Thanks for the clarify, might be firmware issue?
>>
>> How fast does tx hang reproduce? I suggest you to enable debug code in
>driver so when tx hang occurs it will dump the HW desc ring info into
>kernel log.
>
>Once I copy a file from other server, issue to be reproduced at once.
>I'll enable the debug to get more debug info.
>
>> You can run "ethtool -s ethx msglvl 0x2c00" to enable debug.
>> Once tx hang occurs please send me the full dmesg log.
>>
>> Does tx hang occur with in-kernel e1000e driver too?
>
>I tried several drivers included rhel5 the latest, Intel the latest,
>rhel6 the latest, issue see on all those drivers.

Also after issue occurs please capture lspci -vvv (run as root)

>
>Thanks,
>Joe
>>
>> Thanks.
>>
>> -Tushar
>>
>>
>>> If OS is 32bit system, what which happen?
>>
>>
>>>
>>> Thanks in advance,
>>> Joe
>>>
>>> On 07/09/12 16:51, Joe Jin wrote:
>>>> Hi list,
>>>>
>>>> I'm seeing a Unit Hang even with the latest e1000e driver 2.0.0 when
>>>> doing scp test. this issue is easy do reproduced on SUN FIRE X2270
>>>> M2, just copy a big file (>500M) from another server will hit it at
>once.
>>>>
>>>> Would you please help on this?
>>>>
>>>> device info:
>>>> # lspci -s 05:00.0
>>>> 05:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>>>> Ethernet Controller (Copper) (rev 06)
>>>>
>>>> # lspci -s 05:00.0 -n
>>>> 05:00.0 0200: 8086:10bc (rev 06)
>>>>
>>>> # ethtool -i eth0
>>>> driver: e1000e
>>>> version: 2.0.0-NAPI
>>>> firmware-version: 5.10-2
>>>> bus-info: 0000:05:00.0
>>>>
>>>> # ethtool -k eth0
>>>> Offload parameters for eth0:
>>>> rx-checksumming: on
>>>> tx-checksumming: on
>>>> scatter-gather: on
>>>> tcp segmentation offload: on
>>>> udp fragmentation offload: off
>>>> generic segmentation offload: on
>>>> generic-receive-offload: on
>>>>
>>>> kernel log:
>>>> -----------
>>>> e1000e 0000:05:00.0: eth0: Detected Hardware Unit Hang:
>>>>   TDH                  <6c>
>>>>   TDT                  <81>
>>>>   next_to_use          <81>
>>>>   next_to_clean        <6b>
>>>> buffer_info[next_to_clean]:
>>>>   time_stamp           <fffc7a23>
>>>>   next_to_watch        <71>
>>>>   jiffies              <fffc8c0c>
>>>>   next_to_watch.status <0>
>>>> MAC Status             <80387>
>>>> PHY Status             <792d>
>>>> PHY 1000BASE-T Status  <3c00>
>>>> PHY Extended Status    <3000>
>>>> PCI Status             <10>
>>>> e1000e 0000:05:00.0: eth0: Detected Hardware Unit Hang:
>>>>   TDH                  <6c>
>>>>   TDT                  <81>
>>>>   next_to_use          <81>
>>>>   next_to_clean        <6b>
>>>> buffer_info[next_to_clean]:
>>>>   time_stamp           <fffc7a23>
>>>>   next_to_watch        <71>
>>>>   jiffies              <fffc9bac>
>>>>   next_to_watch.status <0>
>>>> MAC Status             <80387>
>>>> PHY Status             <792d>
>>>> PHY 1000BASE-T Status  <3c00>
>>>> PHY Extended Status    <3000>
>>>> PCI Status             <10>
>>>> ------------[ cut here ]------------
>>>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x225/0x230()
>>>> Hardware name: SUN FIRE X2270 M2 NETDEV WATCHDOG: eth0 (e1000e):
>>>> transmit queue 0 timed out Modules linked in: autofs4 hidp rfcomm
>>>> bluetooth rfkill lockd sunrpc cpufreq_ondemand acpi_cpufreq mperf
>>>> be2iscsi iscsi_boot_sysfs ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad
>>>> ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i libcxgbi cxgb3
>>>> mdio libiscsi_tcp libiscsi scsi_transport_iscsi video sbs sbshc
>>>> acpi_pad acpi_ipmi ipmi_msghandler parport_pc lp parport e1000e(U)
>>>> snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device
>>>> igb snd_pcm_oss serio_raw snd_mixer_oss snd_pcm tpm_infineon
>>>> snd_timer snd soundcore snd_page_alloc i2c_i801 iTCO_wdt i2c_core
>>>> pcspkr i7core_edac iTCO_vendor_support ioatdma ghes dca edac_core
>>>> hed dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod
>>>> usb_storage sd_mod crc_t10dif sg ahci libahci ext3 jbd mbcache [last
>unloaded:
>>>> microcode]
>>>> Pid: 0, comm: swapper Not tainted 2.6.39-200.24.1.el5uek #1 Call
>>>> Trace:
>>>>  [<c07d9ac5>] ? dev_watchdog+0x225/0x230  [<c045ba61>]
>>>> warn_slowpath_common+0x81/0xa0  [<c07d9ac5>] ?
>>>> dev_watchdog+0x225/0x230  [<c045bb23>] warn_slowpath_fmt+0x33/0x40
>>>> [<c07d9ac5>] dev_watchdog+0x225/0x230  [<c07d98a0>] ?
>>>> dev_activate+0xb0/0xb0  [<c0468e82>] call_timer_fn+0x32/0xf0
>>>> [<c04bceb0>] ? rcu_check_callbacks+0x80/0x80  [<c046a76d>]
>>>> run_timer_softirq+0xed/0x1b0  [<c07d98a0>] ? dev_activate+0xb0/0xb0
>>>> [<c0461a81>] __do_softirq+0x91/0x1a0  [<c04619f0>] ?
>>>> local_bh_enable+0x80/0x80  <IRQ>  [<c0462295>] ? irq_exit+0x95/0xa0
>>>> [<c087f8b8>] ? smp_apic_timer_interrupt+0x38/0x42
>>>>  [<c08784f5>] ? apic_timer_interrupt+0x31/0x38  [<c046007b>] ?
>>>> do_exit+0x11b/0x370  [<c065eae4>] ? intel_idle+0xa4/0x100
>>>> [<c078d9b9>] ? cpuidle_idle_call+0xb9/0x1e0  [<c0411d77>] ?
>>>> cpu_idle+0x97/0xd0  [<c085cbbd>] ? rest_init+0x5d/0x70  [<c0b07a7a>] ?
>>>> start_kernel+0x28a/0x340  [<c0b074b0>] ?
>>>> obsolete_checksetup+0xb0/0xb0 [<c0b070a4>] ?
>>>> i386_start_kernel+0x64/0xb0 ---[ end trace 5502b55cd4d4e5cb ]---
>>>> e1000e 0000:05:00.0: eth0: Reset adapter
>>>> e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control:
>>>> Rx/Tx
>>>>
>>>> Thanks,
>>>> Joe
>>>>
>>>
>>>
>>>
