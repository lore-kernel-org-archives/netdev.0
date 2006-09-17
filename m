From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.18-rc[67] crashes in TCP ack handling
Date: Sun, 17 Sep 2006 20:53:51 +0900
Message-ID: <20060917205351.4f691c4e@localhost.localdomain>
References: <20060916221948.GA12421@outpost.ds9a.nl>
	<20060917083214.45b5f61f@localhost.localdomain>
	<20060917101101.GA30461@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28352 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964954AbWIQLyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 07:54:05 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060917101101.GA30461@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Sep 2006 12:11:01 +0200
bert hubert <bert.hubert@netherlabs.nl> wrote:

> On Sun, Sep 17, 2006 at 08:32:14AM +0900, Stephen Hemminger wrote:
> 
> > By building all the possiblities into the kernel, ie. not as modules
> > you get the last one registered. TCP LP is probably the worst one
> > to use, because it is designed for bulk low priority applications.
> > It also is one of the newest least tested.  Right now, I would rate
> 
> Hehe, this seems to be a bad default configuration policy then. People
> generally don't assume that if the kernel offers 10 policies that the most
> unstable will be used by default if you compile them all in.
> 
> I've attached a patch that reorders the choices per your suggested order, so
> people are most likely to get a sane default.
> 
> I've tried to make "reno" the default, no matter what you compiled in, but
> it didn't work. The linker probably reorders tcp_cong.o in early.

Reno is always builtin.  To choose it use 
 sysctl -w net.ipv4.tcp_congestion_control=reno
Depending on load order is not good, and not a safe way to configure.
If you want a particular value set it with sysctl!

The more experimental ones are already labeled as EXPERIMENTAL.
