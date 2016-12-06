From: John Stultz <john.stultz@linaro.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Mon, 5 Dec 2016 16:28:54 -0800
Message-ID: <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
References: <1478647728-30357-1-git-send-email-john.stultz@linaro.org>
 <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com> <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S. Miller" <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>,
        Harald Hoyer <harald@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        lkml <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Li Zefan <lizefan@huawei.com>,
        Jonathan Corbet <corbet@lwn.net>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        Android Kernel Team <kernel-team@android.com>,
        Rom Lemarchand <romlem@android.com>,
        Colin Cross <ccross@android.com>,
        Dmitry Shmidt <dimitrysh@google.
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 4:57 PM, John Stultz <john.stultz@linaro.org> wrote:
> On Tue, Nov 8, 2016 at 4:12 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Tue, Nov 8, 2016 at 4:03 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>>> On Tue, Nov 08, 2016 at 03:51:40PM -0800, Andy Lutomirski wrote:
>>>>
>>>> I hate to say it, but I think I may see a problem.  Current
>>>> developments are afoot to make cgroups do more than resource control.
>>>> For example, there's Landlock and there's Daniel's ingress/egress
>>>> filter thing.  Current cgroup controllers can mostly just DoS their
>>>> controlled processes.  These new controllers (or controller-like
>>>> things) can exfiltrate data and change semantics.
>>>>
>>>> Does anyone have a security model in mind for these controllers and
>>>> the cgroups that they're attached to?  I'm reasonably confident that
>>>> CAP_SYS_RESOURCE is not the answer...
>>>
>>> and specifically the answer is... ?
>>> Also would be great if you start with specifying the question first
>>> and the problem you're trying to solve.
>>>
>>
>> I don't have a good answer right now.  Here are some constraints, though:
>>
>> 1. An insufficiently privileged process should not be able to move a
>> victim into a dangerous cgroup.
>>
>> 2. An insufficiently privileged process should not be able to move
>> itself into a dangerous cgroup and then use execve to gain privilege
>> such that the execve'd program can be compromised.
>>
>> 3. An insufficiently privileged process should not be able to make an
>> existing cgroup dangerous in a way that could compromise a victim in
>> that cgroup.
>>
>> 4. An insufficiently privileged process should not be able to make a
>> cgroup dangerous in a way that bypasses protections that would
>> otherwise protect execve() as used by itself or some other process in
>> that cgroup.
>>
>> Keep in mind that "dangerous" may apply to a cgroup's descendents in
>> addition to the cgroup being controlled.
>
> Sorry for taking awhile to get back to you here.  I'm a little
> befuddled as to what next steps I should consider (and honestly, I'm
> not totally sure I really grok your concern here, particularly what
> you mean with "dangrous cgroups").
>
> So is going back to the CAP_CGROUP_MIGRATE approach (to properly
> separate "sufficiently" from "insufficiently privileged") better?
>
> Or something closer to the original method Android used of each cgroup
> having an allow_attach() check which could determine what is
> sufficiently privledged for the respective level of danger the cgroup
> might poise?
>
> Or just stepping back, what method would you imagine to be reasonable
> to allow a specified task to migrate other tasks between cgroups
> without it having to be root/suid?

Any suggested feedback here?

thanks
-john
