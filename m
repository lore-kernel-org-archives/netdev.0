From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Tue, 6 Dec 2016 11:57:45 -0500
Message-ID: <20161206165745.GB17648@mtj.duckdns.org>
References: <1478647728-30357-1-git-send-email-john.stultz@linaro.org>
 <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com>
 <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com>
 <20161206020011.GA22261@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
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
        Colin Cro
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161206020011.GA22261-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Serge.

On Mon, Dec 05, 2016 at 08:00:11PM -0600, Serge E. Hallyn wrote:
> > I really don't know.  The cgroupfs interface is a bit unfortunate in
> > that it doesn't really express the constraints.  To safely migrate a
> > task, ISTM you ought to have some form of privilege over the task
> > *and* some form of privilege over the cgroup.
> 
> Agreed.  The problem is that the privilege required should depend on
> the controller (I guess).  For memory and cpuset, CAP_SYS_NICE seems
> right.  Perhaps CAP_SYS_RESOURCE would be needed for some..  but then,
> as I look through the lists (capabilities(7) and the list of controllers),
> it seems like CAP_SYS_NICE works for everything.  What else would we need?
> Maybe CAP_NET_ADMIN for net_cls and net_prio?  CAP_SYS_RESOURCE|CAP_SYS_ADMIN
> for pids?

Please see my other reply but I don't think it's a good idea to have
these extra checks on the side when there already is hierarchical
delegation mechanism which should be able to handle both resource
control and process management delegation.

Thanks.

-- 
tejun
