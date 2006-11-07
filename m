From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 7 Nov 2006 11:34:00 -0800
Message-ID: <20061107113400.880e1ce9.akpm@osdl.org>
References: <11619654014077@2ka.mipt.ru>
	<45506D51.30604@garzik.org>
	<20061107115111.GA13028@2ka.mipt.ru>
	<45507CD4.5030600@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18838 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752129AbWKGTfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 14:35:33 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45507CD4.5030600@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Nov 2006 07:32:20 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> Evgeniy Polyakov wrote:
> > Mmap ring buffer implementation was stopped by Andrew Morton and Ulrich
> > Drepper, process' memory is used instead. copy_to_user() is slower (and
> > some times noticebly), but there are major advantages of such approach.
> 
> 
> hmmmm.  I say there are advantages to both.

My problem with the old mmapped ringbuffer was that it permitted each user
to pin (typically) 48MB of unswappable memory.  Plus this pinned-memory
problem would put upper bounds on the ring size.

> Perhaps create a "kevent_direct_limit" resource limit for each thread. 
> By default, each thread could mmap $n pinned pagecache pages.  Sysadmin 
> can tune certain app resource limits to permit more.
> 
> I would think that retaining the option to avoid copy_to_user() 
> -somehow- in -some- cases would be wise.

What Evgeniy means here is that copy_to_user() is slower than memcpy() (on
his machine, with his kernel config, at least).

Which is kinda weird and unexpected and is something which we should
investigate independently from this project.  (Rather than simply going
and bypassing it!)

