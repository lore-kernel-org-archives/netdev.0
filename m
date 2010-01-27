From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Wed, 27 Jan 2010 09:00:16 -0800
Message-ID: <20100127090016.05138a5d@nehalam>
References: <4B605648.7020705@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42083 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab0A0RA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 12:00:27 -0500
In-Reply-To: <4B605648.7020705@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2010 00:05:44 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Allocating everything in one place means there's a single point
> of failure in sky2_up, and sky2_rx_start can no longer fail.
> 
> This also fixes a memory leak in the case that sky2_rx_start
> fails in the middle of allocating skbs, since any allocated
> skbs will not be free'd in sky2_up's failure path.

I may incorporate the cleanup, but there is no leak.
if rx_start fails, it already called rx_clean.
