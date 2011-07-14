From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: preempting while holding rtnl_lock
Date: Fri, 15 Jul 2011 00:06:31 +0100
Message-ID: <1310684791.8783.261.camel@localhost>
References: <20110714181502.4a5602aa@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58441 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437Ab1GNXGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 19:06:36 -0400
In-Reply-To: <20110714181502.4a5602aa@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-14 at 18:15 -0300, Flavio Leitner wrote:
> Hi,
> 
> I was reviewing driver sources and found that
> ethtool ops holds rtnl_lock() and there are few
> drivers (for example: tg3, bnx2) that use napi_disable()
> in this context.
[...]
> The msleep() above will preempt.  I believe this is wrong.
[...]
> What am I missing?

The RTNL lock is a mutex so it's OK to sleep (but preferably not very
long) while holding it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

