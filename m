From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Intermittent SCTP multihoming breakage
Date: Wed, 3 Jan 2007 15:46:34 -0800
Message-ID: <20070103154634.b40d9cde.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:32818 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197AbXACXqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 18:46:39 -0500
To: sri@us.ibm.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 3 Jan 2007 11:54:26 +0000
From: Steve Hill <steve.hill@dialogic.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Intermittent SCTP multihoming breakage



Apologies if I'm posting to the wrong list - the lksctp lists seem to be a
bit dead these days and a bit of Googling seemed to inidicate that SCTP
developemnt discussions might have moved here.

I'm running under the 2.6.16.1 kernel and have an intermittent problem
with the SCTP stack.  Having reviewed the git logs I can't see any
indication that the problem has been fixed in more recent kernels, but it
is very difficult to test since it is so intermittent.

I am running a multihomed connection between 2 machines, (2 NICs on
each machine, so 2 paths for the connection) and tcpdump shows heartbeat
requests and acks on both paths.  Putting data over the link correctly
sends it over the first path.

If I drop the traffic on one of the NICs then most of the time it
correctly fails over the the second path and I see the data being sent
and acknowledged correctly on the second path.  However, I also
intermittently see two failure conditions:

1. Sometimes, just after failing over to the second path I see an ABORT.
2. More frequently, the association stays up indefinately, with heartbeat
requests and acks on the second path, but no data chunks are sent even
though the transmit queue on the transmitting end appears to be full and
the socket is blocking writes.

I have been adding debugging to the kernel in an attempt to track down the
source of the second failure condition, and I am wondering if anyone else
has seen similar behaviour?

-- 
 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
