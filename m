From: jamal <hadi@cyberus.ca>
Subject: Re: Refactor Netlink connector?
Date: Wed, 14 Jun 2006 08:36:04 -0400
Message-ID: <1150288564.5233.31.camel@jzny2>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>
	 <20060527134629.GA16306@2ka.mipt.ru>
	 <Pine.LNX.4.64.0605271223390.12872@d.namei>
	 <Pine.LNX.4.64.0605271303050.13104@d.namei>
	 <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2>
	 <20060531130649.GD7844@postel.suug.ch> <1149081752.5462.98.camel@jzny2>
	 <Pine.LNX.4.64.0605311141320.4964@d.namei>
	 <20060601104506.GF7844@postel.suug.ch>
	 <Pine.LNX.4.64.0606011022450.16136@d.namei>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:40146 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932310AbWFNMkz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 08:40:55 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FqUg2-0005q1-5M
	for netdev@vger.kernel.org; Wed, 14 Jun 2006 08:40:54 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606011022450.16136@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So whats the resolution on this? I actually have some cycles this coming
weekend that i was hopping to spend updating the doc instead.

cheers,
jamal

On Thu, 2006-01-06 at 10:24 -0400, James Morris wrote:
> On Thu, 1 Jun 2006, Thomas Graf wrote:
> 
> > It shouldn't be hard to split what is implemented in nlmsg_route_perms[]
> > for NETLINK_ROUTE into the definitions of the generic netlink
> > operations, could look like this:
> > 
> > struct genl_ops some_op = {
> > 	[...]
> > 	.perm	 = NETLINK_GENERIC_SOCKET__NLMSG_READ,
> > };
> 
> We wouldn't need the socket class outside of SELinux, just the perm, so 
> something like:
> 
> NL_PERM_READ
> 
> > int genl_peek_cmd(struct nlmsghdr *nlh)
> > {
> > 	struct genlmsghdr *hdr = nlmsg_data(nlh);
> > 
> > 	if (nlh->nlmsglen < nlmsg_msg_sizeo(GENL_HDRLEN))
> > 		return -EINVAL;
> > 
> > 	return hdr->cmd;
> > }
> 
> Unless I'm mistaken, people are already multiplexing commands inside genl 
> commands (and if so, why even bother with registerable ops?).
> 
> 
> I'll look at it in more detail soon.
> 
> 

