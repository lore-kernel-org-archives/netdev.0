From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Tue, 6 Dec 2016 10:13:53 -0800
Message-ID: <CALCETrUmwPaWbN_U2XAsg6Z0UGBJ=Ou7BoD09-GZFdRVT5Y-EQ@mail.gmail.com>
References: <1478647728-30357-1-git-send-email-john.stultz@linaro.org>
 <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com> <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com>
 <20161206165519.GA17648@mtj.duckdns.org> <CALCETrV3Yrq1hRcoGCTU_z-T-6hmq-gY-HytR2HGkvnRK-W1SQ@mail.gmail.com>
 <20161206181221.GA2625@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Stultz <john.stultz@linaro.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S. Miller" <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>,
        Harald Hoyer <harald@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Li Zefan <lizefan@huawei.com>,
        Jonathan Corbet <corbet@lwn.net>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        Android Kernel Team <kernel-team@android.com>,
        Rom Lemarchand <romlem@android.com>,
        Colin Cross <ccross@android.com>,
        Dmitry Shmidt
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161206181221.GA2625@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2016 at 10:12 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Tue, Dec 06, 2016 at 09:01:17AM -0800, Andy Lutomirski wrote:
>> How would one be granted the right to move processes around in one's
>> own subtree?
>
> Through expicit delegation - chowning of the directory and
> cgroup.procs file.
>
>> Are you imagining that, if you're in /a/b and you want to move a
>> process that's currently in /a/b/c to /a/b/d then you're allowed to
>> because the target process is in your tree?  If so, I doubt this has
>> the security properties you want -- namely, if you can cooperate with
>> anyone in /, even if they're unprivileged, you can break it.
>
> Delegation is an explicit operation and reflected in the ownership of
> the subdirectories and cgroup interface files in them.  The
> subhierarchy containment is achieved by requiring the user who's
> trying to migrate a process to have write perm on cgroup.procs on the
> common ancestor of the source and target in addition to the target.

OK, I see what you're doing.  That's interesting.
