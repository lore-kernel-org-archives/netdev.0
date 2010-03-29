From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: eth1: Detected Hardware Unit Hang
Date: Mon, 29 Mar 2010 19:36:54 +0200
Message-ID: <4BB0E536.2010301@itcare.pl>
References: <4BB0C853.2080607@itcare.pl> <8DD2590731AB5D4C9DBF71A877482A9061BB3254@orsmsx509.amr.corp.intel.com> <4BB0E394.2060908@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:58580 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab0C2RhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 13:37:00 -0400
In-Reply-To: <4BB0E394.2060908@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-03-29 19:29, Pawe=B3 Staszewski pisze:
> lspci -vvv + ethtool -S in attached files.
>
> Network traffic when i get this info:
> eth1:    RX:    157.22 Mb/s    TX:    379.27 Mb/s
>
> ethtool -i eth1
> driver: e1000e
> version: 1.0.2-k2
> firmware-version: 0.5-7
> bus-info: 0000:05:00.0
> This is: Intel Corporation 82573L Gigabit Ethernet Controller
>
>
> But in this server i have another gigabit interface:
> Intel Corporation 82573E Gigabit Ethernet Controller
> this interface has two times more traffic than eth0 (82573L)
> ethtool -i eth0
> driver: e1000e
> version: 1.0.2-k2
> firmware-version: 0.15-5
> bus-info: 0000:04:00.0
>
I forgot to add that i have no problems with (eth0) 82573E


> And also this server was working 4months without problems on 2.6.29.1=
=20
> kernel
>
> Drivers that I use for e1000e are from kernel (standard kernel=20
> build-in e1000e driver).
> I don't tried other drivers.
>
> This is production server so I can't make too much tests.
>
>
> W dniu 2010-03-29 18:41, Allan, Bruce W pisze:
>> [adding e1000-devel]
>>
>> Please provide more information:
>> * what NIC/LOM is this on (preferably send full output from lspci -v=
vv)
>> * what type of networking workload is running at the time the hang=20
>> occurred
>> * a dump of the NIC/LOM statistics might also help (ethtool -S eth1)
>>
>> Have you tried the latest standalone e1000e driver on e1000.sf.net? =
=20
>> Does it reproduce the issue?
>>
>> If we cannot reproduce the hang in-house, would you be able/willing=20
>> to run a debug driver to gather more information?
>>
>> Thanks,
>> Bruce.
>>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org=20
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Pawel Staszewski
>> Sent: Monday, March 29, 2010 8:34 AM
>> To: Linux Network Development list
>> Subject: eth1: Detected Hardware Unit Hang
>>
>> After update to kernel from 2.6.29.1 to 2.6.33.1 i have this info in=
=20
>> dmesg:
>>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bafaf>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bb1a3>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bb397>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> ------------[ cut here ]------------
>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x118/0x19c()
>> Hardware name: X7DCT
>> NETDEV WATCHDOG: eth1 (e1000e): transmit queue 0 timed out
>> Modules linked in:
>> Pid: 0, comm: swapper Not tainted 2.6.33.1 #2
>> Call Trace:
>>    [<c1024e3d>] ? warn_slowpath_common+0x52/0x71
>>    [<c1024e49>] ? warn_slowpath_common+0x5e/0x71
>>    [<c1024e8e>] ? warn_slowpath_fmt+0x26/0x2a
>>    [<c1261f54>] ? dev_watchdog+0x118/0x19c
>>    [<c102135c>] ? __wake_up+0x29/0x39
>>    [<c10320c6>] ? insert_work+0x40/0x44
>>    [<c1261e3c>] ? dev_watchdog+0x0/0x19c
>>    [<c102cc15>] ? run_timer_softirq+0x11a/0x173
>>    [<c1028e5b>] ? __do_softirq+0x74/0xdf
>>    [<c1028ee9>] ? do_softirq+0x23/0x27
>>    [<c10290be>] ? irq_exit+0x26/0x58
>>    [<c10102d7>] ? smp_apic_timer_interrupt+0x6c/0x76
>>    [<c12c5f9a>] ? apic_timer_interrupt+0x2a/0x30
>>    [<c1007e06>] ? mwait_idle+0x49/0x4e
>>    [<c10017e8>] ? cpu_idle+0x41/0x5a
>> ---[ end trace bcca9926a046332c ]---
>>
>>
>> With kernel 2.6.29.1 all was ok.
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>

