From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Refactor Netlink connector?
Date: Tue, 30 May 2006 23:09:06 +0400
Message-ID: <20060530190906.GA3128@2ka.mipt.ru>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei> <20060528153321.GB31822@2ka.mipt.ru> <Pine.LNX.4.64.0605301015090.25929@d.namei> <20060530180300.GA10293@2ka.mipt.ru> <Pine.LNX.4.64.0605301453360.28036@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35758 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932424AbWE3TJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 15:09:20 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605301453360.28036@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 02:58:11PM -0400, James Morris (jmorris@namei.org) wrote:
> > Apache still can setup routes using ioctl or execve("ip route add/route
> > add");
> 
> Depends on the policy.  You can specify which types of files/sockets 
> apache can perform ioctl on, and whether it can execve 'ip', and if so, 
> which security context that runs in, and then whether that security 
> context can add routes.

With applications like phpmmyadmin apache must be allowed to perform such
operations no matter hacked it is or not...

> Security in SELinux is not based on the name of the application, it's 
> based on the security label bound to the binary being executed.

I know how selinux works.
I see your point, selinux is supposed to control each datflow even if it
sometimes is not that good idea.

> > Anyway you can easily add lsm hook into both sending/receiving pathes in
> > connector code, it fully controls the traffic before it reached socket
> > queue or user's callback.
> 
> There are already LSM hooks which allow this, it's a matter of not wanting 
> to have to parse arbitrarily implemented Netlink protocols to determine 
> what the messages are.

I mean you can control messages based on cn_mcg->id structure, since
cn_msg is a header for all connector messages.
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
