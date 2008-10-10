From: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 12:09:10 +0400
Message-ID: <20081010080910.GA31723@tservice.net.ru>
References: <20081009231759.GA8664@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:32979 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbYJJIJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 04:09:13 -0400
Content-Disposition: inline
In-Reply-To: <20081009231759.GA8664@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter.

I've enabled kernel hacking option and scheduler debugging and turned
off hrticks and performance jumped to 382 MB/s:

vanilla 27: 347.222
no TSO/GSO: 357.331
no hrticks: 382.983

I use tsc clocksource, also available acpi_pm and jiffies,
with acpi_pm performance is even lower (I stopped test after it dropped
below 340 MB/s mark), jiffies do not work at all, looks like sockets
stuck in time_wait state when this clock source is used, although that
may be some different issue.

So I think hrticks are guilty, but still not as good as .25 tree without
mentioned changes (455 MB/s) and .24 (475 MB/s).

-- 
	Evgeniy Polyakov
