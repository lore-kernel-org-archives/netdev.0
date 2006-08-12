From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 3/4] deadlock prevention core
Date: Sat, 12 Aug 2006 10:41:58 -0400
Message-ID: <44DDE8B6.8000900@garzik.org>
References: <20060812141415.30842.78695.sendpatchset@lappy> <20060812141445.30842.47336.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:961 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932537AbWHLOmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 10:42:06 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060812141445.30842.47336.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> Index: linux-2.6/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.orig/include/linux/gfp.h	2006-08-12 12:56:06.000000000 +0200
> +++ linux-2.6/include/linux/gfp.h	2006-08-12 12:56:09.000000000 +0200
> @@ -46,6 +46,7 @@ struct vm_area_struct;
>  #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
>  #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
>  #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
> +#define __GFP_MEMALLOC  ((__force gfp_t)0x40000u) /* Use emergency reserves */

This symbol name has nothing to do with its purpose.  The entire area of 
code you are modifying could be described as having something to do with 
'memalloc'.

GFP_EMERGENCY or GFP_USE_RESERVES or somesuch would be a far better 
symbol name.

I recognize that is matches with GFP_NOMEMALLOC, but that doesn't change 
the situation anyway.  In fact, a cleanup patch to rename GFP_NOMEMALLOC 
would be nice.

	Jeff


