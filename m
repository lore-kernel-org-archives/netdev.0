From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 17 Apr 2014 14:50:23 -0400
Message-ID: <20140417185023.GA32527@redhat.com>
References: <CALCETrUrj2LtAoXp600BD2ANgE2UUEbTYQrK8hHqDR=qpeFPcg@mail.gmail.com>
 <1397751853.2628.50.camel@willson.li.ssimo.org>
 <CALCETrWNWvumFg9Qba0GEOjYop4WYe530tCPtakrhnoCrHqhUQ@mail.gmail.com>
 <1397753323.2628.60.camel@willson.li.ssimo.org>
 <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
 <20140417171256.GB25334@redhat.com>
 <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
 <1397756025.2628.64.camel@willson.li.ssimo.org>
 <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
 <1397759013.2628.86.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397759013.2628.86.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 17, 2014 at 02:23:33PM -0400, Simo Sorce wrote:
> On Thu, 2014-04-17 at 10:35 -0700, Andy Lutomirski wrote:
> > On Thu, Apr 17, 2014 at 10:33 AM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Thu, 2014-04-17 at 10:26 -0700, Andy Lutomirski wrote:
> > >>
> > >> Not really.  write(2) can't send SCM_CGROUP.  Callers of sendmsg(2)
> > >> who supply SCM_CGROUP are explicitly indicating that they want their
> > >> cgroup associated with that message.  Callers of write(2) and send(2)
> > >> are simply indicating that they have some bytes that they want to
> > >> shove into whatever's at the other end of the fd.
> > >
> > > But there is no attack vector that passes by tricking setuid binaries to
> > > write to pre-opened file descriptors on sendmsg(), and for the other
> > > cases (connected socket) journald can always cross check with
> > > SO_PEERCGROUP, so why do we care again ?
> > 
> > Because the proposed code does not do what I described, at least as
> > far I as I can tell.
> 
> Ok let me backtrack, apparently if you explicitly use connect() on a
> datagram socket then you *can* write() (thanks to Vivek for checking
> this).
> 
> So you can trick something to write() to it but you can't do
> SO_PEERCGROUP on the other side, because it is not really a connected
> socket, the connection is only faked on the sender side by constructing
> sendmsg() messages with the original address passed into connect().
> 
> So given this unfortunate circumstance, requiring the client to
> explicitly pass cgroup data on unix datagram sockets may be an
> acceptable request IMO.
> 
> Perhaps this could be done with a sendmsg() header flag or simplified
> ancillary data even, rather than forcing the sender process to retrieve
> and construct the whole information which is already available in
> kernel.

So what would be the protocol here? When should somebody send an
SCM_CGROUP message using sendmsg()?

Thanks
Vivek
