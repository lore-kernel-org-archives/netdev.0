From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 12:18:26 +0400
Message-ID: <20070813081826.GB30089@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070808095448.GA3440@2ka.mipt.ru> <20070808101708.GA23815@2ka.mipt.ru> <200708121616.10670.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42800 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968867AbXHMISx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 04:18:53 -0400
Content-Disposition: inline
In-Reply-To: <200708121616.10670.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel.

On Sun, Aug 12, 2007 at 04:16:10PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> Your patch is close to the truth, but it needs to throttle at the top 
> (virtual) end of each block device stack instead of the bottom 
> (physical) end.  It does head in the direction of eliminating your own 
> deadlock risk indeed, however there are block devices it does not 
> cover.

I decided to limit physical devices just because any limit on top of
virtual one is not correct. When system recharges bio from virtual
device to physical, and the latter is full, virtual device will not
accept any new blocks for that physical device, but can accept for
another ones. That was created specially to allow fair use for network
and physical storages.

-- 
	Evgeniy Polyakov
