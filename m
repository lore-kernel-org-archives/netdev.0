From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: BUG: soft lockup happened for ixgbevf
Date: Thu, 3 Dec 2015 11:34:00 +0800
Message-ID: <565FB828.2060306@huawei.com>
References: <565D4860.2060108@huawei.com> <565DD804.1080503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"jeffrey.t.kirsher@intel.com >> Jeff Kirsher"
	<jeffrey.t.kirsher@intel.com>,
	"jesse.brandeburg@intel.com >> Jesse Brandeburg"
	<jesse.brandeburg@intel.com>,
	"bruce.w.allan@intel.com >> Bruce Allan" <bruce.w.allan@intel.com>,
	"donald.c.skidmore@intel.com >> Don Skidmore"
	<donald.c.skidmore@intel.com>, <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org >> Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:44726 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574AbbLCDfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 22:35:13 -0500
In-Reply-To: <565DD804.1080503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/12/2 1:25, Alexander Duyck wrote:
> On 11/30/2015 11:12 PM, Ding Tianhong wrote:
>> Hi Everyone:
>>
>> I found this problem when using the Testgine to send package to the =
82599 ethernet:
>> 1.wait for the speed to 10G/bit, it's ok.
>> 2.then down the eth and then up, loop for several times.
>> 3.then the softlockup happened.
>> [  317.005148] IPv6: ADDRCONF(NETDEV_CHANGE): eth2: link becomes rea=
dy
>> [  368.106005] BUG: soft lockup - CPU#1 stuck for 22s! [rcuos/1:15]
>> [  368.106005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [  368.106005] task: ffff88057dd8a220 ti: ffff88057dd9c000 task.ti: =
ffff88057dd9c000
>> [  368.106005] RIP: 0010:[<ffffffff81579e04>]  [<ffffffff81579e04>] =
fib_table_lookup+0x14/0x390
>> [  368.106005] RSP: 0018:ffff88061fc83ce8  EFLAGS: 00000286
>> [  368.106005] RAX: 0000000000000001 RBX: 00000000020155c0 RCX: 0000=
000000000001
>> [  368.106005] RDX: ffff88061fc83d50 RSI: ffff88061fc83d70 RDI: ffff=
880036d11a00
>> [  368.106005] RBP: ffff88061fc83d08 R08: 0000000000000001 R09: 0000=
000000000000
>> [  368.106005] R10: ffff880036d11a00 R11: ffffffff819e0900 R12: ffff=
88061fc83c58
>> [  368.106005] R13: ffffffff816154dd R14: ffff88061fc83d08 R15: 0000=
0000020155c0
>> [  368.106005] FS:  0000000000000000(0000) GS:ffff88061fc80000(0000)=
 knlGS:0000000000000000
>> [  368.106005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  368.106005] CR2: 00007f8c2aee9c40 CR3: 000000057b222000 CR4: 0000=
0000000407e0
>> [  368.106005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
>> [  368.106005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
>> [  368.106005] Stack:
>> [  368.106005]  00000000010000c0 ffff88057b766000 ffff8802e380b000 f=
fff88057af03e00
>> [  368.106005]  ffff88061fc83dc0 ffffffff815349a6 ffff88061fc83d40 f=
fffffff814ee146
>> [  368.106005]  ffff8802e380af00 00000000e380af00 ffffffff819e0900 0=
20155c0010000c0
>> [  368.106005] Call Trace:
>> [  368.106005]  <IRQ>
>> [  368.106005]
>> [  368.106005]  [<ffffffff815349a6>] ip_route_input_noref+0x516/0xbd=
0
>> [  368.106005]  [<ffffffff814ee146>] ? skb_release_data+0xd6/0x110
>> [  368.106005]  [<ffffffff814ee20a>] ? kfree_skb+0x3a/0xa0
>> [  368.106005]  [<ffffffff8153698f>] ip_rcv_finish+0x29f/0x350
>> [  368.106005]  [<ffffffff81537034>] ip_rcv+0x234/0x380
>> [  368.106005]  [<ffffffff814fd656>] __netif_receive_skb_core+0x676/=
0x870
>> [  368.106005]  [<ffffffff814fd868>] __netif_receive_skb+0x18/0x60
>> [  368.106005]  [<ffffffff814fe4de>] process_backlog+0xae/0x180
>> [  368.106005]  [<ffffffff814fdcb2>] net_rx_action+0x152/0x240
>> [  368.106005]  [<ffffffff81077b3f>] __do_softirq+0xef/0x280
>> [  368.106005]  [<ffffffff8161619c>] call_softirq+0x1c/0x30
>> [  368.106005]  <EOI>
>> [  368.106005]
>> [  368.106005]  [<ffffffff81015d95>] do_softirq+0x65/0xa0
>> [  368.106005]  [<ffffffff81077174>] local_bh_enable+0x94/0xa0
>> [  368.106005]  [<ffffffff81114922>] rcu_nocb_kthread+0x232/0x370
>> [  368.106005]  [<ffffffff81098250>] ? wake_up_bit+0x30/0x30
>> [  368.106005]  [<ffffffff811146f0>] ? rcu_start_gp+0x40/0x40
>> [  368.106005]  [<ffffffff8109728f>] kthread+0xcf/0xe0
>> [  368.106005]  [<ffffffff810971c0>] ? kthread_create_on_node+0x140/=
0x140
>> [  368.106005]  [<ffffffff816147d8>] ret_from_fork+0x58/0x90
>> [  368.106005]  [<ffffffff810971c0>] ? kthread_create_on_node+0x140/=
0x140
>>
>> I have test this on kernel 3.10 and kernel 4.3, both exist this prob=
lem.
>> Thanks for any suggestion.
>=20
> So I have a couple questions.  First what kernel was the above trace =
captured with?  Are you using the in-kernel driver or did you download =
one and build it out-of-tree?  If you are using the in-tree then I can =
assume the above trace is with kernel version 3.10 since the ixgbevf dr=
iver was fixed to not use the backlog several versions ago.
>=20
> Can you povide the trace for the 4.3 kernel?  It would greatly help a=
s the 3.10 kernel is a bit old and a reproduction on the 4.3 kernel or =
net-next would go a long way toward allowing us to figure out the root =
cause.
>=20
> Thanks.
>=20
> - Alex
>=20


Hi Alex=EF=BC=9A

Thanks for the message.

The above calltrace is from 3.10 kernel version indeed, and I will try =
to get the calltrace again for 4.3 which I missed already.
I check the ixbgevf drivers found that much different between 3.10 and =
4.3, so I am not sure whether they will met the same problem until I ge=
t the calltrace from 4.3,
so I will update the message as soon as possible, thanks.

Ding=20


>=20
> .
>=20
