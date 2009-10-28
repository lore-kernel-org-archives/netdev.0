From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 13:12:24 -0700
Message-ID: <OFF3B08FBF.39A0F6F8-ON8825765D.006E5150-8825765D.006EFF93@us.ibm.com>
References: <1256683583.3153.389.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37992 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbZJ1UMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:12:48 -0400
In-Reply-To: <1256683583.3153.389.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't gone through the entire thread yet, but I should point
out that this appears to break regular IP fragmentation for
unicast packets. There is no restriction whatsoever that
fragments from a remote destination that are actually for
the same datagram need to be routed on the same paths
and received on the same input interface.

For the multicast case, if they are from the same datagram,
it doesn't matter how you got them. If it's a different datagram
with the same ID, which can happen anyway, the checksum
should fail (at least (64K-1) of 64K cases). I don't see a special
case here, other than that you can tell by the interface if it was
actually a distinct datagram with the same ID in the multicast
case (and only in multicast and only if the different interfaces
are not in the same multicast routing domain).

NACK.

                                        +-DLS

