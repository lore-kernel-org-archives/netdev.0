From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 17:34:55 +0400
Message-ID: <20070605133455.GA3111@2ka.mipt.ru>
References: <20070605080542.GA9909@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46254 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760447AbXFENfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 09:35:25 -0400
Content-Disposition: inline
In-Reply-To: <20070605080542.GA9909@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05, 2007 at 10:05:43AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> Hi,

Hi Jens.

> Here's an implementation of tcp network splice receive support. It's
> originally based on the patch set that Intel posted some time ago, but
> has been (close to) 100% reworked.
> 
> Now, I'm not a networking guru by any stretch of the imagination, so I'd
> like some input on the direction of the main patch. Is the approach
> feasible? Glaring errors? Missing bits?

First one - you seems to create new data_ready callback
tcp_splice_data_ready(), but it is unused, and actually can not be at 
all - there will be a deadlock, since sk_data_ready can be called with locked 
socket and also in bh context.

I will setup this and report abck about bugs.

-- 
	Evgeniy Polyakov
