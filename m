From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: Fix out of bounds access to tcpm_vals
Date: Wed, 11 Jul 2012 17:32:49 -0700 (PDT)
Message-ID: <20120711.173249.1303803416502735349.davem@davemloft.net>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	alexander.duyck@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab2GLAcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 20:32:50 -0400
In-Reply-To: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 11 Jul 2012 17:18:04 -0700

> The recent patch "tcp: Maintain dynamic metrics in local cache." introduced
> an out of bounds access due to what appears to be a typo.   I believe this
> change should resolve the issue by replacing the access to RTAX_CWND with
> TCP_METRIC_CWND.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks a lot.

How did you spot this, did you get a compiler warning?

I ask because while working on this, I at one point put the
tcp timestamp members after the metrics array in the
tcp_metrics_bucket struct.  And I got a warning from gcc about
an array bounds violation that I could not figure out.

I am pretty certain this bug here is what it was warning about.  And
the problem is that if you put the array at the end gcc doesn't warn
in order to handle things similar to what people use zero length
arrays for.
