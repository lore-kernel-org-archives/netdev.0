From: horseriver <horserivers@gmail.com>
Subject: Re: when and where does ep_poll_callback be called ?
Date: Mon, 14 Jan 2013 15:52:57 +0800
Message-ID: <20130114075257.GE4289@debian.localdomain>
References: <20130114011115.GG2743@debian.localdomain>
 <50F433D1.6070809@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:62337 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376Ab3ANRfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:35:07 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so1915456dak.30
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 09:35:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50F433D1.6070809@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 14, 2013 at 08:35:29AM -0800, Randy Dunlap wrote:
> On 01/13/13 17:11, horseriver wrote:
> > hi:
> > 
> > 
> >    I'm studying the epoll module , I can not find ep_poll_callback be called somewhere .
> 
> 
> It's right there in fs/eventpoll.c:
> 
> 
> /*
>  * This is the callback that is used to add our wait queue to the
>  * target file wakeup lists.
>  */
> static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
> 				 poll_table *pt)
> {
> 	struct epitem *epi = ep_item_from_epqueue(pt);
> 	struct eppoll_entry *pwq;
> 
> 	if (epi->nwait >= 0 && (pwq = kmem_cache_alloc(pwq_cache, GFP_KERNEL))) {
> >>>>>		init_waitqueue_func_entry(&pwq->wait, ep_poll_callback);

     Thanks!
     
     I know this is setting  the callbak function into watqueue . But not the called place . 

     I want to know the code which calls  ep_poll_callback .

     Perhaps , it is called at tcp layer when a datagram is reached . but I have not find that key  code .

     

> 		pwq->whead = whead;
> 		pwq->base = epi;
> 		add_wait_queue(whead, &pwq->wait);
> 		list_add_tail(&pwq->llink, &epi->pwqlist);
> 		epi->nwait++;
> 
> 
> 
> -- 
> ~Randy
