From: jamal <hadi@cyberus.ca>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 09:22:32 -0400
Message-ID: <1149081752.5462.98.camel@jzny2>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>
	 <20060527134629.GA16306@2ka.mipt.ru>
	 <Pine.LNX.4.64.0605271223390.12872@d.namei>
	 <Pine.LNX.4.64.0605271303050.13104@d.namei>
	 <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2>
	 <20060531130649.GD7844@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:4051 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964993AbWEaNWh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 09:22:37 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FlQel-0005nc-It
	for netdev@vger.kernel.org; Wed, 31 May 2006 09:22:39 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060531130649.GD7844@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-31-05 at 15:06 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-05-31 08:20
> > The challenge is how to inform SELinux of these permissions. 
> > The access limit could be done by putting a SELinux hook at the time the
> > skb gets to the generic netlink code?
> > Note: There's actually two things that can be classified for access
> > control, the genl family as well as the ops.
> 
> We already have the flag GENL_ADMIN_PERM which when set for a
> struct genl_ops calls security_netlink_recv(). It's not as
> fine grained as it could be though. 

To also answer your other email:
Look at  security/selinux/nlmsgtab.c for example for NETLINK_ROUTE
and compare with NETLINK_GENERIC to see the hole. I was suggesting if
we started by just adding checks for NETLINK_GENERIC first in those
tables (currently lacking), that would be a good start.

> The point is that adding
> fine grained SELinux support is no problem and even easier than
> for casual netlink families.
> 

indeed. And it would be the first to check for a lot more fine graining
than exists today.
If you look at security/selinux/nlmsgtab.c (after we add checks for
NETLINK_GENERIC) then it seems hard to just "hardcode" all commands and
families/ids in there because the idea is people could even be doing
this via modules. Not sure if that made sense.

>  the important point is that for genetlink we already have
> a point where we peek at the attributes and adding a hook is
> trivial unlike for other netlink families where they'd have to be
> spread in the code.

nod.

cheers,
jamal

