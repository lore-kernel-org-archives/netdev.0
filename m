From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take3 4/4] kevent: poll/select() notifications. Timer notifications.
Date: Thu, 3 Aug 2006 11:43:02 +0200
Message-ID: <200608031143.03064.dada1@cosmosbay.com>
References: <11545983601@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:54161 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932445AbWHCJnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 05:43:11 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11545983601@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 August 2006 11:46, Evgeniy Polyakov wrote:
> poll/select() notifications. Timer notifications.
>
> +++ b/kernel/kevent/kevent_poll.c

> +static int kevent_poll_wait_callback(wait_queue_t *wait,
> +		unsigned mode, int sync, void *key)
> +{
> +	struct kevent_poll_wait_container *cont =
> +		container_of(wait, struct kevent_poll_wait_container, wait);
> +	struct kevent *k = cont->k;
> +	struct file *file = k->st->origin;
> +	unsigned long flags;
> +	u32 revents, event;
> +
> +	revents = file->f_op->poll(file, NULL);
> +	spin_lock_irqsave(&k->ulock, flags);
> +	event = k->event.event;
> +	spin_unlock_irqrestore(&k->ulock, flags);

Not sure why you take a spinlock just to read a u32

Eric
