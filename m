From: dean gaudet <dean@arctic.org>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 22:09:28 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701232202320.27405@twinlark.arctic.org>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <45B65271.1040709@hp.com>
 <Pine.LNX.4.64.0701231140320.21464@twinlark.arctic.org>
 <20070123.211140.74746965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rick.jones2@hp.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:45233 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030245AbXAXGJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:09:28 -0500
In-Reply-To: <20070123.211140.74746965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jan 2007, David Miller wrote:

> From: dean gaudet <dean@arctic.org>
> Date: Tue, 23 Jan 2007 12:11:01 -0800 (PST)
> 
> > libnss-ldap has some code which attempts to determine if its private 
> > socket has been trampled on in between calls to the library... and to do 
> > this it caches getsockname/getpeername results and compares them every 
> > time the library is re-entered... and when there's a mismatch it leaks a 
> > socket (eventually crashing nscd if you're using that).  i've been trying 
> > to band-aid over the problem:
> > 
> > http://bugzilla.padl.com/show_bug.cgi?id=304
> > http://bugzilla.padl.com/show_bug.cgi?id=305
> > 
> > but i'm probably going to need to approach it from another direction -- 
> > make libnss-ldap monitor the ldap library results so it knows when there's 
> > been a read/write error so that it stops doing this 
> > getsockname/getpeername thing after the error has occured.
> 
> Please do not write programs in this way.  getsockname/getpeername
> were never meant to be used in that way, and it's hella inefficient
> to keep checking the socket like that to boot.
> 
> I really don't see you gaining anything by making this check every
> time the user calls into the library.
> 
> If the application mucks with the communications channel socket, so
> what, it's his application that will go tits up.
> 
> Is there some tricky interaction between nscd and something like
> libnss-ldap that makes this tom-foolery necessary?
> 

oh heck yeah i totally agree -- it's not my code though, i'm just 
debugging it.

-dean
