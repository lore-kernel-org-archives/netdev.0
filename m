From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH (take 2)] netdev: lockdep classes in register_netdevice Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Wed, 16 May 2007 09:18:55 +0200
Message-ID: <20070516071855.GC1801@ff.dom.local>
References: <20070516054000.GB967@ff.dom.local> <20070515.224725.95062491.davem@davemloft.net> <20070516061732.GB1801@ff.dom.local> <20070515.231751.59657428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:35603 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751581AbXEPHMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 03:12:20 -0400
Content-Disposition: inline
In-Reply-To: <20070515.231751.59657428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 11:17:51PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Wed, 16 May 2007 08:17:32 +0200
> 
> > BTW - I think some patch on vlan cannot do any harm (at
> > least like this previous of mine - with only ppp
> > considered), and maybe this all could be forgotten.
> 
> Let's wait to see if any new messages show up.
> 
> I think how we've seperated PPP from ethernet locking
> has annotated things sufficiently for lockdep to see
> what's going on even in that VLAN case.
> 

I'm 99,9% sure lockdep's warning like this will be back:

#0 vlan_netdev_xmit_lock_key
	|
	V
#1 ppp->wlock
	|
	V
(pppoe)


#0 ppp->wlock
	|
	V
#1 pch->downl
	|
	V
#2 vlan_netdev_xmit_lock_key
	|
	V
(eth)

This 0,1% is for Yuriy - when he changes config or turns off
lockdep, like others.

But I have no problem with waiting too.

Jarek P.
