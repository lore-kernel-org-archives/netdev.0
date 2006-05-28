From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Refactor Netlink connector?
Date: Sun, 28 May 2006 19:33:21 +0400
Message-ID: <20060528153321.GB31822@2ka.mipt.ru>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55763 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750776AbWE1PkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 11:40:05 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605271303050.13104@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 27, 2006 at 01:21:05PM -0400, James Morris (jmorris@namei.org) wrote:
> On Sat, 27 May 2006, James Morris wrote:
> 
> > One of the problems is that different Netlink protocols bury their 
> > commands at different levels, so the SELinux code has to know how how deep 
> > to dig (and then do the digging) to determine exactly which command is 
> > being called.
> 
> Actually, a possible solution here is to completely remove all internal 
> knowledge of netlink messages from SELinux and have the netfilter 
> framework and protocols provide methods to determine message types and 
> permissions.
> 
> One of the issues still to resolve for SELinux and generic netlink is that 
> we don't know what the netlink protocol for the socket really is until 
> messages are sent over it, so some socket-level perms for NETLINK_GENERIC 
> will have to be handed out to all potential users (although actual 
> transfer of data can be mediated at a finer granularity).

Does SELinux have security handlers for each type of possible ioctls
over the world? Each ioctl number is like each netlink type of message,
but instead there is only one check per ioctl syscall as long as lsm
hook for socket's send/recv syscall. 
It could be interesting and quite challenging to force all ioctl users
to have the same structure under each ioctl number so SELinux could
control for example disk geometry or time and date requests...
And, btw, what is the purpose of controlling netlink messages?
Does it prevent malicious userspace application to receive events from
malicious kernel module?
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
