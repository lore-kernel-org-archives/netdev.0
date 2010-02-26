From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding: fix device leak on error in bond_create()
Date: Fri, 26 Feb 2010 11:22:24 -0500
Message-ID: <20100226162224.GB2108@gospo.rdu.redhat.com>
References: <4B87EA58.7090601@trash.net> <20100226160544.GA2108@gospo.rdu.redhat.com> <4B87F424.6090300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965233Ab0BZQWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 11:22:38 -0500
Content-Disposition: inline
In-Reply-To: <4B87F424.6090300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 05:17:40PM +0100, Patrick McHardy wrote:
> Andy Gospodarek wrote:
> > On Fri, Feb 26, 2010 at 04:35:52PM +0100, Patrick McHardy wrote:
> > 
> >> commit f357a5caa0ca29b74811a0fc08efb5ae4aade959
> >> Author: Patrick McHardy <kaber@trash.net>
> >> Date:   Thu Feb 25 20:21:10 2010 +0100
> >>
> >>     bonding: fix device leak on error in bond_create()
> >>     
> >>     When the register_netdevice() call fails, the newly allocated device is
> >>     not freed.
> >>     
> >>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> >>
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index 1787e3c..430c022 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -4946,6 +4946,8 @@ int bond_create(struct net *net, const char *name)
> >>  	}
> >>  
> >>  	res = register_netdevice(bond_dev);
> >> +	if (res < 0)
> >> +		goto out_netdev;
> >>  
> >>  out:
> >>  	rtnl_unlock();
> > 
> > Acked-by: Andy Gospodarek <andy@greyhouse.net>
> > 
> > Seems like a good idea.  I know register_netdevice is always supposed to
> > return a value < 0 on error, but this would work if it didn't for some
> > reason.
> 
> I don't care much, but that would be a bug since we'd return
> invalid errno codes to userspace.

Then I guess the bonding driver would probably not be the last to know
if someone snuck a bug into register_netdevice....

