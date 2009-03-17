From: Brian Haley <brian.haley@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 11:59:34 -0400
Message-ID: <49BFC8E6.8000404@hp.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:2275 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbZCQP7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 11:59:37 -0400
In-Reply-To: <20090317125845.GB9754@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix von Leitner wrote:
>> I don't think this ever worked on Linux, from the very beginning of inet6_bind():
> 
>>         /* Check if the address belongs to the host. */
>>         if (addr_type == IPV6_ADDR_MAPPED) {
>>                 v4addr = addr->sin6_addr.s6_addr32[3];
>>                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
>>                         err = -EADDRNOTAVAIL;
>>                         goto out;
>>                 }
>>         } else {
> 
> What is the harm in allowing this?  That way an application ported to
> IPv6 can still bind IPv4-only.  Why would it be legal to bind to a
> specific IPv4 address but not to all IPv4 addresses?

Please show me a porting guide that even mentions supporting IPv4-only mode
through an IPv6 socket by using this method.  There is none that I know of.

> The specific case is a bittorrent tracker.  The code was ported to IPv6,
> but since there is so much overhead in storing IPv6 addresses you are
> supposed to run two processes, one on the IPv6 address and one on the
> IPv4 address (the IPv4 one then does not have overhead).  The sane way
> to do this is to bind the IPv6 socket to ::ffff:0.0.0.0 then.  Otherwise
> you would need some kind of giant abstraction layer in the application.
> And we specifically added the ipv4 mapped addresses so applications
> would not need to have a giant abstraction layer.
> 
> Did I mention *BSD and OSX allow this?

That was their decision, and it doesn't mean it's the right thing to do.  It
doesn't mean Linux shouldn't change either, but name-calling isn't going to get
you anywhere on this list.

Compare your bittorrent server to Apache, which is probably the most widely-used
server application in the world.  It doesn't do what you're trying to do.  See
http://httpd.apache.org/docs/2.2/bind.html and/or browse the source code.

>> So are you trying to get IPv4-only behavior out of this socket?  Seems
>> like the wrong way to go about it.
> 
> Why would you say that?

Because if you want IPv4-only you open an AF_INET socket.  There is no
equivalent to IPv6-only, for example when you open an AF_INET6 socket and set
IPV6_ONLY on it.

-Brian
