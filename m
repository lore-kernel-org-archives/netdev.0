From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] request_irq() always returns -EINVAL with a NULL
 handler.
Date: Sat, 2 Feb 2008 22:15:02 -0800
Message-ID: <20080202221502.76d48ead.akpm@linux-foundation.org>
References: <200801171757.59026.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57946 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751776AbYBCGPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 01:15:05 -0500
In-Reply-To: <200801171757.59026.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 17:57:58 +1100 Rusty Russell <rusty@rustcorp.com.au> wrote:

> I assume that these ancient network drivers were trying to find out if
> an irq is available.  eepro.c expecting +EBUSY was doubly wrong.
> 
> I'm not sure that can_request_irq() is the right thing, but these drivers
> are definitely wrong.
> 
> request_irq should BUG() on bad input, and these would have been found
> earlier.

This breaks non-CONFIG_GENERIC_HARDIRQS architectures.

alpha:

drivers/net/3c503.c: In function 'el2_open':
drivers/net/3c503.c:382: error: implicit declaration of function 'can_request_irq'

