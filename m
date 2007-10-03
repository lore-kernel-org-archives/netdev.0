From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: fix race in process_backlog
Date: Wed, 3 Oct 2007 09:15:26 -0700
Message-ID: <20071003091526.2c1c6c1d@freepuppy.rosehill>
References: <1191426293.5599.27.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jeff Dike <jdike@addtoit.com>,
	David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56859 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752324AbXJCQPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 12:15:40 -0400
In-Reply-To: <1191426293.5599.27.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 03 Oct 2007 17:44:53 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Subject: net: fix race in process_backlog
> 
> The recent NAPI rework (4fa57c9ea9f36f9ca852f3a88ca5d2f1aebbc960)
> introduced a race between netif_rx() and process_backlog() which
> resulted in softirq processing to drop dead.
> 
> netif_rx()		process_backlog()
> 
> 			irq_disable();
> 			skb = __skb_dequeue();
> 			irq_enable();
> 
> irq_disable();
> __skb_queue_tail();
> napi_schedule();
> irq_enable();
> 
> 			if (!skb)
> 			  napi_complete();  <-- oops!
> 
> we cleared the napi bit, even though there is data to process.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
