From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 07/15] ehea: Allocate large enough skbs to avoid
 partial cacheline DMA writes
Date: Thu, 12 May 2011 03:52:48 +0100
Message-ID: <1305168768.4065.382.camel@localhost>
References: <20110512005213.897432612@samba.org>
	 <20110512005623.100278010@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12283 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab1ELCww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 22:52:52 -0400
In-Reply-To: <20110512005623.100278010@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> plain text document attachment (ehea_8.patch)
> The ehea adapter has a mode where it will avoid partial cacheline DMA
> writes on receive by always padding packets to fall on a cacheline
> boundary.
> 
> Unfortunately we currently aren't allocating enough space for a full
> ethernet MTU packet to be rounded up, so this optimisation doesn't hit.
> 
> It's unfortunate that the next largest packet size exposed by the
> hypervisor interface is 2kB, meaning our skb allocation comes out of a
> 4kB SLAB. However the performance increase due to this optimisation is
> quite large and my TCP stream numbers increase from 900MB to 1000MB/sec.

You can allocate page buffers and then split them into exactly 2K
segments.  If you switch from inet_lro to GRO then GRO will handle the
eventual skb allocation for you (even for non-mergeable packets).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

