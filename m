From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Fri, 2 Dec 2016 18:22:33 +0100
Message-ID: <20161202182233.7d78459f@redhat.com>
References: <20161201091108.GF26507@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751635AbcLBRXK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 12:23:10 -0500
In-Reply-To: <20161201091108.GF26507@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 1 Dec 2016 10:11:08 +0100 Florian Westphal <fw@strlen.de> wrote:

> In light of DPDKs existence it make a lot more sense to me to provide
> a). a faster mmap based interface (possibly AF_PACKET based) that allows
> to map nic directly into userspace, detaching tx/rx queue from kernel.
> 
> John Fastabend sent something like this last year as a proof of
> concept, iirc it was rejected because register space got exposed directly
> to userspace.  I think we should re-consider merging netmap
> (or something conceptually close to its design).

I'm actually working in this direction, of zero-copy RX mapping packets
into userspace.  This work is mostly related to page_pool, and I only
plan to use XDP as a filter for selecting packets going to userspace,
as this choice need to be taken very early.

My design is here:
 https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html

This is mostly about changing the memory model in the drivers, to allow
for safely mapping pages to userspace.  (An efficient queue mechanism is
not covered).  People often overlook that netmap's efficiency *also* comes
from introducing pre-mapping memory/pages to userspace.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
