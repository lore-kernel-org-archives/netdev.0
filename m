From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor
 ownership.
Date: Wed, 02 May 2007 11:04:03 -0500
Message-ID: <4638B673.4090504@freescale.com>
References: <20070501165542.GA31285@ld0162-tx32.am.freescale.net> <65f0b79871a670eb595cca7d78e2f4e9@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:34765 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993426AbXEBQEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 12:04:21 -0400
In-Reply-To: <65f0b79871a670eb595cca7d78e2f4e9@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Segher Boessenkool wrote:
>> The hardware must not see that is given ownership of a buffer until it is
>> completely written, and when the driver receives ownership of a buffer,
>> it must ensure that any other reads to the buffer reflect its final
>> state.  Thus, I/O barriers are added where required.
>>
>> Without this patch, I have observed GCC reordering the setting of
>> bdp->length and bdp->status in gfar_new_skb.
> 
> 
> The :::"memory" in the barriers you used prevent GCC
> from reordering accesses around the barriers.

Sure... it was just an example to point out that it's actually 
happening, rather than a theoretical concern.

> AFAICS you need stronger barriers though; {w,r,}mb(),
> to prevent _any_ reordering of those memory accesses,
> not just the compiler-generated ones.

My impression was that the eieio used by iobarrier would be sufficient 
for that, as we're not trying to synchronize between accesses to 
different types of memory.  Is sync really required here?

-Scott
