From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer interface.
Date: Sat, 19 Apr 2008 20:33:22 +0400
Message-ID: <20080419163322.GA17089@2ka.mipt.ru>
References: <200804181433.48488.rusty@rustcorp.com.au> <200804181439.49051.rusty@rustcorp.com.au> <20080419102214.GA21952@2ka.mipt.ru> <200804200205.31508.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49764 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbYDSQeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2008 12:34:19 -0400
Content-Disposition: inline
In-Reply-To: <200804200205.31508.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 20, 2008 at 02:05:31AM +1000, Rusty Russell (rusty@rustcorp.com.au) wrote:
> > Should this whole function and vring_used_buffer() be protected with
> > vr->lock mutex?
> 
> No; it's up to the caller to make sure that they are serialized.  In the case 
> of tun that happens naturally.
> 
> There are two reasons not to grab the lock.  It turns out that if we tried to 
> lock here, we'd deadlock, since the callbacks are called under the lock.  
> Secondly, it's possible to implement an atomic vring_used_buffer variant, 
> which could fail: this would avoid using the thread most of the time.

Yep, I decided that too. But it limits its usage to tun only or any
other system where only single thread picks up results, so no generic
userspace ring buffers?

-- 
	Evgeniy Polyakov
