From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [DRIVER SUBMISSION] DRBD wants to go mainline
Date: Thu, 26 Jul 2007 13:17:48 +0400
Message-ID: <20070726091748.GA15925@2ka.mipt.ru>
References: <20070721203819.GA10706@mail.linbit.com> <20070722213202.1f5d1cab.mrlinuxman@mac.com> <20070723133202.GB23495@mail.linbit.com> <a781481a0707230640h17e6d83l5c2359e41f3ec7b7@mail.gmail.com> <20070723211947.GD6477@mail.linbit.com> <a781481a0707241611v3c35f6bdsb7af97d382b9298f@mail.gmail.com> <20070725094638.GA2444@mail.linbit.com> <a781481a0707250512v29d41b1bh25bcd358e7381d38@mail.gmail.com> <Pine.LNX.4.64.0707251900410.21378@asgard.lang.hm> <B3CFC70C-ADBC-406A-A2C8-908530FED007@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: david@lang.hm, Satyam Sharma <satyam.sharma@gmail.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@osdl.org>,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Kyle Moffett <mrlinuxman@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38688 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757566AbXGZJTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 05:19:15 -0400
Content-Disposition: inline
In-Reply-To: <B3CFC70C-ADBC-406A-A2C8-908530FED007@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kyle.

On Wed, Jul 25, 2007 at 11:43:38PM -0400, Kyle Moffett (mrlinuxman@mac.com) wrote:
> If you made all your sockets and inter-thread pipes nonblocking then  
> in userspace you would just epoll_wait() on the sockets and pipes and  
> be easily able to react to any IO from anywhere.
> 
> In kernel space there are similar nonblocking interfaces, although it  
> would probably be easier just to use a couple threads.

There are no such interfaces in kernel - one must create own state
machine on top of ->poll() callback, or use sys_poll()/epoll, but likely 
it is not what one wants for high-performance in-kernel event processing 
engine. Having two threads does not solve the problem - eventually one 
needs to send a header before receiving data. So, the solution would 
either to use always-blocking mode like in NBD, or create own state 
machine using ->poll() callbacks.

> Cheers,
> Kyle Moffett

-- 
	Evgeniy Polyakov
