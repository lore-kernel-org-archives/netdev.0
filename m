From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 08:14:09 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729224724.91A3A4B7F@lists.samba.org>
References: <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca>
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: Your message of "Mon, 29 Jul 2002 06:57:20 -0400."
             <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

In message <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca> you writ
e:
> > Connection tracking:
> 
> Fix perfomance problems with this thing. You may have seen reports of
> performance degradation it introduces. I was hoping to take a look at some
> point time hasnt been visiting this side.

There are several simple things to do here.  One is to improve the
hashing (fine for internet traffic, but frequently sucks under LAN
conditions), which is easy.  The other is to modify the
one-timer-per-connection approach to a "sweep once a second, or when
full" approach.

Both these are simple patches, but I want to see benchmarks showing
that they improve things.

> > iptables:
> > 	o Change over to a netlink interface
> > 		o Back to add/delete/replace interface + commit.
> > 	o Rewrite libiptc to use netlink (to port iptables).
> 
> I hope this resolves the current scheme where the whole
> add/delete/replace interface + commit happens in user space?
> If you use netlink it would make sense to do incremental updates to the
> kernel.

Yes, that's exactly the plan.  It'd be more like the old-style
insert/delete (probably not replace), except with a "commit"
interface, implemented by copying the rules when they start modifying.

Hope that helps,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
