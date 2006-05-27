From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Sat, 27 May 2006 13:21:05 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605271303050.13104@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru>
 <Pine.LNX.4.64.0605271223390.12872@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:29393 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964911AbWE0RVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 13:21:08 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <Pine.LNX.4.64.0605271223390.12872@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 May 2006, James Morris wrote:

> One of the problems is that different Netlink protocols bury their 
> commands at different levels, so the SELinux code has to know how how deep 
> to dig (and then do the digging) to determine exactly which command is 
> being called.

Actually, a possible solution here is to completely remove all internal 
knowledge of netlink messages from SELinux and have the netfilter 
framework and protocols provide methods to determine message types and 
permissions.

One of the issues still to resolve for SELinux and generic netlink is that 
we don't know what the netlink protocol for the socket really is until 
messages are sent over it, so some socket-level perms for NETLINK_GENERIC 
will have to be handed out to all potential users (although actual 
transfer of data can be mediated at a finer granularity).


- James
-- 
James Morris
<jmorris@namei.org>
