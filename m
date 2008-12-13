From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 25/33] sfc: Generate unique names for per-NIC workqueues
Date: Sat, 13 Dec 2008 14:01:56 +0000
Message-ID: <20081213140154.GK10372@solarflare.com>
References: <20081212125656.GY10372@solarflare.com> <20081212.220431.165056851.davem@davemloft.net> <20081213062301.GH10372@solarflare.com> <20081212.222954.177408494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:55174 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754226AbYLMOCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 09:02:04 -0500
Content-Disposition: inline
In-Reply-To: <20081212.222954.177408494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sat, 13 Dec 2008 06:23:03 +0000
> 
> > David Miller wrote:
> > > create_singlethread_workqueue() is going to reference this
> > > name buffer on the stack for the life of the workqueue, but
> > > once this function returns that reference will no longer
> > > be valid.
> >  
> > No, it's copied into the "comm" field of task_struct.
> 
> Hmmm...
> 
> create_singlethread_workqueue(name...
> 	--> __create_workqueue(name...
> 	--> __create_workqueue_key(name...
> 
> which goes:
> 	wq->cpu_wq = alloc_percpu(struct cpu_workqueue_struct);
>  ...
> 	wq->name = name;
> 
> Which looks like a dynamic memory assumption to me.

If you look carefully you'll see that wq->name is never used after
initialisation of single-threaded workqueues.  But I'd agree it's not
nice to have that dangling pointer around, so I'll respin this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
