From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 18:09:00 +0100
Message-ID: <20151023170900.GX22011@ZenIV.linux.org.uk>
References: <5628636E.1020107@oracle.com>
 <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
 <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
 <5628CF79.2000507@oracle.com>
 <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
 <5628E142.7050600@oracle.com>
 <20151022170548.GR22011@ZenIV.linux.org.uk>
 <56291F56.2080906@oracle.com>
 <20151022185610.GU22011@ZenIV.linux.org.uk>
 <201510221950.t9MJoAw0005835@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46802 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbJWRJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 13:09:07 -0400
Content-Disposition: inline
In-Reply-To: <201510221950.t9MJoAw0005835@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 09:50:10PM +0200, Casper.Dik@oracle.com wrote:
> >Sigh...  It completely fails to mention descriptor-passing.  Which
> >	a) is relevant to what "last close" means and
> >	b) had been there for nearly the third of a century.
> 
> Why is that different?  These clearly count as file descriptors.

To quote your own posting upthread (Message-ID:
<201510212033.t9LKX4G8007718@room101.nl.oracle.com>)

> Well, a file descriptor really only exists in the context of a process; 
> in-flight it is no longer a file descriptor as there process context with 
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> a file descriptor table; so pointers to file descriptions are passed 
> around.

IMO it shows that the wording is anything but clear.  The only way to claim
that it's accurate is, indeed, to declare that the contents of in-flight
SCM_RIGHTS datagram should be counted as file descriptors and that's too
much of a stretch for the reasons you've pointed to.
