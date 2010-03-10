From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 18:56:53 +0100
Message-ID: <201003101856.53525.arnd@arndb.de>
References: <20100310131317.GA6267@linux.vnet.ibm.com> <20100310162658.GI6267@linux.vnet.ibm.com> <20100310.083547.213194954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61129 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065Ab0CJR5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 12:57:07 -0500
In-Reply-To: <20100310.083547.213194954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 March 2010, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 10 Mar 2010 08:26:58 -0800
>
> > I have -tip commit a898def29e4119bc01ebe7ca97423181f4c0ea2d that
> > converts some of the rcu_dereference()s in net/core/filter.c,
> > net/core/dev.c, net/decnet/dn_route.c, net/packet/af_packet.c, and
> > net/ipv4/route.c to rcu_dereference_bh().
> > 
> > How should we coordinate the removal of the rcu_read_lock() calls?
> 
> Paul if you want to do this via your tree, feel free.

My feeling is that this should be combined with the annotations I'm doing,
annotating one subsystem at a time, and doing changes like these in the
process. I'm still unsure what interface extensions there will have to
be, but I guess we can the new interfaces as empty wrappers in the 2.6.34
phase, and do all of the conversions where there are potential or real
bugs.

All the other annotations can get queued in subsystem maintainer trees
where it makes sense or get put in one tree for all the others, to be
merged in after 2.6.34 is out.

	Arnd
