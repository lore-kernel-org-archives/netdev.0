From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] do not give access to 1-1024 ports for autobinding
Date: Wed, 10 Oct 2007 10:12:03 -0700
Message-ID: <20071010101203.0e3da7ab@freepuppy.rosehill>
References: <20071010143449.GA10796@iris.sw.ru>
	<20071010084137.1963122e@freepuppy.rosehill>
	<470D04E1.9030505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <dlunev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35314 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752435AbXJJRMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 13:12:21 -0400
In-Reply-To: <470D04E1.9030505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Oct 2007 20:59:13 +0400
"Denis V. Lunev" <dlunev@gmail.com> wrote:

> Stephen Hemminger wrote:
> > On Wed, 10 Oct 2007 18:34:49 +0400
> > "Denis V. Lunev" <den@openvz.org> wrote:
> > 
> >> This patch prevents possibility to give 1-1024 port range for autobinding.
> >> {1, 1} may only takes some sense for deep embedded people.
> >>
> >> Signed-off-by: Denis V. Lunev <den@openvz.org>
> >>
> >> --- ./net/ipv4/sysctl_net_ipv4.c.port2	2007-10-10 17:46:48.000000000 +0400
> >> +++ ./net/ipv4/sysctl_net_ipv4.c	2007-10-10 18:08:00.000000000 +0400
> >> @@ -25,7 +25,7 @@ extern int sysctl_ip_nonlocal_bind;
> >>  #ifdef CONFIG_SYSCTL
> >>  static int zero;
> >>  static int tcp_retr1_max = 255;
> >> -static int ip_local_port_range_min[] = { 1, 1 };
> >> +static int ip_local_port_range_min[] = { 1024, 1024 };
> >>  static int ip_local_port_range_max[] = { 65535, 65535 };
> >>  #endif
> >>  
> >> -
> > 
> > That only limits the sysctl, which seems completely counter productive.
> > Sounds like more of the "stop root from shooting themselves" patches.
> > 
> 
> They have sense for the case of multiple network namespaces, where root
> in the other namespace can be treated as a user to initial namespace.

IMHO  don't want to treat root as a complete idiot like normal users.
As long as what root requests doesn't create a security problem, it
should be allowed.  The port space is per namespace right? The sysctl
values should be per namespace as well.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
