From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 15:06:49 +0200
Message-ID: <20060531130649.GD7844@postel.suug.ch>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei> <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39585 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965006AbWEaNGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 09:06:30 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1149078055.5462.55.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-05-31 08:20
> The challenge is how to inform SELinux of these permissions. 
> The access limit could be done by putting a SELinux hook at the time the
> skb gets to the generic netlink code?
> Note: There's actually two things that can be classified for access
> control, the genl family as well as the ops.

We already have the flag GENL_ADMIN_PERM which when set for a
struct genl_ops calls security_netlink_recv(). It's not as
fine grained as it could be though. The point is that adding
fine grained SELinux support is no problem and even easier than
for casual netlink families.

> This is even further granularity that opens a whole new can of worms. 

I agree, the advantage is that the genetlink code already takes
care of validating the attributes, all we have to do is allow
genetlink families to provide a policy.

> BTW, I abused the term "attribute" in my other email to James. In that
> context it means metadata for the command and in the above case it means
> the "T" in TLV. Despite that they are strongly related, just that
> the packet offsets are different and the checks are for different
> things: SELinux policy is a simple accept/deny based on some policy
> (provisioned in user space??) and nla_policy is richer with a range
> check for sanity reasons as opposed to access control and then
> accept/deny. 

Right, the important point is that for genetlink we already have
a point where we peek at the attributes and adding a hook is
trivial unlike for other netlink families where they'd have to be
spread in the code.
