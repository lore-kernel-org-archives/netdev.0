From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: where change events in epoll_wait(), and who notify an epoll event?
Date: Tue, 29 Jul 2008 10:39:09 +0400
Message-ID: <20080729063909.GB7009@2ka.mipt.ru>
References: <15da71430807281854v3e7c2536hd4e709a9a5dc7bb6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: cpusoft <cpusoft@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:51506 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246AbYG2GjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 02:39:20 -0400
Content-Disposition: inline
In-Reply-To: <15da71430807281854v3e7c2536hd4e709a9a5dc7bb6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jul 29, 2008 at 09:54:35AM +0800, cpusoft (cpusoft@gmail.com) wrote:
> But, i wonder where changes the epi->event.events? and who notify the
> epoll event ?

Nothing modifies events, only revents are used to specify mask of the
condition.

When new event is inserted into the epoll system, appropriate
driver's (attached to the file's private data)->poll() callback is
invoked. When the last parameter is non-NULL, it specifies essentially
the wait queue to attach to the private wait queue head of the driver.
When driver triggers some condition and calls
wake_up(&private_wait_queue_head), all wait queues attached there are
processed and callback stored in each one is executed. Callback for
epoll's wait queue puts given event into the ready list and wakes up
epoll_wait(), which copies data to userspace.

-- 
	Evgeniy Polyakov
