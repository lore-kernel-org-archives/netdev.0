From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Sat, 17 May 2008 07:57:26 -0700
Message-ID: <482EF256.8030305@linux.intel.com>
References: <fa.LFS/TATb5YijFetLw6A+gczrVAQ@ifi.uio.no> <482E3B1B.9070400@shaw.ca> <20080517141235.GA13130@duo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Hancock <hancockr@shaw.ca>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Axboe <jens.axboe@oracle.com>
To: Andrea Arcangeli <andrea@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:21990 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750812AbYEQO5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 10:57:31 -0400
In-Reply-To: <20080517141235.GA13130@duo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrea Arcangeli wrote:
> The reason I touched that code, is that a change introduced during
> 2.6.25-rc initialized the isa dma pool even if not necessary and that
> broke the reserved-ram patch that requires no __GFP_DMA
> allocations. There was no crash in 2.6.24 based kernels, the
> regression started in 2.6.25-rc.

I'd not really call "breaks external patch" a regression ;)


What we really ought to be doing is always initialize the pool, from
the right process context. However, we need to make it such that we
can detect that there is zero __GFP_DMA memory in the system, and bail
out in that case. Doing it on-demand is just not going to fly; by that
time it's just too late (the pool may have been eaten already, the context
might be nasty to do allocations from etc etc).

the sata_nv driver has to do it on finding a cdrom; afaik it has something
like a different DMA mask for disks and cdroms, and it scales down once you
insert a CD.

