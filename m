From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Thu, 1 Jun 2006 10:24:50 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606011022450.16136@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru>
 <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei>
 <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2>
 <20060531130649.GD7844@postel.suug.ch> <1149081752.5462.98.camel@jzny2>
 <Pine.LNX.4.64.0605311141320.4964@d.namei> <20060601104506.GF7844@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:20960 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750994AbWFAOYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 10:24:53 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060601104506.GF7844@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Jun 2006, Thomas Graf wrote:

> It shouldn't be hard to split what is implemented in nlmsg_route_perms[]
> for NETLINK_ROUTE into the definitions of the generic netlink
> operations, could look like this:
> 
> struct genl_ops some_op = {
> 	[...]
> 	.perm	 = NETLINK_GENERIC_SOCKET__NLMSG_READ,
> };

We wouldn't need the socket class outside of SELinux, just the perm, so 
something like:

NL_PERM_READ

> int genl_peek_cmd(struct nlmsghdr *nlh)
> {
> 	struct genlmsghdr *hdr = nlmsg_data(nlh);
> 
> 	if (nlh->nlmsglen < nlmsg_msg_sizeo(GENL_HDRLEN))
> 		return -EINVAL;
> 
> 	return hdr->cmd;
> }

Unless I'm mistaken, people are already multiplexing commands inside genl 
commands (and if so, why even bother with registerable ops?).


I'll look at it in more detail soon.


-- 
James Morris
<jmorris@namei.org>
