From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 11:35:13 -0700
Message-ID: <CALCETrUs1js3Br81ZkiQnsuWduzOiqDe3aV0K_z_zw0znSuiag@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com> <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
 <20140416182530.GB550@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140416182530.GB550-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 11:25 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Apr 16, 2014 at 11:13:31AM -0700, Andy Lutomirski wrote:
>
> [..]
>> > Ok, so passing cgroup information is not necessarily a problem as long
>> > as it is not used for authentication. So say somebody is just logging
>> > all the client request and which cgroup client was in, that should not
>> > be a problem.
>>
>> Do you consider correct attribution of logging messages to be
>> important?  If so, then this is a kind of authentication, albeit one
>> where the impact of screwing it up is a bit lower.
>
> So not passing cgroup information makes attribution more correct. Just
> logging of information is authentication how? Both kernel and user space
> log message into /var/log/messages and kernel messages are prefixed with
> "kernel". So this somehow becomes are sort of authentication. I don't
> get it.

I did a bad job of explaining what I meant.

I think that, currently, log lines can be correctly attributed to the
kernel or to userspace, but determining where in userspace a log line
came from is a bit flaky.  One of the goals of these patches is to
make log attribution less flaky.  But if you want log attribution to
be completely correct, even in the presence of malicious programs,
then I think that the current patches aren't quite there.

Is the reason that you don't want to modify the senders because you
want users of syslog(3) to get the new behavior?  If so, I think it
would be nice to update glibc to fix that, but maybe the kernel should
cooperate, and maybe SO_PEERCGROUP is a decent way to handle this.

I still think that SO_PASSCGROUP, as currently designed, is problematic.
