From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 11 Apr 2013 23:30:53 +0300
Message-ID: <20130411203053.GC25515@redhat.com>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
 <20130411185853.GE23301@redhat.com>
 <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932875Ab3DKUbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 16:31:13 -0400
Content-Disposition: inline
In-Reply-To: <20130411192005.GN17641@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 12:20:05PM -0700, Tejun Heo wrote:
> On Thu, Apr 11, 2013 at 10:17:17PM +0300, Michael S. Tsirkin wrote:
> > Hmm no, there's a real deadlock here: you are
> > trying to flush from work1 from within work2 running
> > on same workqueue. work2 can't event start running.
> > The problem is not annotation.
> 
> No, that has changed years ago with introduction of cmwq.  System
> workqueues are now expected to have high enough maximum concurrency to
> not cause deadlock as long as memory for worker creation is available,
> so as long as your work item doesn't directly sit in the memory
> reclaim path, it's safe to flush a different work item running on the
> same workqueue with sufficiently high max_active.
> 
> Thanks.

Okay, so you are saying it's a false-positive?
Want to send a patch so Or can try it out?

> -- 
> tejun
