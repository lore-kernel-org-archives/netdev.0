From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Wed, 8 Dec 2010 15:49:32 -0800
Message-ID: <20101208154932.5bc4b254@nehalam>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
	<4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org>
	<4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56422 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209Ab0LHXte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 18:49:34 -0500
In-Reply-To: <m1tyineu3p.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Dec 2010 15:13:30 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Brian Haley <brian.haley@hp.com> writes:
> 
> > This got broken in 2.6.34-rc1, and the most obvious culprit is this,
> > although I haven't bisected it:
> >
> > commit dc2b99f71ef477a31020511876ab4403fb7c4420
> > Author: stephen hemminger <shemminger@vyatta.com>
> > Date:   Mon Feb 8 19:48:05 2010 +0000
> >
> >     IPv6: keep permanent addresses on admin down
> >
> >     Permanent IPV6 addresses should not be removed when the link is
> >     set to admin down, only when device is removed.
> >
> >     When link is lost permanent addresses should be marked as tentative
> >     so that when link comes back they are subject to duplicate address
> >     detection (if DAD was enabled for that address).
> >
> >     Other routing systems keep manually configured IPv6 addresses
> >     when link is set down.
> >
> > Even though there was a bugfix update, it didn't help.
> >
> > I unfortunately won't be able to look at this more until at least Friday,
> > I couldn't come up with a quick patch just looking quickly at
> > addrconf_ifdown().
> 
> This is almost certainly it.
> ip link set lo down
> ip link set lo up
> 
> Is enough to break ping6 ::1.
> 
> I get the feeling the loopback address was not actually tested and
> there is something different about it.

Loopback is already handled as special case in addrconf. Look at IFF_LOOPBACK
perhaps there is a logic error there.


-- 
