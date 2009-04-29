From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 10:10:57 -0700
Message-ID: <1241025057.17018.7.camel@localhost.localdomain>
References: <1240945659.8819.9.camel@Maple>
	<20090428.221605.71993506.davem@davemloft.net>	<1241012897.7487.12.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173019pub.verizon.net ([206.46.173.19]:35496 "EHLO
	vms173019pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbZD2RLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 13:11:25 -0400
Received: from [192.168.1.3] ([173.50.252.109]) by vms173019.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KIV00NFFH2A2XIU@vms173019.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Apr 2009 12:10:59 -0500 (CDT)
In-reply-to: <1241012897.7487.12.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My original NAPI implementation did not have the mmiowb() but it was
added because of some comments from Francois Romeiu (2006-06-29/30).  I
do not know if they are required or not.  My feeling was/is that they
are not as the writes are flushed with the unlocking primitives.
However that is not based on knowledge, just "feeling".

How would this be tested on all architectures to find out?

Don

-----Original Message-----
From: John Dykstra <john.dykstra1@gmail.com>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, pcnet32@verizon.net, jeff@garzik.org
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory
barriers
Date: Wed, 29 Apr 2009 08:48:17 -0500

On Tue, 2009-04-28 at 22:16 -0700, David Miller wrote:
> Any driver where these things are present usually has them
> there for a reason.  Usually it's because the SGI guys really
> did run into real problems without them on their huge
> machines which can reorder PCI MMIO wrt. real memory operations.

Is that relevant when the driver doesn't do any MMIO operations?  All
pcnet32 register accesses are via PCI I/O space, as implied by the
commit description.

Descriptors and buffers are, of course, in consistent physical memory.
This patch doesn't touch the barriers associated with those structures.

> I don't feel good applying this at all, given that I see no
> evidence that there has been any investigation into how these
> barriers got there in the first place.

Before sending out this patch, I determined that the MMIO barriers were
added as part of NAPI support.  I CCed one of the authors of that patch,
so he could NAK if appropriate.  I've added the other author on this
reply.

I knew there'd be questions about whether removing these two barriers
was safe.  Submitting the patch seemed the best way to understand why
they were needed, if they are.

  --  John

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

