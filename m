From: Sage Weil <sage@newdream.net>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 13:00:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805141247180.23143@cobra.newdream.net>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org>
 <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
 <482B2E50.2030601@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cobra.newdream.net ([66.33.216.30]:38392 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764161AbYENUAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 16:00:09 -0400
In-Reply-To: <482B2E50.2030601@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008, Jeff Garzik wrote:
> > Similarly, if only 1 out of 3 replicas is surviving, most people want to be
> > able to read their data, while Paxos demands a majority to ensure it is
> > correct.
> 
> This isn't necessarily true -- it's quite easy for most applications to come
> up with an alternate method for ensuring correctness of retrieved data, if one
> assumes Paxos consensus was achieved during the write-data phase earlier in
> time.  Checksumming is a common solution, but not the only one.  Domain- or
> app-specific solution, as noted, of course.

You mean if, say, some verifiable metadata or a trusted third party stores 
that checksum?  Sure.  This is just pushing the what-has-committed 
information to some other party, though, who will presumably face the same 
problem of requiring a majority for verifiable correctness.  This is more 
or less what most people do in practice... using Paxos for critical state 
and piggybacking the rest of the system's consistency off of that.

> > (This is why Paxos is typically used only for critical cluster
> > configuration/state, not regular data.)
> 
> Yep, I'm working on a config daemon a la Chubby or zookeeper, based on Paxos,
> that does just this.  :)

Cool.  Do you have a URL?  I'd be interested in seeing how you diverge 
from classic paxos.  For Ceph's monitor daemon, the main requirements 
(besides strict correctness guarantees) were scalable (distributed) read 
access, and a history of state changes.  Nothing too unusual.

sage
