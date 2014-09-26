From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Fri, 26 Sep 2014 13:45:25 -0700
Message-ID: <87tx3uun4q.fsf@x220.int.ebiederm.org>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>
	<54228D87.3070309@6wind.com>
	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>
	<5422F0F4.6000709@6wind.com>
	<CAHA+R7Ot2kLHb+ne5AW3bFNc87qkFOiEHEyDh9sFrsHqXgrY3g@mail.gmail.com>
	<5423D80B.9060500@6wind.com>
	<CAHA+R7Ooyam2L-QfP-TjMEZEOqrQcQDxYiebmw760kgEji4G=g@mail.gmail.com>
	<54256CCB.4000709@6wind.com> <5425BB3E.10700@gmail.com>
	<87mw9myy4n.fsf@x220.int.ebiederm.org> <5425C22F.7050301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: David Ahern <lxhacker68-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5425C22F.7050301-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (David Ahern's message of "Fri, 26
	Sep 2014 13:44:47 -0600")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Ahern <lxhacker68-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 9/26/14, 1:34 PM, Eric W. Biederman wrote:
>> When I wrote the "ip netns" support I never expected that all
>> applications would want to run in a specific network namespace.  All
>> that is needed is one socket per network namespace.
>
> Sure that is another option. But for a process to create a socket or
> thread in a second namespace it has to run as root -- CAP_SYS_ADMIN is
> needed for setns (or perhaps there is another way to create the socket
> or thread in the namespace).

To do anything other than simply listen on a netlink socket you also
have to be root.  So this is most cases that I am aware of this is a
don't care.  Especially for routing daemons.

If it becomes a common pain in writing network namespace aware
applications that the you have to be root just to open your listening
socket then that probably would be sufficient justification for the
socketat system call that I have I prototyped and then never did
anything with because at the time it was insufficiently interesting.

> Second, it still does not address the scalability problem. For example
> a single daemon providing service across 2k namespaces means it needs
> 2k listen sockets. From there a system could have 20, 30 or 50
> services running. Certainly lighter than a process per namespace, but
> not even close to ideal when talking about something like VRFs.

Ah.  You are talking about a system with 2k namespaces and 20-50
services providing services in all 2k namespaces. Something completely
different than the case of quagga you mentioned earlier.

I expect quagga would need one netlink control socket and one socket
listening to netlink events, and a tcp connection or two to remote bgp
servers in each network namespace.  In that case I don't see anything
except a small constant difference in ways it can be handled.

For your new example of a crazy number of servers running on a box each
of which is had one listening socket in each network namespace maybe
they will be idle most of the time in most network namespaces and the
overhead will be significant.  Shrug those applications don't appear to
exist so I can't say what would make a good design.

If someone writes them and describes what is going on we can see if the
current set of interfaces is ideal or problematics.  If there are
signifcantly better interfaces that can be provided in a maintainable
way I imagine the patches would be easily accepted.

But again this has nothing do with the peer netns work.  So if you have
something practical to contribute please start a new thread.

Eric
