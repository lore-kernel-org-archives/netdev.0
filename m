From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces per second
Date: Sun, 18 Oct 2009 12:13:57 -0400
Message-ID: <20091018161356.GA23395@kvack.org>
References: <20091017221857.GG1925@kvack.org> <4ADA98EE.9040509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:46279 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754630AbZJRQNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 12:13:53 -0400
Content-Disposition: inline
In-Reply-To: <4ADA98EE.9040509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 18, 2009 at 06:26:22AM +0200, Eric Dumazet wrote:
> Unfortunatly this slow down fast path by an order of magnitude.
> 
> atomic_dec() is pretty cheap (and eventually could use a per_cpu thing,
> now we have a new and sexy per_cpu allocator), but atomic_dec_and_test()
> is not that cheap and more important forbids a per_cpu conversion.

dev_put() is not a fast path by any means.  atomic_dec_and_test() costs 
the same as atomic_dec() on any modern CPU -- the cost is in the cacheline 
bouncing and serialisation both require.  The case of the device count 
becoming 0 is quite rare -- any device with a route on it will never hit 
a reference count of 0.

		-ben
