From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
	messages
Date: Wed, 15 Apr 2009 13:53:29 -0400
Message-ID: <20090415175329.GE21448@hmsreliant.think-freely.org>
References: <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org> <49E6172D.8080201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46483 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbZDORxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 13:53:45 -0400
Content-Disposition: inline
In-Reply-To: <49E6172D.8080201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 01:19:41PM -0400, Vlad Yasevich wrote:
> Neil Horman wrote:
> find the multicast in the socket's list.
> >>
> > Also see above, hes using multicast group 239.x.x.x.  SSM only encompases
> > addresses in the 232.0.0.1 to 232.255.255.255 range.  He's using ASM not SSM,
> > regardless of what SSM allows.  I agree it sounds like we have a bug in SSM
> > behavior, but its not overly relevant to this discussion (saving for the fact
> > that his new feature would inadvertantly fix the bug, in addition to altering
> > ASM behavior).  If we want to fix the SSM bug, thats great, lets fix it, but
> > lets not do it by introducing a new behavior to ASM.
> 
> Sorry, but I don't buy it.  What we have is essentially "backward-brokeness".
> 
> Looking at BSD, which was the root of the original brokeness, they have it fixed.
> The code will skip sockets that are not members of a particular group.  So, we
> are trying really hard to stay bug-for-bug compatible with old implementations.
> 

Despite your assertions, its not broken just because you call it such.  Its
working as its been documented.  If BSD has changed, I'll go look, and as I've
said several times in this thread, if this makes porting from other os'es
easier, than this has legs.  You're the first to have pointed one out, so thank
you.  Regardless however, that doesn't make the current behavior broken.

> > 
> > And thats all moot anyway, becaues Christoph (unless I'm mistaken) is not, and
> > does not want to restrict source sending privlidges.  He wants to get data on
> > multicast groups from all/any source, he just doesn't want to get multicast data
> > from groups he didn't explicitly join in the app doing the receiving, which is
> > exactly what you can currently use bind for.
> 
> Let's look at it the other way.  What is broken if we actually filter based on the
> socket group membership?  The only applications that will be impacted are ones that
> do not join groups themselves and expect to get multicast traffic.  Such applications
> are broken to start with.
> 
I can easily envision on application which expects to get multicast traffic that
doesn't join a group within the context of its own process, specifically relying
on the behavior as its documented today.  Consider a data processing
application whos group management is segmented into a different utility.  This
is really the problem here though isn't it?  A proposal to change the 20 year
old behavior of multicast reception with no way to know how strongly
applications rely on this behavior and no documentation to support the assertion
that the current behavior is broken.

> We already do group membership check for the socket. We simply incorrectly determine
> that any socket that doesn't list a group.
> 
> What's worse is that if you have a socket that doesn't care about any mulicast
> destinations (never did an ADD_MEMBERSHIP), it will still get multicast traffic if
> it bound to that port.
> 
You assume thats true, but you really have no way of knowing thats the case.  I
can imagine plenty of uses for applications that anonymously receive multicast
datagrams.


I'll refer you again to this exact conversation months ago, when I was on the
opposite end of this, and shown to be wrong:
http://kerneltrap.org/mailarchive/linux-netdev/2008/7/11/2430904

Neil
