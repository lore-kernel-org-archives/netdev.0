From: Felix von Leitner <felix-kernel@fefe.de>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 13:58:45 +0100
Message-ID: <20090317125845.GB9754@codeblau.de>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:46092 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752639AbZCQM6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 08:58:49 -0400
Content-Disposition: inline
In-Reply-To: <49BF0A5A.2040501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't think this ever worked on Linux, from the very beginning of inet6_bind():

>         /* Check if the address belongs to the host. */
>         if (addr_type == IPV6_ADDR_MAPPED) {
>                 v4addr = addr->sin6_addr.s6_addr32[3];
>                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
>                         err = -EADDRNOTAVAIL;
>                         goto out;
>                 }
>         } else {

What is the harm in allowing this?  That way an application ported to
IPv6 can still bind IPv4-only.  Why would it be legal to bind to a
specific IPv4 address but not to all IPv4 addresses?

The specific case is a bittorrent tracker.  The code was ported to IPv6,
but since there is so much overhead in storing IPv6 addresses you are
supposed to run two processes, one on the IPv6 address and one on the
IPv4 address (the IPv4 one then does not have overhead).  The sane way
to do this is to bind the IPv6 socket to ::ffff:0.0.0.0 then.  Otherwise
you would need some kind of giant abstraction layer in the application.
And we specifically added the ipv4 mapped addresses so applications
would not need to have a giant abstraction layer.

Did I mention *BSD and OSX allow this?

> So are you trying to get IPv4-only behavior out of this socket?  Seems
> like the wrong way to go about it.

Why would you say that?

Felix
