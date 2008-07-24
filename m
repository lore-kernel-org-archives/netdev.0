From: Patrick McHardy <kaber@trash.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 14:03:50 +0200
Message-ID: <48886FA6.6050908@trash.net>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756995AbYGXMEZ@vger.kernel.org>
In-Reply-To: <20080724115957.GA25701@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
>> here's a new type of crash a -tip testbox triggered today:
>>
>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
>> IP: [<0000000000000000>] 0x0
>> PGD 0 
>> Oops: 0010 [1] PREEMPT 
>> CPU 0 
>> Pid: 5331, comm: ssh Not tainted 2.6.26 #21613
>> RIP: 0010:[<0000000000000000>]  [<0000000000000000>] 0x0
>> RSP: 0018:ffff88003b959a70  EFLAGS: 00010217
>> RAX: ffff88003b9ba91c RBX: ffff88003b9baac0 RCX: 0000000000000002
>> RDX: ffff88003b9baac0 RSI: 0000000000000014 RDI: ffff88003b9ba3d8
>> RBP: ffff88003b959a98 R08: ffff88003e434130 R09: ffff88003b9598b8
>> R10: 0000000000002000 R11: 00000000d85507ac R12: ffff88003b9ba3d8
>> R13: 0000000000000002 R14: ffff88003e06a020 R15: 0000000000000000
>> FS:  00007fb2b7806780(0000) GS:ffffffff80c1c180(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> CR2: 0000000000000000 CR3: 000000003b9e8000 CR4: 00000000000006a0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process ssh (pid: 5331, threadinfo ffff88003b958000, task ffff88003b99a000)
>> Stack:  ffffffff80777f25 ffff88003b959a98 ffffffff80c24170 ffff88003b959b28
>>  0000000000000004 ffff88003b959ae8 ffffffff80733107 ffff88003b959ab8
>>  ffff88003b9ba3d8 ffffffff80c1ed60 0000000000000004 ffff88003b9ba3d8
>> Call Trace:
>>  [<ffffffff80777f25>] ? ipv4_confirm+0x8d/0x122
>>  [<ffffffff80733107>] nf_iterate+0x43/0xa5

Does reverting 31d8519c fix this?
