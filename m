From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Mon, 27 Aug 2007 14:57:37 -0700
Message-ID: <200708271457.38100.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070808095448.GA3440@2ka.mipt.ru> <20070808101708.GA23815@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phunq.net ([64.81.85.152]:53937 "EHLO moonbase.phunq.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765103AbXH0V6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 17:58:17 -0400
In-Reply-To: <20070808101708.GA23815@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Say Evgeniy, something I was curious about but forgot to ask you 
earlier...

On Wednesday 08 August 2007 03:17, Evgeniy Polyakov wrote:
> ...All oerations are not atomic, since we do not care about precise
> number of bios, but a fact, that we are close or close enough to the
> limit. 
> ... in bio->endio
> +			q->bio_queued--;

In your proposed patch, what prevents the race:

			cpu1						cpu2

	read q->bio_queued
									q->bio_queued--
	write q->bio_queued - 1
	Whoops! We leaked a throttle count.

Regards,

Daniel
