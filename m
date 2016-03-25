From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netpoll: Fix extra refcount release in
 netpoll_cleanup()
Date: Fri, 25 Mar 2016 11:24:38 -0400 (EDT)
Message-ID: <20160325.112438.1680393079835321066.davem@davemloft.net>
References: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	nhorman@redhat.com, aduyck@mirantis.com,
	linux-kernel@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 24 Mar 2016 21:56:21 -0500

> netpoll_setup() does a dev_hold() on np->dev, the netpoll device.  If it
> fails, it correctly does a dev_put() but leaves np->dev set.  If we call
> netpoll_cleanup() after the failure, np->dev is still set so we do another
> dev_put(), which decrements the refcount an extra time.
> 
> It's questionable to call netpoll_cleanup() after netpoll_setup() fails,
> but it can be difficult to find the problem, and we can easily avoid it in
> this case.  The extra decrements can lead to hangs like this:
> 
>   unregister_netdevice: waiting for bond0 to become free. Usage count = -3
> 
> Set and clear np->dev at the points where we dev_hold() and dev_put() the
> device.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Looks good, applied and queued up for -stable.

But you probably do want to look into the stacked device issue
Neil pointed out.

Thanks!
