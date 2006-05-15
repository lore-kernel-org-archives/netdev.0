From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Mon, 15 May 2006 16:35:45 -0700
Message-ID: <20060515163545.4e3d755a@localhost.localdomain>
References: <OFE8460E54.0C8D85D8-ON8525716F.0074F22F-8825716F.0076D537@us.ibm.com>
	<20060515.154939.28171388.davem@davemloft.net>
	<44690C1C.8030101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mark1smi@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21993 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750786AbWEOXgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 19:36:03 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44690C1C.8030101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006 16:17:48 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> David S. Miller wrote:
> > From: Mark A Smith <mark1smi@us.ibm.com>
> > Date: Mon, 15 May 2006 14:39:06 -0700
> > 
> > 
> >>I discovered that in some cases, send(), sendmsg(), and sendto() are not
> >>thread-safe. Although the man page for these functions does not specify
> >>whether these functions are supposed to be thread-safe, my reading of the
> >>POSIX/SUSv3 specification tells me that they should be. I traced the
> >>problem to tcp_sendmsg(). I was very curious about this issue, so I wrote
> >>up a small page to describe in more detail my findings. You can find it at:
> >>http://www.almaden.ibm.com/cs/people/marksmith/sendmsg.html .
> 
> 
> # ./sendmsgclient localhost
> ERROR! We should have all 0! We don't!
> buff[16384]=1
> buff[16385]=1
> buff[16386]=1
> buff[16387]=1
> buff[16388]=1
> buff[16389]=1
> buff[16390]=1
> buff[16391]=1
> buff[16392]=1
> buff[16393]=1
> That's 10/32768 bad bytes
> # uname -a
> HP-UX tarry B.11.23 U ia64 2397028692 unlimited-user license
> 
> Given that the URL above asserts that HP-UX claims atomicity, either 
> there is a bug in the UX stack, or perhaps the test?  I took a quick 
> look at the HP-UX 11iv2 (aka 11.23) manpage for sendmsg and didn't see 
> anything about atomicity there - on which manpage(s) or docs was the 
> assertion of HP-UX atomicity made?
> 
> I presume this is only for "blocking" sockets?  I cannot at least off 
> the top of my head see how a stack could offer it on non-blocking sockets.

The test seems to be based on sending a big message. In this case,
on non-blocking sockets, the send call will return partial status. The
return from the system call will be less than the number of bytes requested.

> 
> > And frankly, BSD defines BSD socket semantics here not some wording in
> > the POSIX standards.
> 
> Have BSD socket semantics ever been updated/clarified any any 
> quasi-official manner since the popular presence of threads?  Or 
> are/were Posix/Xopen filling a gap?
> 
> rick jones
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
