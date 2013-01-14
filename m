From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: when and where does ep_poll_callback be called ?
Date: Mon, 14 Jan 2013 08:35:29 -0800
Message-ID: <50F433D1.6070809@infradead.org>
References: <20130114011115.GG2743@debian.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: horseriver <horserivers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59486 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756736Ab3ANQeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 11:34:16 -0500
In-Reply-To: <20130114011115.GG2743@debian.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/13 17:11, horseriver wrote:
> hi:
> 
> 
>    I'm studying the epoll module , I can not find ep_poll_callback be called somewhere .


It's right there in fs/eventpoll.c:


/*
 * This is the callback that is used to add our wait queue to the
 * target file wakeup lists.
 */
static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
				 poll_table *pt)
{
	struct epitem *epi = ep_item_from_epqueue(pt);
	struct eppoll_entry *pwq;

	if (epi->nwait >= 0 && (pwq = kmem_cache_alloc(pwq_cache, GFP_KERNEL))) {
>>>>>		init_waitqueue_func_entry(&pwq->wait, ep_poll_callback);
		pwq->whead = whead;
		pwq->base = epi;
		add_wait_queue(whead, &pwq->wait);
		list_add_tail(&pwq->llink, &epi->pwqlist);
		epi->nwait++;



-- 
~Randy
