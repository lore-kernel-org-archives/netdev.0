From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Tue, 13 Oct 2009 10:05:33 -0700
Message-ID: <87ws2zcjhe.fsf@caffeine.danplanet.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-3-git-send-email-danms@us.ibm.com>
	<4AD3A52B.6050101@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	John Dykstra <jdykstra72@gmail.com>
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:48149 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760589AbZJMRGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:06:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> * Did you test this with UDP too ?

Not sendmail of course, but I have a little test program that
maintains a DGRAM connection to the echo service on a remote node,
yeah.

OL> * What happens if the the clock on the target machine differs from
OL> the clock on the origin machine ?  (TCP timestamps)

I guess maybe we should canonicalize the timeout values to something
like "milliseconds after checkpoint start"?  This would allow the
remote system to reset the timers to something reasonable.  It would
also cause non-migration restarts to restore the timers appropriately
for a coordinated restart of multiple machines.

OL> * How confident are we that "bad" input in one or more fields,
OL> that you don't currently sanitize, cannot create "bad" behavior ?
OL> (bad can be kernel crash, unauthorized behavior, DoS etc)

I'm going to say 0.052.

I haven't evaluated much of it, no :)

OL> * How much does TCP rely on the validity of the info in the
OL> protocol control block, and what sorts of bads can happen if it
OL> isn't ?  Would TCP be still happy if the URG point is bogus, would
OL> it allow the user to sent packets otherwise disallowed (to that
OL> user?), or maybe it could crash the kernel ?

Good question, I'll have to look.

OL> * Can you please document (brief description) how the restart
OL> logic works (listening parent socket etc) ?

Sure.

OL> * Do you intend to checkpoint (and collect) lingering sockets,
OL> that is they are closed by the application so not references by
OL> any task, but still sending data from their buffers ?

Yeah, I expect that will be important :)

OL> * I'd like to also preserve the "older" behavior - so the user can
OL> choose to restart and reset all previous connections, keep
OL> listening sockets (e.g. RESTART_DISCONNET).

Sure, sounds good to me.

>> +	printk("Doing post-restart hash\n");

(oops, looks like I left some debug messages in place)

OL> I wonder if a user can use this to convince TCP to send some nasty
OL> packets to some arbitrary destination, with specific seq-number or
OL> what not ?

I'm not sure what you mean.  The sk->num value comes from the sport
which should have been refused during the bind() if it's in use or not
permitted, no?

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
