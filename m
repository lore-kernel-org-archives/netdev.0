From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 08:48:17 -0500
Message-ID: <1241012897.7487.12.camel@Maple>
References: <1240945659.8819.9.camel@Maple>
	 <20090428.221605.71993506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pcnet32@verizon.net, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:1323 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbZD2NsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 09:48:21 -0400
Received: by yx-out-2324.google.com with SMTP id 3so685219yxj.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 06:48:20 -0700 (PDT)
In-Reply-To: <20090428.221605.71993506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

