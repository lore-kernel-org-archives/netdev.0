From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 3/5] AF_RXRPC: Make it possible to merely try to cancel
 timers and delayed work [try #2]
Date: Fri, 16 Mar 2007 15:07:05 +0000
Message-ID: <20070316150705.0b2fbeb0@lxorguk.ukuu.org.uk>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<20070316125026.3740.56876.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:51570 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S964807AbXCPOEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 10:04:06 -0400
In-Reply-To: <20070316125026.3740.56876.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/**
> + * try_to_cancel_delayed_work - Try to kill pending scheduled, delayed work
> + * @work: the work to cancel
> + *
> + * Try to kill off a pending schedule_delayed_work().
> + * - The timer may still be running afterwards, and if so, the work may still
> + *   be pending
> + * - Returns -1 if timer still active, 1 if timer removed, 0 if not scheduled
> + * - Can be called from the work routine; if it's still pending, just return
> + *   and it'll be called again.
> + */
> +static inline int try_to_cancel_delayed_work(struct delayed_work *work)
> +{
> +	int ret;

This expands to a fair bit of code and IMHO isn't an inline candidate.

