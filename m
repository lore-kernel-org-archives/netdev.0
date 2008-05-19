From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Sun, 18 May 2008 22:13:32 -0400
Message-ID: <4830E24C.3020405@garzik.org>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40642 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbYESCNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 22:13:37 -0400
In-Reply-To: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> Hi-
> 
> I'm interested in some review of the following four patches which add to
> the kernel's NFS client the ability to parse IPv6 addresses in presentation
> format.
> 
> Namely, it adds the following:
> 
> 1.  If the user passes in an IPv6 address as the server name, the colons
>     in the address will confuse the logic that splits the device name
>     into a server hostname and an export path.   We'll use square brackets
>     around IPv6 server addresses to "escape" the colons, as does Solaris.
> 
> 2.  If the user passes in a link-local IPv6 address as the server name,
>     an interface index is also necessary.  We'll use the "%id" suffix on
>     the address to pass in the index, and plant that in the sockaddr's
>     sin6_scope_id field.
> 
> In addition to the following patches in email, a git repo with these
> same patches already applied can be found here:
> 
> 	linux-nfs.org:exports/cel-2.6.git
> 
> The basic questions:
> 
> Are these reasonable conventions to follow?  Is the parsing logic adequate?
> Is there anything I'm forgetting?

I would take a look at the underlying components of glibc's 
getnameinfo(), which must parse IPv6 addresses according to POSIX 
specifications, IIRC.

Comments:

1) bracket escaping seems reasonably common.  browsers and other apps 
sometimes use that convention too.

2) an interface name rather than index should be used

	Jeff


