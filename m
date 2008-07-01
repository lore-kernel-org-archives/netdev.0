From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 16:03:20 +0400
Message-ID: <20080701120320.GA9412@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52972 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbYGAMDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 08:03:10 -0400
Content-Disposition: inline
In-Reply-To: <486A1AC7.9020706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.

On Tue, Jul 01, 2008 at 01:53:43PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> My two main objections are that this only works for TCP and
> can be trivially evaded. What use cases does it have?

Yes, it is TCP specific module.

> I'm also wondering whether this couldn't be implemented
> using the u32 match.

I'm not sure it is that simple. OSF uses common rules database
shared with OpenBSD (and other *BSDs as well), so converting it into u32
match would require noticeble efforts. But in theory it is probably
doable.

> >This version existed quite for a while in patch-o-matic(-ng), but
> >suddenly was dropped and then only was updated on its own repo:
> >http://tservice.net.ru/~s0mbre/old/?section=projects&item=osf
> >
> >I've updated OSF to match new iptables standards (namely xtables
> >support) and present new kernelspace and userspace library files in
> >attach.
> >
> >To setup single rule, which will drop and log all Linux incoming
> >access one needs to do following steps:
> ># insmod ./ipt_osf.ko
> ># ./load ./pf.os /proc/sys/net/ipv4/osf
> ># iptables -I INPUT -j DROP -p tcp -m osf --genre Linux --log 2 \
> >--ttl 2 --connector
> 
> And I don't think it should be using connector. AFAIK we
> only have a single user in the tree currently and new
> stuff usually uses genetlink (which is pretty similar),
> so we might be able to remove connection in the future
> unless we add new users. But netfilter modules should
> use nfnetlink anyway.
 
This module was created way before genetlink was ever designed (on
behalf of connector btw :)

Also I do not know why we want to remove connector in favour of
genetlink, since the former is much simpler to work with. Connector
logging is optional in OSF.

-- 
	Evgeniy Polyakov
