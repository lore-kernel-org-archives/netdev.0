From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 23:35:47 +0100
Message-ID: <20080514223547.GG23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <482B2E50.2030601@garzik.org> <Pine.LNX.4.64.0805141247180.23143@cobra.newdream.net> <482B5E6F.4020204@garzik.org> <Pine.LNX.4.64.0805141516540.23143@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:45591 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbYENWfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 18:35:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805141516540.23143@cobra.newdream.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sage Weil wrote:
> It's the 'single node' part that concerns me.  As long as that node is 
> ensuring there is consensus behind the scenes before handing out said 
> signature.  Otherwise you can't be sure you're not getting an old 
> signature for old data..

Sounds like a transaction serialisation problem?

> This is more or less what I ended up doing.  Since the workload is 
> mostly-read, the paxos leader gives non-leaders leases to process reads in 
> parallel, and new elections or state changes wait if necessary to ensure 
> old leases are revoked or expire before any new leases on new values are 
> issued.

My design has something similar, but I think more like MOESI protocol
analogous to CPUs.  There are read leases which are revoked by
explicit confirmation or waiting for them to expire, but that's only
required when serialisation forces a particular access order, and it
can be speculated around.  Like MOESI, it adapts between mostly-read
and mostly-write workloads.

-- Jamie
