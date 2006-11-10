From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] spidernet: fix transmit routine.
Date: Fri, 10 Nov 2006 11:30:50 -0800
Message-ID: <20061110113050.5689c226@freekitty>
References: <20061110105038.200a74d0@freekitty>
	<OFF9C5DB9C.8DD003F3-ON87257222.0068A615-86257222.006950CA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	jim@jklewis.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23749 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946730AbWKJTbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 14:31:19 -0500
To: James K Lewis <jklewis@us.ibm.com>
In-Reply-To: <OFF9C5DB9C.8DD003F3-ON87257222.0068A615-86257222.006950CA@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 13:10:25 -0600
James K Lewis <jklewis@us.ibm.com> wrote:

> Stephen,
> 
>   I had already tried that previously, the fail still occurred. Note that 
> the skb_pad (or skb_padto) never actually fails. There is just something 
> about calling it that causes the hang. Note too that I believe your patch 
> is incorrect, you would still have to pci_unmap_single the correct length 
> (skb_pad does not actually change skb->len which just seems plain wrong to 
> me).

Yeah, that was a bad choice not to set skb->len to start with. Too late
now given how it might affect other drivers.

>   I checked, and none of our "mainstream" PPC ethernet drivers (e100, 
> e1000, pcnet32, tg3) have this check in them. When I have time I may add 
> the pad to pcnet32 (for example) to see if it fails.

The hardware for all these drivers does padding.


> Jim Lewis
> Advisory Software Engineer
> IBM Linux Technology Center
> 512-838-7754
> 
> 
