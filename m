From: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v3 21/22] netoops: Add user-programmable boot_id
Date: Tue, 14 Dec 2010 16:47:44 -0600
Message-ID: <1292366864.3446.875.camel@calx>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
	 <20101214213048.17022.58746.stgit@mike.mtv.corp.google.com>
	 <1292362957.3446.851.camel@calx>
	 <AANLkTi=Q+LaS7yaU_4ThkhMUM-q8S3JTuwMWqAikQPgH@mail.gmail.com>
	 <1292364378.3446.854.camel@calx>
	 <AANLkTineeFcSNx09P=2SZGcBHeq5p_LQ54nU=uGVv_Ck@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTineeFcSNx09P=2SZGcBHeq5p_LQ54nU=uGVv_Ck-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-12-14 at 14:33 -0800, Mike Waychison wrote:
> On Tue, Dec 14, 2010 at 2:06 PM, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> > On Tue, 2010-12-14 at 13:59 -0800, Mike Waychison wrote:
> >> On Tue, Dec 14, 2010 at 1:42 PM, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> >> > On Tue, 2010-12-14 at 13:30 -0800, Mike Waychison wrote:
> >> >> Add support for letting userland define a 32bit boot id.  This is useful
> >> >> for users to be able to correlate netoops reports to specific boot
> >> >> instances offline.
> >> >
> >> > This sounds a lot like the pre-existing /proc/sys/kernel/random/boot_id
> >> > that's used by kerneloops.org.
> >>
> >> Could be.  I'm looking at it now... There is no documentation for this
> >> boot_id field?
> >
> > Probably not. It's just a random number generated at boot.
> >
> >> Reusing this guy would work, except that it doesn't appear to allow
> >> arbitrary values to be set.  We need to inject our boot sequence
> >> number (which is figured out in userland) in the packet somehow as we
> >> need to correlate it to our other monitoring systems.
> >
> > What happens if you oops before userspace is available?
> >
> 
> Either one of two general cases:
>   - The crash is a one-off and the machine comes back.  The boot
> number sequence will see a hole in it, which is a clue that something
> bad happened.
>   - The machine is in a crash loop.  This has the same failure mode
> for us as if the machine never made it onto the network due to
> whatever reason: bad cables, bad firmware, bad ram, ...
> 
> In both cases, we can detect that something is wrong and handle it.
> Note that our firmware is responsible for incrementing the boot
> sequence at bootup, which is why the above works.   In general though,
> our machines do make it up to userland -- staying alive once booted is
> the hard part ;)

Interesting. Is this Google-specific firmware magic? I'd probably accept
a hook in random.c to fold a number into the UUID, which would unify
things. 

-- 
Mathematics is the supreme nostalgia of our time.
