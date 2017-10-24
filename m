From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: general protection fault in __list_del_entry_valid
Date: Tue, 24 Oct 2017 19:11:43 +0200
Message-ID: <CACT4Y+ay=w9NAKr8Pmkt-5Gbuuj5KBVrun_HweJz9dq-zqwAZQ@mail.gmail.com>
References: <f403043cb57c0ee302055c4c2e3c@google.com> <CACT4Y+ZFWVLJ_TKw7RKAsybK8vBSpYhpmS=ObSSKn3s5azxn-Q@mail.gmail.com>
 <CAM_iQpUv1SYMWMMhM1xDTfT8nVD+6oV-F-4nhEBxJe7TWoEwJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: syzbot
        <bot+b3b21cb3f2c95ba434f66810d52abd04c99b877e@syzkaller.appspotmail.com>,
        David Miller <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        syzkaller-bugs@googlegroups.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUv1SYMWMMhM1xDTfT8nVD+6oV-F-4nhEBxJe7TWoEwJQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 7:06 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Oct 24, 2017 at 8:02 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Tue, Oct 24, 2017 at 4:59 PM, syzbot
>> <bot+b3b21cb3f2c95ba434f66810d52abd04c99b877e@syzkaller.appspotmail.com>
>> wrote:
>>> Hello,
>>>
>>> syzkaller hit the following crash on
>>> aa69ff9e9c32db8aa84835baffea1b70c39e5112
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
>>> compiler: gcc (GCC) 7.1.1 20170620
>>> .config is attached
>>> Raw console output is attached.
>>> C reproducer is attached
>>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>>> for information about syzkaller reproducers
>>
>> This also happened on more recent commits, including net-next
>> 33ad61d0f799656e8987e9c80e6e15151bb857f3 (Oct 20), with similar
>> signature:
>>
>> general protection fault: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 1 PID: 17 Comm: kworker/1:0 Not tainted 4.14.0-rc5+ #89
>> Hardware name: Google Google Compute Engine/Google Compute Engine,
>> BIOS Google 01/01/2011
>> Workqueue: events netlink_sock_destruct_work
>> task: ffff8801d9f94480 task.stack: ffff8801d9fa0000
>> RIP: 0010:__list_del_entry_valid+0x7e/0x150 lib/list_debug.c:51
>> RSP: 0018:ffff8801d9fa70b8 EFLAGS: 00010246
>> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
>> RDX: 0000000000000000 RSI: ffff8801cb186b60 RDI: ffff8801cb186b68
>> RBP: ffff8801d9fa70d0 R08: ffffffff84248f02 R09: 0000000000000000
>> R10: ffff8801d9fa6f98 R11: ffff8801ca127a10 R12: 0000000000000000
>> R13: ffff8801d9fa7198 R14: ffff8801ca1279f8 R15: ffff8801cb186b68
>> FS:  0000000000000000(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000020000000 CR3: 00000001c17a4000 CR4: 00000000001406e0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> Call Trace:
>>  __list_del_entry include/linux/list.h:116 [inline]
>>  list_del include/linux/list.h:124 [inline]
>>  xfrm_policy_walk_done+0xfa/0x310 net/xfrm/xfrm_policy.c:1048
>>  xfrm_dump_policy_done+0x73/0xa0 net/xfrm/xfrm_user.c:1699
>>  netlink_sock_destruct+0xfa/0x3c0 net/netlink/af_netlink.c:362
>>  __sk_destruct+0xfd/0x910 net/core/sock.c:1560
>>  sk_destruct+0x47/0x80 net/core/sock.c:1595
>>  __sk_free+0x57/0x230 net/core/sock.c:1603
>>  sk_free+0x2a/0x40 net/core/sock.c:1614
>>  netlink_sock_destruct_work+0x19/0x20 net/netlink/af_netlink.c:384
>>  process_one_work+0xbf0/0x1bc0 kernel/workqueue.c:2119
>>  worker_thread+0x223/0x1860 kernel/workqueue.c:2253
>>  kthread+0x35e/0x430 kernel/kthread.c:231
>
> I think this is probably fixed by:

Ah! I guess also syzkaller :)

> [PATCH 2/2] ipsec: Fix aborted xfrm policy dump crash

Can you please follow this part of the guideline? This will greatly
help keeping the overall process working. Thanks!

> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> Note: all commands must start from beginning of the line.
