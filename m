From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Wed, 2 May 2007 02:54:40 +0200
Message-ID: <65f0b79871a670eb595cca7d78e2f4e9@kernel.crashing.org>
References: <20070501165542.GA31285@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-13.arcor-online.net ([151.189.21.53]:37408 "EHLO
	mail-in-13.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992634AbXEBAyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 20:54:54 -0400
In-Reply-To: <20070501165542.GA31285@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The hardware must not see that is given ownership of a buffer until it 
> is
> completely written, and when the driver receives ownership of a buffer,
> it must ensure that any other reads to the buffer reflect its final
> state.  Thus, I/O barriers are added where required.
>
> Without this patch, I have observed GCC reordering the setting of
> bdp->length and bdp->status in gfar_new_skb.

The :::"memory" in the barriers you used prevent GCC
from reordering accesses around the barriers.

AFAICS you need stronger barriers though; {w,r,}mb(),
to prevent _any_ reordering of those memory accesses,
not just the compiler-generated ones.


Segher

