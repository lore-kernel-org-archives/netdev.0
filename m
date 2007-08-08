From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Wed, 8 Aug 2007 17:28:53 +0400
Message-ID: <20070808132853.GA19488@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net> <20070807120523.GX5245@kernel.dk> <200708071124.56859.phillips@phunq.net> <20070807205538.GB5245@kernel.dk> <20070808095448.GA3440@2ka.mipt.ru> <20070808101708.GA23815@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Phillips <phillips@phunq.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44767 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432AbXHHN3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 09:29:51 -0400
Content-Disposition: inline
In-Reply-To: <20070808101708.GA23815@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 02:17:09PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> This throttling mechanism allows to limit maximum amount of queued bios 
> per physical device. By default it is turned off and old block layer 
> behaviour with unlimited number of bios is used. When turned on (queue
> limit is set to something different than -1U via blk_set_queue_limit()),
> generic_make_request() will sleep until there is room in the queue.
> number of bios is increased in generic_make_request() and reduced either
> in bio_endio(), when bio is completely processed (bi_size is zero), and
> recharged from original queue when new device is assigned to bio via
> blk_set_bdev(). All oerations are not atomic, since we do not care about
> precise number of bios, but a fact, that we are close or close enough to
> the limit.
> 
> Tested on distributed storage device - with limit of 2 bios it works
> slow :)

As addon I can cook up a patch to configure this via sysfs if needed.
Thoughts?

-- 
	Evgeniy Polyakov
