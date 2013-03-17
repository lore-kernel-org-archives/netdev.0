From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: propagate errors from qdisc_create_dflt
Date: Sun, 17 Mar 2013 14:32:10 -0400 (EDT)
Message-ID: <20130317.143210.2198141328498450246.davem@davemloft.net>
References: <20130317093622.088bfb3f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445Ab3CQScL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 14:32:11 -0400
In-Reply-To: <20130317093622.088bfb3f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 17 Mar 2013 09:36:22 -0700

> This patch improves the error handling of default queuing discipline.
> 
> The function qdisc_create_dflt masks the error code from the underlying
> qdisc init function. Use IS_ERR() to propagate it back out to the callers.
> 
> Change the error handling of several qdisc's to report error rather than
> silently substituting a noop qdisc. Change the log level of failure to
> setup queue discipline from info to notice, since it is a real error.
> 
> In current kernel, the only likely error from pfifo_fast is out of memory,
> but the API shouldn't be hiding errors.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

If you're going to do this, you must change all the call sites so that
they don't leave error pointers in the various datastructures.

So code that does:

	foo->member = qdisc_create_dflt();

must now go:

	var = qdisc_create_dflt();
	if (IS_ERR(var))
		goto out_err;

	foo->member = var;
