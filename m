From: Andrei Sharaev <aosharaev@telecom.by>
Subject: Re: Backport patch from 4.2 to 3.18
Date: Mon, 4 Apr 2016 12:05:12 +0300
Message-ID: <57022E48.5030008@telecom.by>
References: <56D9F2C3.3030204@telecom.by> <56D9FD6A.4060107@oracle.com>
 <56E6EA59.5020302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sasha Levin <sasha.levin@oracle.com>,
	stable <stable@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <56E6EA59.5020302@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Could you help with this problem?

--=20
Best regards,
Andrei Sharaev
BYAS-RIPE
ISP Atlant Telecom
aosharaev@telecom.by

14.03.2016 19:44, Sasha Levin =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 03/04/2016 04:26 PM, Sasha Levin wrote:
>> On 03/04/2016 03:40 PM, Andrei Sharaev wrote:
>>>> Hi Sasha,
>>>>
>>>> Can you backport this patch for "inet-frag-fixes" to linux kernel =
3.18 LTS?
>>>> http://kernel.suse.com/cgit/kernel/commit/?h=3Dv4.2-rc5&id=3D64b89=
2ad2326348a5b8314167590d240e3bcc69e
>>>>
>>>> I get 1-5 kernel panics in month for linux kernels 3.18.24-3.18.26=
 at my NAT server with big IPv4 traffic (10-15 Gbps).
>>>> My kernel panics have similar symptoms:
>>>>>> <82>general protection fault: 0000 [#1] SMP
>>>>>> <82>Modules linked in: bonding ipt_NETFLOW(O) xt_recent configfs=
 x86_pkg_temp_thermal ixgbe(O)
>>>>>> <86>CPU: 13 PID: 29908 Comm: kworker/13:2 Tainted: G          IO=
   3.18.26 #1
>>>>>> <86>Hardware name: Intel Corporation S2600WT2/S2600WT2, BIOS SE5=
C610.86B.01.01.0005.101720141054 10/17/2014
>>>>>> <82>Workqueue: events inet_frag_worker
>>>>>> <86>task: ffff88046cdba9a0 ti: ffff880454928000 task.ti: ffff880=
454928000
>>>>>> <82>RIP: 0010:[<ffffffff815b91d9>]  [<ffffffff815b91d9>] inet_ev=
ict_bucket+0x109/0x160
>>>>>> <86>RSP: 0018:ffff88045492bd38  EFLAGS: 00010286
>>>>>> <86>RAX: ffff880441d0e001 RBX: dead0000001000c0 RCX: 00000001803=
0002e
>>>>>> <86>RDX: 000000018030002f RSI: ffff880441d0e000 RDI: dead0000001=
000c0
>>>>>> <86>RBP: ffff88045492bd88 R08: 0000000000000000 R09: ffff88086cc=
88500
>>>>>> <86>R10: ffff88046fdb5c50 R11: ffffea0011074380 R12: 00000000000=
00002
>>>>>> <86>R13: ffffffff81e02200 R14: 0000000000000000 R15: ffff88083f0=
942a0
>>>>>> <86>FS:  0000000000000000(0000) GS:ffff88046fda0000(0000) knlGS:=
0000000000000000
>>>>>> <86>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>>>> <86>CR2: 00007fab8f466000 CR3: 000000085f66d000 CR4: 00000000001=
407e0
>>>>>> <86>Stack:
>>>>>> <82> ffffffff81e05a78 ffffffff81e05a70 ffff88046cdba9a0 ffff8808=
3f0942e0
>>>>>> <82> ffff88046f808c00 0000000000000079 ffffffff81e02200 ffffffff=
81e06200
>>>>>> <82> 0000000000000388 0000000000000007 ffff88045492bdf8 ffffffff=
815b928a
>>>>>> <86>Call Trace:
>>>>>> <82> [<ffffffff815b928a>] inet_frag_worker+0x5a/0x230
>>>>>> <82> [<ffffffff8105808d>] process_one_work+0x12d/0x330
>>>>>> <82> [<ffffffff8105892b>] worker_thread+0x4b/0x450
>>>>>> <82> [<ffffffff810588e0>] ? cancel_delayed_work_sync+0x10/0x10
>>>>>> <82> [<ffffffff8105cd34>] kthread+0xc4/0xe0
>>>>>> <82> [<ffffffff81060c59>] ? finish_task_switch+0x49/0xc0
>>>>>> <82> [<ffffffff8105cc70>] ? kthread_create_on_node+0x170/0x170
>>>>>> <82> [<ffffffff81603d88>] ret_from_fork+0x58/0x90
>>>>>> <82> [<ffffffff8105cc70>] ? kthread_create_on_node+0x170/0x170
>>>>>> <82>Code: f6 0f 85 73 ff ff ff 48 8b 45 b8 80 40 08 01 48 8b 7d =
c8 48 85 ff 74 23 48 83 ef 40 75 0d eb 1b 66 90 48 83 eb 40 48 89 df 74=
 10 <48> 8b 5f 40 41 ff 95 70 40 00 00 48 85 db 75 e7 48 83 c4 28 44
>>>>>> <22>RIP  [<ffffffff815b91d9>] inet_evict_bucket+0x109/0x160
>>>>>> <82> RSP <ffff88045492bd38>
>> Hey Andrei,
>>
>> Thanks for the report.
>>
>> Usually David Miller (Cc'ed) handles backporting network commits. In=
 this case, I see
>> that he has elected not to backport it into 4.1 or 3.18, so I don't =
want to do it without
>> getting an ack from him first.
>>
>> David, is it ok to backport these commits back to 3.18 (and probably=
 4.1)?
> Ping?
