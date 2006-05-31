From: jamal <hadi@cyberus.ca>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 08:20:55 -0400
Message-ID: <1149078055.5462.55.camel@jzny2>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>
	 <20060527134629.GA16306@2ka.mipt.ru>
	 <Pine.LNX.4.64.0605271223390.12872@d.namei>
	 <Pine.LNX.4.64.0605271303050.13104@d.namei>
	 <20060531030046.GC7844@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:11139 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964972AbWEaMVA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 08:21:00 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FlPh7-0007N7-VD
	for netdev@vger.kernel.org; Wed, 31 May 2006 08:21:01 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060531030046.GC7844@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-31-05 at 05:00 +0200, Thomas Graf wrote:
> * James Morris <jmorris@namei.org> 2006-05-27 13:21
> > Actually, a possible solution here is to completely remove all internal 
> > knowledge of netlink messages from SELinux and have the netfilter 
> > framework and protocols provide methods to determine message types and 
> > permissions.
> 
> Right, regarding generic netlink we can extend struct genl_ops to
> include a policy stating what permissions are required. 

The challenge is how to inform SELinux of these permissions. 
The access limit could be done by putting a SELinux hook at the time the
skb gets to the generic netlink code?
Note: There's actually two things that can be classified for access
control, the genl family as well as the ops.

> Besides
> that we can extend struct nla_policy to support validating of
> attributes.

This is even further granularity that opens a whole new can of worms. 

BTW, I abused the term "attribute" in my other email to James. In that
context it means metadata for the command and in the above case it means
the "T" in TLV. Despite that they are strongly related, just that
the packet offsets are different and the checks are for different
things: SELinux policy is a simple accept/deny based on some policy
(provisioned in user space??) and nla_policy is richer with a range
check for sanity reasons as opposed to access control and then
accept/deny. 

cheers,
jamal

