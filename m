From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [Bugme-new] [Bug 13954] New: Oops in rtnetlink code when creating
 can device
Date: Tue, 11 Aug 2009 09:52:52 +0200
Message-ID: <4A812354.8090704@volkswagen.de>
References: <bug-13954-10286@http.bugzilla.kernel.org/> <20090810215436.0bf47297.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, kaber@trash.net,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:6968 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbZHKNC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 09:02:27 -0400
In-Reply-To: <20090810215436.0bf47297.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Mon, 10 Aug 2009 11:34:28 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
>
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=13954
>>     
>
> Thanks.
>
>   
>>            Summary: Oops in rtnetlink code when creating can device
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.30-rc5
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: dbaryshkov@gmail.com
>>         Regression: No
>>
>>
>> I've got a nice oops when looking around new CAN code in kernel.
>>
>> root@qemux86:~# ip link add type can
>> [  713.113325] BUG: unable to handle kernel NULL pointer dereference at (null)
>> [  713.114216] IP: [<c13eecab>] register_netdevice+0xab/0x420
>> [  713.114920] *pdpt = 00000000061bd001 *pde = 0000000000000000 
>> [  713.115627] Oops: 0000 [#1] SMP 
>> [  713.115972] last sysfs file:
>> /sys/devices/virtual/backlight/fujitsu-laptop/brightness
>> [  713.116137] Modules linked in:
>> [  713.116137] 
>> [  713.116137] Pid: 1803, comm: ip Not tainted (2.6.31-rc5 #68) 
>> [  713.116137] EIP: 0060:[<c13eecab>] EFLAGS: 00000246 CPU: 0
>> [  713.116137] EIP is at register_netdevice+0xab/0x420
>> [  713.116137] EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000001
>> [  713.116137] ESI: c72c6000 EDI: 00000000 EBP: c61abb54 ESP: c61abb34
>> [  713.116137]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>> [  713.116137] Process ip (pid: 1803, ti=c61aa000 task=c6f395e0
>> task.ti=c61aa000)
>> [  713.116137] Stack:
>> [  713.116137]  c61abb54 c13f732f 00000001 c61abbb4 894f908a 00000000 c72c6000
>> 00000000
>> [  713.116137] <0> c61abc74 c13f8278 c61abbb4 00000010 c165d494 c1652090
>> c61abc18 c6f3d028
>> [  713.116137] <0> 894f908a 894f908a c61abc18 c13f7da0 c61abc74 c13f7f46
>> 00000008 c1546f80
>> [  713.116137] Call Trace:
>> [  713.116137]  [<c13f732f>] ? rtnl_create_link+0x4f/0x130
>> [  713.116137]  [<c13f8278>] ? rtnl_newlink+0x4d8/0x4e0
>> [  713.116137]  [<c13f7da0>] ? rtnl_newlink+0x0/0x4e0
>> [  713.116137]  [<c13f7f46>] ? rtnl_newlink+0x1a6/0x4e0
>> [  713.116137]  [<c13f7da0>] ? rtnl_newlink+0x0/0x4e0
>> [  713.116137]  [<c13f7d00>] ? rtnetlink_rcv_msg+0x180/0x220
>> [  713.116137]  [<c13f7b80>] ? rtnetlink_rcv_msg+0x0/0x220
>> [  713.116137]  [<c1400e56>] ? netlink_rcv_skb+0x86/0xb0
>> [  713.116137]  [<c13f7b5a>] ? rtnetlink_rcv+0x2a/0x50
>>     

The problem is, that

ip link add type can

is not possible as you can not create 'real' CAN devices like can0, 
can1, ...

To create 'software CAN devices' like vcan0, vcan1, vcan2, ... we use

ip link add type vcan

see drivers/net/can/vcan.c

---

For real hardware CAN devices the netlink interface is only used for the 
configuration of already existing interfaces.
 From a quick view on the rtnl_newlink() function in 
net/core/rtnetlink.c i was not able to find any method to disallow the 
creation of  interfaces, will say: How can a netlink user provide the 
information, that he's not able to create new devices via netlink???

@Patrick: Do you have an idea for this? Is it a new use-case for netlink 
that needs to be implemented?

Regards,
Oliver

