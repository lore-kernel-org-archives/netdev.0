From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Tue, 30 May 2006 14:58:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605301453360.28036@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru>
 <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei>
 <20060528153321.GB31822@2ka.mipt.ru> <Pine.LNX.4.64.0605301015090.25929@d.namei>
 <20060530180300.GA10293@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:57002 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932394AbWE3S6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 14:58:14 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060530180300.GA10293@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 May 2006, Evgeniy Polyakov wrote:

> On Tue, May 30, 2006 at 10:18:32AM -0400, James Morris (jmorris@namei.org) wrote:
> > > And, btw, what is the purpose of controlling netlink messages?
> > > Does it prevent malicious userspace application to receive events from
> > > malicious kernel module?
> > 
> > It provides control over which types of applications can send and receive 
> > different types of Netlink messages.  e.g. you can specify that Apache can 
> > read the routing table but not write to it.
>  
> Apache still can setup routes using ioctl or execve("ip route add/route
> add");

Depends on the policy.  You can specify which types of files/sockets 
apache can perform ioctl on, and whether it can execve 'ip', and if so, 
which security context that runs in, and then whether that security 
context can add routes.

Security in SELinux is not based on the name of the application, it's 
based on the security label bound to the binary being executed.

> Anyway you can easily add lsm hook into both sending/receiving pathes in
> connector code, it fully controls the traffic before it reached socket
> queue or user's callback.

There are already LSM hooks which allow this, it's a matter of not wanting 
to have to parse arbitrarily implemented Netlink protocols to determine 
what the messages are.


- James
-- 
James Morris
<jmorris@namei.org>
