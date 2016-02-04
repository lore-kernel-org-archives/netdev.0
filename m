From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Disabling XPS for 4.4.0-1+ixgbe+OpenStack VM over a VLAN means
 65% increase in netperf TCP_STREAM
Date: Thu, 4 Feb 2016 11:57:51 -0800
Message-ID: <56B3AD3F.9070404@hpe.com>
References: <56B3A2D4.1010309@hpe.com>
 <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2352.austin.hp.com ([15.217.128.51]:35310 "EHLO
	g2t2352.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831AbcBDT5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 14:57:53 -0500
In-Reply-To: <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 11:38 AM, Tom Herbert wrote:
> On Thu, Feb 4, 2016 at 11:13 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>> The Intel folks suggested something about the process scheduler moving the
>> sender around and ultimately causing some packet re-ordering.  That could I
>> suppose explain the TCP_STREAM difference, but not the TCP_RR since that has
>> just a single segment in flight at one time.
>>
> XPS has OOO avoidance for TCP, that should not be a problem.

What/how much should I read into:

With XPS    TCPOFOQueue: 78206
Without XPS TCPOFOQueue: 967

out of the netstat statistics on the receiving VM?

>> I can try to get perf/whatnot installed on the systems - suggestions as to
>> what metrics to look at are welcome.
>>
> I'd start with verifying the XPS configuration is sane and then trying
> to reproduce the issue outside of using VMs, if both of those are okay
> then maybe look at some sort of bad interaction with OpenStack
> configuration.

Fair enough - what is the definition of "sane" for an XPS configuration?

Here is what it looks like before I disabled it:

$ for i in `find 
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0 -name 
xps_cpus`; do echo $i `cat $i`; done
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-0/xps_cpus 
0000,00000001
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-1/xps_cpus 
0000,00000002
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-2/xps_cpus 
0000,00000004
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-3/xps_cpus 
0000,00000008
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-4/xps_cpus 
0000,00000010
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-5/xps_cpus 
0000,00000020
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-6/xps_cpus 
0000,00000040
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-7/xps_cpus 
0000,00000080
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-8/xps_cpus 
0000,00000100
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-9/xps_cpus 
0000,00000200
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-10/xps_cpus 
0000,00000400
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-11/xps_cpus 
0000,00000800
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-12/xps_cpus 
0000,00001000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-13/xps_cpus 
0000,00002000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-14/xps_cpus 
0000,00004000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-15/xps_cpus 
0000,00008000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-16/xps_cpus 
0000,00010000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-17/xps_cpus 
0000,00020000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-18/xps_cpus 
0000,00040000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-19/xps_cpus 
0000,00080000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-20/xps_cpus 
0000,00100000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-21/xps_cpus 
0000,00200000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-22/xps_cpus 
0000,00400000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-23/xps_cpus 
0000,00800000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-24/xps_cpus 
0000,01000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-25/xps_cpus 
0000,02000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-26/xps_cpus 
0000,04000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-27/xps_cpus 
0000,08000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-28/xps_cpus 
0000,10000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-29/xps_cpus 
0000,20000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-30/xps_cpus 
0000,40000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-31/xps_cpus 
0000,80000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-32/xps_cpus 
0001,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-33/xps_cpus 
0002,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-34/xps_cpus 
0004,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-35/xps_cpus 
0008,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-36/xps_cpus 
0010,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-37/xps_cpus 
0020,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-38/xps_cpus 
0040,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-39/xps_cpus 
0080,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-40/xps_cpus 
0100,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-41/xps_cpus 
0200,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-42/xps_cpus 
0400,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-43/xps_cpus 
0800,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-44/xps_cpus 
1000,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-45/xps_cpus 
2000,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-46/xps_cpus 
4000,00000000
/sys/devices/pci0000:00/0000:00:02.2/0000:04:00.0/net/eth0/queues/tx-47/xps_cpus 
8000,00000000


Which looks like it simply got spread across all the "CPUs" (HTs 
included) in the system.

happy benchmarking,

rick jones
