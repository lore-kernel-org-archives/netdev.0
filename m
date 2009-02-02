From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: create connector workqueue only while needed once
Date: Mon, 2 Feb 2009 14:06:13 +0300
Message-ID: <20090202110613.GA11413@ioremap.net>
References: <498638ad.1438560a.537e.51b8@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>, Li Zefan <lizf@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:34056 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbZBBLGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 06:06:25 -0500
Content-Disposition: inline
In-Reply-To: <498638ad.1438560a.537e.51b8@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Feb 01, 2009 at 04:05:01PM -0800, Frederic Weisbecker (fweisbec@gmail.com) wrote:
> The netlink connector uses its own workqueue to relay the datas sent from
> userspace to the appropriate callback.
> If you launch the test from Documentation/connector and change it a bit to send
> a high flow of data, you will see thousands of events coming to the "cqueue" workqueue
> by looking at the workqueue tracer.
> 
> This flow of events can be sent very quickly. So, to not encumber the kevent workqueue and
> delay other jobs, the "cqueue" workqueue should remain.
> 
> But this workqueue is pointless most of the time, it will always be created (assuming you have
> built it of course) although only developpers with specific needs will use it.
> 
> So avoid this "most of the time useless task", this patch proposes to create this workqueue only when needed
> once.
> The first jobs to be sent to connector callbacks will be sent to kevent while the "cqueue" thread creation
> will be scheduled to kevent too.
> 
> The following jobs will continue to be scheduled to keventd until the cqueue workqueue is created, and then
> the rest of the jobs will continue to perform as usual, through this dedicated workqueue.
> 
> Each time I tested this patch, only the first event was sent to keventd, the rest has been sent to cqueue which
> have been created quickly.
> 
> Also, this patch fixes some trailing whitespaces on the connector files.
> 
> Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>

Looks very good, thanks a lot Frederic.
Ack.

-- 
	Evgeniy Polyakov
