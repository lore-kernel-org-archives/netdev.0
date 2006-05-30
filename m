From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Refactor Netlink connector?
Date: Tue, 30 May 2006 22:03:00 +0400
Message-ID: <20060530180300.GA10293@2ka.mipt.ru>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei> <20060528153321.GB31822@2ka.mipt.ru> <Pine.LNX.4.64.0605301015090.25929@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:24205 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932372AbWE3SOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 14:14:08 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605301015090.25929@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 10:18:32AM -0400, James Morris (jmorris@namei.org) wrote:
> > And, btw, what is the purpose of controlling netlink messages?
> > Does it prevent malicious userspace application to receive events from
> > malicious kernel module?
> 
> It provides control over which types of applications can send and receive 
> different types of Netlink messages.  e.g. you can specify that Apache can 
> read the routing table but not write to it.
 
Apache still can setup routes using ioctl or execve("ip route add/route
add");

Anyway you can easily add lsm hook into both sending/receiving pathes in
connector code, it fully controls the traffic before it reached socket
queue or user's callback.
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
