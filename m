From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri, 4 Dec 2015 11:40:02 +0100
Message-ID: <CACT4Y+Z68wnWjFZ6e2AmePBNu1U+V9N_4szdyNrrf710Er2zyg@mail.gmail.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <20151203130525.GB4164@mrl.redhat.com> <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
 <f7twpsvgyar.fsf@aconole.bos.csb> <566098BD.6010803@akamai.com>
 <1449172984.12092.0.camel@perches.com> <5660A1A7.3080301@akamai.com>
 <1449174246.12092.8.camel@perches.com> <5660A951.4000808@akamai.com> <1449175884.17296.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Baron <jbaron@akamai.com>, Aaron Conole <aconole@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449175884.17296.2.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 3, 2015 at 9:51 PM, Joe Perches <joe@perches.com> wrote:
> (adding lkml as this is likely better discussed there)
>
> On Thu, 2015-12-03 at 15:42 -0500, Jason Baron wrote:
>> On 12/03/2015 03:24 PM, Joe Perches wrote:
>> > On Thu, 2015-12-03 at 15:10 -0500, Jason Baron wrote:
>> > > On 12/03/2015 03:03 PM, Joe Perches wrote:
>> > > > On Thu, 2015-12-03 at 14:32 -0500, Jason Baron wrote:
>> > > > > On 12/03/2015 01:52 PM, Aaron Conole wrote:
>> > > > > > I think that as a minimum, the following patch should be evaluted,
>> > > > > > but am unsure to whom I should submit it (after I test):
>> > > > []
>> > > > > Agreed - the intention here is certainly to have no side effects. It
>> > > > > looks like 'no_printk()' is used in quite a few other places that would
>> > > > > benefit from this change. So we probably want a generic
>> > > > > 'really_no_printk()' macro.
>> > > >
>> > > > https://lkml.org/lkml/2012/6/17/231
>> > >
>> > > I don't see this in the tree.
>> >
>> > It never got applied.
>> >
>> > > Also maybe we should just convert
>> > > no_printk() to do what your 'eliminated_printk()'.
>> >
>> > Some of them at least.
>> >
>> > > So we can convert all users with this change?
>> >
>> > I don't think so, I think there are some
>> > function evaluation/side effects that are
>> > required.  I believe some do hardware I/O.
>> >
>> > It'd be good to at least isolate them.
>> >
>> > I'm not sure how to find them via some
>> > automated tool/mechanism though.
>> >
>> > I asked Julia Lawall about it once in this
>> > thread:  https://lkml.org/lkml/2014/12/3/696
>> >
>>
>> Seems rather fragile to have side effects that we rely
>> upon hidden in a printk().
>
> Yup.
>
>> Just convert them and see what breaks :)
>
> I appreciate your optimism.  It's very 1995.
> Try it and see what happens.


Whatever is the resolution for pr_debug, we still need to fix this
particular use-after-free. It affects stability of debug builds, gives
invalid debug output, prevents us from finding more bugs in SCTP. And
maybe somebody uses CONFIG_DYNAMIC_DEBUG in production.
