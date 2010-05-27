From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 10:00:25 +0200
Message-ID: <20100527080025.GB6800@basil.fritz.box>
References: <87fx1e1sat.fsf@basil.nowhere.org> <20100526.140818.245406045.davem@davemloft.net> <20100526212745.GC24615@basil.fritz.box> <20100526.151014.70204145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37982 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab0E0IA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 04:00:27 -0400
Content-Disposition: inline
In-Reply-To: <20100526.151014.70204145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 03:10:14PM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 26 May 2010 23:27:45 +0200
> 
> > As I understand the idea was that the application knows
> > what flows belong to a single peer and wants to have
> > a single cwnd for all of those. Perhaps there would
> > be a way to generalize that to tell it to the kernel.
> > 
> > e.g. have a "peer id"  that is known by applications
> > and the kernel could manage cwnds shared between connections
> > associated with the same peer id?
> > 
> > Just an idea, I admit I haven't thought very deeply
> > about this. Feel free to poke holes into it.
> 
> Yes, a CWND "domain" that can include multiple sockets is
> something that might gain some traction.
> 
> The "domain" could just simply be the tuple {process,peer-IP}

If process is in there this wouldn't work for a multi process
server?

Perhaps having it associated with a FD so that it could
be passed around with unix sockets if needed (just would
need to make sure the AF_UNIX gc can handle such cycles)

peer_id = open_peer_id();   
/* peer id is like a fd */

socket = socket( ... ); 
set_peer_id(socket, peer_id); 


...

close(peer_id);

-andi
-- 
ak@linux.intel.com -- Speaking for myself only.
