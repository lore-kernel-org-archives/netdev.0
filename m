From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/33] sfc: Generate unique names for per-NIC workqueues
Date: Fri, 12 Dec 2008 22:29:54 -0800 (PST)
Message-ID: <20081212.222954.177408494.davem@davemloft.net>
References: <20081212125656.GY10372@solarflare.com>
	<20081212.220431.165056851.davem@davemloft.net>
	<20081213062301.GH10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755786AbYLMG3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:29:53 -0500
In-Reply-To: <20081213062301.GH10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 13 Dec 2008 06:23:03 +0000

> David Miller wrote:
> > create_singlethread_workqueue() is going to reference this
> > name buffer on the stack for the life of the workqueue, but
> > once this function returns that reference will no longer
> > be valid.
>  
> No, it's copied into the "comm" field of task_struct.

Hmmm...

create_singlethread_workqueue(name...
	--> __create_workqueue(name...
	--> __create_workqueue_key(name...

which goes:
	wq->cpu_wq = alloc_percpu(struct cpu_workqueue_struct);
 ...
	wq->name = name;

Which looks like a dynamic memory assumption to me.
