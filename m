From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 08:36:06 -0700
Message-ID: <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
References: <4E9C8D8B.90606@mellanox.co.il>
	<1318902525.2571.24.camel@edumazet-laptop>
	<953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
	<1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33912 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932876Ab1JRPgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 11:36:09 -0400
In-Reply-To: <953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2011 08:59:44 +0000
Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:

> > 
> > What is the gain using random values ?
> > 
> > Usually, we tend to have same hardware in a single machine, or we use
> > active-backup bonding mode, and an active slave flip can change rxhash
> > values with litle effect, since this happens not often.
> > 
> > I really prefer not random values, because it allows to have replayable
> > configurations : For a given tcp flow, the same rxhash value is given
> > and same cpu target in RPS. Its way easier to tune your machine for some workloads.
> > 
> 
> There is no gain in random values, 
> I'll make the change to have static value for RSS function.
> 
> We might consider how to ensure consistency across the different drivers in this aspect.

The key should be part of the network device core. Almost all hardware just
implements the Microsoft standard, and if all drivers used same key they should
come up with the same hash.

Although using the same key all the time makes testing easier.
The risk of using the same key is that it makes it easier for an attacker to
create a set of addresses that all map to the same CPU which would make a DoS
attack work better.  Therefore the key should be randomly generated at boot time.
