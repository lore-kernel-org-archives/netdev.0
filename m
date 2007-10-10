From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] do not give access to 1-1024 ports for autobinding
Date: Wed, 10 Oct 2007 15:51:51 -0700 (PDT)
Message-ID: <20071010.155151.11054291.davem@davemloft.net>
References: <20071010143449.GA10796@iris.sw.ru>
	<20071010084137.1963122e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754769AbXJJWvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:51:49 -0400
In-Reply-To: <20071010084137.1963122e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 10 Oct 2007 08:41:37 -0700

> On Wed, 10 Oct 2007 18:34:49 +0400
> "Denis V. Lunev" <den@openvz.org> wrote:
> 
> > This patch prevents possibility to give 1-1024 port range for autobinding.
> > {1, 1} may only takes some sense for deep embedded people.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> > 
> > --- ./net/ipv4/sysctl_net_ipv4.c.port2	2007-10-10 17:46:48.000000000 +0400
> > +++ ./net/ipv4/sysctl_net_ipv4.c	2007-10-10 18:08:00.000000000 +0400
> > @@ -25,7 +25,7 @@ extern int sysctl_ip_nonlocal_bind;
> >  #ifdef CONFIG_SYSCTL
> >  static int zero;
> >  static int tcp_retr1_max = 255;
> > -static int ip_local_port_range_min[] = { 1, 1 };
> > +static int ip_local_port_range_min[] = { 1024, 1024 };
> >  static int ip_local_port_range_max[] = { 65535, 65535 };
> >  #endif
> >  
> > -
> 
> That only limits the sysctl, which seems completely counter productive.
> Sounds like more of the "stop root from shooting themselves" patches.

Agreed, we shouldn't be changing these values.
