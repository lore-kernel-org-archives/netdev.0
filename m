From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Kexec Reboot Network Issue
Date: Sat, 17 Jul 2010 21:25:26 -0700
Message-ID: <m1630dh0w9.fsf@fess.ebiederm.org>
References: <4C3EF80B.1040400@symplicity.com>
	<20100715142003.GB19856@verge.net.au> <4C3F2ACF.60601@symplicity.com>
	<20100716071547.GB20761@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Genthner <rgenthner@symplicity.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	kexec@lists.infradead.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49652 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab0GREZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 00:25:35 -0400
In-Reply-To: <20100716071547.GB20761@verge.net.au> (Simon Horman's message of "Fri\, 16 Jul 2010 16\:15\:47 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman <horms@verge.net.au> writes:

> [ CCed Michael Chan, Matt Carlson and Netdev ]
>
> On Thu, Jul 15, 2010 at 11:35:43AM -0400, Richard Genthner wrote:
>> On 07/15/2010 10:20 AM, Simon Horman wrote:
>> >On Thu, Jul 15, 2010 at 07:59:07AM -0400, Richard Genthner wrote:
>> >>I'm currently using the following string:
>> >>
>> >>kexex --type=elf-x86_64 --args-linux -l /boot/vmlinuz-2.6.18-12.el5
>> >>--initrid=/boot/initrd-2.6.18-128.el6.img --append="`cat
>> >>/proc/cmdline`"
>> >>kexec -e
>> >>
>> >>Some times we can get to the box from any subnet, other times we can
>> >>only get to the box from the same subnet only. Our solution to this
>> >>is to down the iface and then restart networking. Has anyone else
>> >>run into this issue?
>> >Hi Richard,
>> >
>> >could you be more specific about which NIC you are using?
>> >And is it at all possible to test a newer kernel version?
>> >
>> >What I suspect is happening is that the NIC is getting into an unknown
>> >state. And what I'm hoping is that is a problem thats already been
>> >addressed.
>>
>> I would try a different kenerl but our cluster fs has us locked to
>> this kernel until we finish the upgrade to the new cluster fs
>> version. heres ethtool on the iface
>> 
>> from lshw
>> *-network
>>                 description: Ethernet interface
>>                 product: NetXtreme BCM5721 Gigabit Ethernet PCI Express
>>                 vendor: Broadcom Corporation
>>                 physical id: 0
>>                 bus info: pci@0000:03:00.0
>>                 logical name: eth0
>>                 version: 21
>>                 serial: 00:25:64:3b:9c:ae
>>                 size: 1GB/s
>>                 capacity: 1GB/s
>>                 width: 64 bits
>>                 clock: 33MHz
>>                 capabilities: pm vpd msi pciexpress bus_master
>> cap_list ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt
>> 1000bt-fd autonegotiation
>>                 configuration: autonegotiation=on broadcast=yes
>> driver=tg3 driverversion=3.93 duplex=full firmware=5721-v3.65,
>> ASFIPMI v6.25 ip=172.16.1.123 latency=0 link=yes module=tg3
>> multicast=yes port=twisted pair speed=1GB/s
>
> Hi Richard,
>
> first, please don't top-post, its not the done thing in these parts.
>
> I had a quick hunt through the git change log and the onl changed that
> jumped out was "[TG3]: Fix msi issue with kexec/kdump"[1], but this
> seems to have been back-ported to the initrd-2.6.18-128.el5 (I assume
> you meant 5 not 6) kernel.
>
> [1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ee6a99b539a50b4e9398938a0a6d37f8bf911550
>
> In any case I strongly suspect that the problem is a kernel problem and as
> such can't be solved modifying the kernel or at least tg.ko module (which
> is probably in the initrd). I suggest logging bug report with Red Hat.

The classic workaround is to rmmod the driver before calling kexec.
Frequently driver remove methods used by rmmod are much more tested
then the shutdown methods used by kexec and reboot.


Eric
