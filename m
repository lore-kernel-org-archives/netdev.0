From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Thu, 8 Dec 2016 21:39:38 -0800
Message-ID: <CALAqxLUkqSAEiHE038w+ZGUmhPgj2SpG7BLcPrrtU46VYcO=KA@mail.gmail.com>
References: <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com> <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com>
 <20161206165519.GA17648@mtj.duckdns.org> <CALCETrV3Yrq1hRcoGCTU_z-T-6hmq-gY-HytR2HGkvnRK-W1SQ@mail.gmail.com>
 <20161206181221.GA2625@mtj.duckdns.org> <CALCETrUmwPaWbN_U2XAsg6Z0UGBJ=Ou7BoD09-GZFdRVT5Y-EQ@mail.gmail.com>
 <20161206182315.GB2625@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kafai-b10kYP2dOMg@public.gmane.org,
        Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
        Harald Hoyer <harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Rom Lemarchand <romlem-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Dmitry Shmid
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161206182315.GB2625-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2016 at 10:23 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> On Tue, Dec 06, 2016 at 10:13:53AM -0800, Andy Lutomirski wrote:
>> > Delegation is an explicit operation and reflected in the ownership of
>> > the subdirectories and cgroup interface files in them.  The
>> > subhierarchy containment is achieved by requiring the user who's
>> > trying to migrate a process to have write perm on cgroup.procs on the
>> > common ancestor of the source and target in addition to the target.
>>
>> OK, I see what you're doing.  That's interesting.
>
> It's something born out of usages of cgroup v1.  People used it that
> way (chowning files and directories) and combined with the uid checksn
> it yielded something which is useful sometimes, but it always had
> issues with hierarchical behaviors, which files to chmod and the weird
> combination of uid checks.  cgroup v2 has a clear delegation model but
> the uid checks are still left in as not changing was the default.
>
> It's not necessary and I'm thinking about queueing something like the
> following in the next cycle.
>
> As for the android CAP discussion, I think it'd be nice to share an
> existing CAP but if we can't find a good one to share, let's create a
> new one.

So just to clarify the discussion for my purposes and make sure I
understood, per-cgroup CAP rules was not desired, and instead we
should either utilize an existing cap (are there still objections to
CAP_SYS_RESOURCE? - this isn't clear to me) or create a new one (ie,
bring back the older CAP_CGROUP_MIGRATE patch).

Tejun: Do you have a more finished version of your patch that I should
add my changes on top of?

thanks
-john
