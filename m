From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/2][INET] (resend) Fix potential kfree on vmalloc-ed
 area of request_sock_queue
Date: Thu, 15 Nov 2007 10:21:01 +0100
Message-ID: <20071115102101.c1b928b7.dada1@cosmosbay.com>
References: <473C0641.2010501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:53141 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758561AbXKOJVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 04:21:03 -0500
In-Reply-To: <473C0641.2010501@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 11:41:37 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> The request_sock_queue's listen_opt is either vmalloc-ed or
> kmalloc-ed depending on the number of table entries. Thus it 
> is expected to be handled properly on free, which is done in 
> the reqsk_queue_destroy().
> 
> However the error path in inet_csk_listen_start() calls 
> the lite version of reqsk_queue_destroy, called 
> __reqsk_queue_destroy, which calls the kfree unconditionally. 
> 
> Fix this and move the __reqsk_queue_destroy into a .c file as 
> it looks too big to be inline.
> 
> As David also noticed, this is an error recovery path only,
> so no locking is required and the lopt is known to be not NULL.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Thank you for finding this bug Pavel

