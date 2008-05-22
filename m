From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/5] sky2: don't warn if page allocation fails
Date: Thu, 22 May 2008 05:57:44 -0400
Message-ID: <48354398.9070307@pobox.com>
References: <20080515000412.984337700@vyatta.com> <20080515000432.989061538@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43961 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675AbYEVJ5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 05:57:48 -0400
In-Reply-To: <20080515000432.989061538@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  
>  	for (i = 0; i < sky2->rx_nfrags; i++) {
> -		struct page *page = alloc_page(GFP_ATOMIC);
> +		struct page *page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
>  
>  		if (!page)
>  			goto free_partial;


IMO it's inappropriate to add these warnings to net drivers that 
properly check all return values.

This approach is too maintenance intensive, and winds up fixing the same 
problem over and over again -- a hint that the fix is in the wrong place.

	Jeff


