From: Dmitry Vyukov via Virtualization
	<virtualization@lists.linux-foundation.org>
Subject: Re: BUG: unable to handle kernel paging request in vsock_diag_dump
Date: Thu, 26 Oct 2017 10:33:35 +0200
Message-ID: <CACT4Y+ZVLhUnZam5U2Vsti2CVo50_kkHMC5-V+H51ockRfyroA@mail.gmail.com>
References: <001a113f99fe969d68055c4c63a3@google.com>
	<20171026081852.GA31901@stefanha-x1.localdomain>
Reply-To: Dmitry Vyukov <dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzbot
	<bot+d6b6d5e0ac5609c835098f88c893a7bb3cfa0900@syzkaller.appspotmail.com>,
	syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20171026081852.GA31901@stefanha-x1.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2017 at 10:18 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> On Tue, Oct 24, 2017 at 08:14:01AM -0700, syzbot wrote:
>> Hello,
>>
>> syzkaller hit the following crash on
>> 28f50eb20931f32a2ceeb6aba8fa2cd5ca96ad9f
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>> C reproducer is attached
>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>> for information about syzkaller reproducers
>>
>>
>> IP: read_pnet include/net/net_namespace.h:269 [inline]
>> IP: sock_net include/net/sock.h:2299 [inline]
>> IP: vsock_diag_dump+0x290/0xa80 net/vmw_vsock/diag.c:87
>
> Feel free to ignore my previous reply, Cong Wang
> <xiyou.wangcong@gmail.com> has already found the root cause.  Thank you!


Hi Stefan,

For future reference, you can recreate the build by using the provided
config, running make olddefconfig and building with compiler
referenced here:
https://github.com/google/syzkaller/blob/master/docs/syzbot.md#crash-does-not-reproduce
Also syzbot has obtained the provided crash report on the provided
reproducer on a freshly-booted machine, so the reproducer worked for
it somehow. You still may have a somewhat different setup, so it won't
reproduce for you, but I have high assurance that the reproducer is
valid.

Also please don't ignore this part. It will greatly help to keep the
whole process running. Otherwise the bot won't be able to provide all
crashes it finds.

> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> Note: all commands must start from beginning of the line.

Thanks
