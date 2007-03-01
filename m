From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: make IGMP flooding on active-backup bonds configurable
Date: Wed, 28 Feb 2007 19:59:34 -0500
Message-ID: <20070301005934.GA1916@gospo.rdu.redhat.com>
References: <20070228222331.GA28813@gospo.rdu.redhat.com> <200702282239.l1SMdg22017137@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932860AbXCAA7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 19:59:41 -0500
Content-Disposition: inline
In-Reply-To: <200702282239.l1SMdg22017137@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 02:39:42PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >A while back the following change was made to the bonding code:
> >
> >commit df49898a47061e82219c991dfbe9ac6ddf7a866b
> >Author: John W. Linville <linville@tuxdriver.com>
> >Date:   Tue Oct 18 21:30:58 2005 -0400
> >
> >    [PATCH] bonding: cleanup comment for mode 1 IGMP xmit hack
> >    
> >    Expand comment explaining MAC address selection for replicated IGMP
> >    frames transmitted in bonding mode 1 (active-backup).  Also, a small
> >    whitespace cleanup.
> >    
> >    Signed-off-by: John W. Linville <linville@tuxdriver.com>
> >    Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
> >
> >In general this patch is good, but this tweaks that feature by allowing
> >that functionality to be enabled and disabled.  This patch adds a new
> >module option as well as a sysfs entry.  It sets the default to be the
> >current behavior so existing users shouldn't notice any difference.
> 
> 	Why would you want to turn this off?
> 

When you connect active-backup bonds to 2 separate switches that are in
'distant' parts of the network you can end up with a bunch of unwanted
multicast data flowing everywhere and if you don't care whether or not
your multicast traffic is highly available then it just seems like
noise.  I thought the flexibility seemed nice.

> 	Also, I've got a replacement patch for this functionality that
> seems to be better in all regards. It sends bonus IGMP joins when a
> failover occurs, rather than simply duplicating them on all slaves (the
> current system can leave switches in the dark if the slaves fail back to
> the originals).  As chance would have it, I'm planning to post it as
> part of a set in a a little while.
> 

That sounds like a nice add-on to the existing functionality.  I can see
the value in something dynamic like that, but I can also see the value
in something static like the functionality we have.  Did you plan to
keep the existing functionality intact or just have it done dynamically?

Is this separate from your workqueue/refactoring patch or does it work
on the existing code?


> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org> More majordomo info at  http://vger.kernel.org/majordomo-info.html
