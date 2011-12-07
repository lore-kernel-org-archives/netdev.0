From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 7 Dec 2011 15:27:09 -0800
Message-ID: <20111207152709.37b5798d@nehalam.linuxnetplumber.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF07@saturn3.aculab.com>
	<b6a68bd3-eec7-47f3-bc46-2781b08d8815@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59618 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240Ab1LGX1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 18:27:12 -0500
In-Reply-To: <b6a68bd3-eec7-47f3-bc46-2781b08d8815@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> <grin> Sorry to have kicked up a storm! We really don't have a problem - just trying to optimize our environment.  We have been told by our SAN vendor that, because of the 4KB limit on block size in Linux file systems, iSCSI connections for Linux file services are latency bound and not bandwidth bound.  I'm not sure if I believe that based upon our traces where tag queueing seems to coalesce SCSI commands into larger blocks and we are able to achieve network saturation.  I was just wondering, since it is all the same traffic and hence no need to separate into bands, if I should change the qdisc on those connections from pfifo_fast (which I assume needs to look at the TOS bits, sort into bands, and poll the separate bands) to fifo which I assume simply dumps packets on the wire.  Thanks -
  John

Is this a shared network? TOS won't matter if it is only your traffic.

There are number of route metrics that you can tweak to that can reduce TCP slow
start effects, like increasing the initial cwnd, etc.
