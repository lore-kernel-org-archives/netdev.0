From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 16 Apr 2014 13:02:46 -0400
Message-ID: <1397667766.19767.440.camel@willson.li.ssimo.org>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
	 <20140416002010.GA5035@redhat.com>
	 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
	 <20140416.085743.1614257692560892039.davem@davemloft.net>
	 <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
	 <1397664837.19767.410.camel@willson.li.ssimo.org>
	 <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 09:31 -0700, Andy Lutomirski wrote:
> On Wed, Apr 16, 2014 at 9:13 AM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, 2014-04-16 at 07:37 -0700, Andy Lutomirski wrote:
> >> On Wed, Apr 16, 2014 at 5:57 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> >> >
> >> > Please, just stop.
> >>
> >> No.
> >>
> >> This thread is proposing an ABI.  This means that, if the ABI ends up
> >> in Linus's kernel, then it has to be supported forever.  Now is the
> >> time to find and fix any issues with it before they become much harder
> >> to fix.
> >
> > Ok, but so far I haven't seen a single objection from you that has solid
> > grounds.
> 
> CVE-2013-1959 was caused by a new kernel feature causing a call to
> write(2) to behave as though the caller was authenticating itself to
> something else where, in previous kernels, write(2) did not
> authenticate.
> 
> Admittedly cgroups aren't currently as important as uid, but if this
> changes, then SO_PASSCGROUP, as currently written, will have *exactly*
> the same problem.

Which is easy to foil by using SO_PEERCGROUP and find out who originally
opened the socket, which is why that is also available!

> > The only one that *may* be reasonable is the "secret" cgroup name one,
> > however nobody seem to come up with a reason why it is legitimate to
> > allow to keep cgroup names secret.
> >
> > And if you can come up with such a good reason the SO_NOPASSCGROUP
> > option seem the right solution.
> >
> >> This ABI is especially tricky because programs will use it even if
> >> they don't explicitly try to.  So just adding the ABI may break
> >> existing assumptions that are relevant to security or correctness.
> >
> > It's not clear to me what you mean by this, either you explicitly use
> > SO_PASSCGROUP or not, it's not like you can involuntarily add a flag ...
> >
> 
> The issue here is that the receiver sets SO_(PASS|PEER)CGROUP, forcing
> the sender to identify or authenticate itself.  The sender might not
> want to identify itself.

You need to explain, why, on a host, when an application connects to
another, it is ok to make it anonymous. If you do not want to expose
yourself, do not talk to other applications in the first place.

>   Even if you don't buy any secrecy arguments,

I don't.

> the sender might not intend to authenticate.  Certainly no existing
> callers of connect or write intend to authenticate using their cgroup,
> since current kernels don't have those semantics.

This is a passive check, it's the receiver that wants to make decisions
about who is connecting, again if you do not want to "disclose"
information do not connect in the first place ?

In the rare case where you may have a legitimate reason to conceal a
process, it will be very simply for the admin to set up a proxy process
that will just terminate the original sender's identity and present only
the proxy identity to the receiver and perform message passing between 2
sockets.

So I rest my case.

Simo.
