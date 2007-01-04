From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Fw: Intermittent SCTP multihoming breakage
Date: Wed, 03 Jan 2007 16:59:49 -0800
Message-ID: <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com>
References: <20070103154634.b40d9cde.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steve Hill <steve.hill@dialogic.com>,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42458 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932225AbXADA7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 19:59:54 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l040xq7J001121
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 19:59:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l040xqXS304426
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 19:59:52 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l040xqbr030029
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 19:59:52 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20070103154634.b40d9cde.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-03 at 15:46 -0800, Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Wed, 3 Jan 2007 11:54:26 +0000
> From: Steve Hill <steve.hill@dialogic.com>
> To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
> Subject: Intermittent SCTP multihoming breakage
> 
> 
> 
> Apologies if I'm posting to the wrong list - the lksctp lists seem to be a
> bit dead these days and a bit of Googling seemed to inidicate that SCTP
> developemnt discussions might have moved here.

No. lksctp-developers mailing list is still the best place for SCTP related
discussions. You can subscribe and look in the archives at 
  http://lists.sourceforge.net/lists/listinfo/lksctp-developers

> 
> I'm running under the 2.6.16.1 kernel and have an intermittent problem
> with the SCTP stack.  Having reviewed the git logs I can't see any
> indication that the problem has been fixed in more recent kernels, but it
> is very difficult to test since it is so intermittent.

If possible, i would suggest moving to the latest mainline 2.6.19.
But 2.6.16.1 should work OK for simple multihoming cases.

> 
> I am running a multihomed connection between 2 machines, (2 NICs on
> each machine, so 2 paths for the connection) and tcpdump shows heartbeat
> requests and acks on both paths.  Putting data over the link correctly
> sends it over the first path.
How are the 2 machines connected? Are they connected directly or
via a router?

Do you see both the addresses when you do cat /proc/net/sctp/assocs 
after the association is established on both the peers?

> 
> If I drop the traffic on one of the NICs then most of the time it
> correctly fails over the the second path and I see the data being sent
> and acknowledged correctly on the second path.  However, I also
> intermittently see two failure conditions:

How are you dropping traffic? You could try simulating failover by
bringing down the interface or physically removing the link.

> 
> 1. Sometimes, just after failing over to the second path I see an ABORT.
This seems to indicate that somehow the app has terminated.

> 2. More frequently, the association stays up indefinately, with heartbeat
> requests and acks on the second path, but no data chunks are sent even
> though the transmit queue on the transmitting end appears to be full and
> the socket is blocking writes.
This is strange. Can you collect tcpdump traces on sender and receiver when 
this happens?

Thanks
Sridhar

> 
> I have been adding debugging to the kernel in an attempt to track down the
> source of the second failure condition, and I am wondering if anyone else
> has seen similar behaviour?
> 
> --
>  - Steve Hill
>    Software Engineer
>    Dialogic
>    Fordingbridge, Hampshire, UK
>    +44-1425-651392
>    steve.hill@dialogic.com
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

