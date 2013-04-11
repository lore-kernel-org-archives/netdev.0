From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 11 Apr 2013 21:58:54 +0300
Message-ID: <20130411185853.GE23301@redhat.com>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
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
Received: from mx1.redhat.com ([209.132.183.28]:44451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab3DKS7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 14:59:16 -0400
Content-Disposition: inline
In-Reply-To: <20130411180517.GJ17641@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 11:05:17AM -0700, Tejun Heo wrote:
> Hello,
> 
> On Thu, Apr 11, 2013 at 06:30:30PM +0300, Michael S. Tsirkin wrote:
> > The issue is that a driver, in it's probe function, calls
> > pci_sriov_enable so a PF device probe causes VF probe (AKA nested
> > probe).  Each probe in pci_device_probe is (normally) run through
> > work_on_cpu (this is to get the right numa node for memory allocated by
> > the driver).  In turn work_on_cpu does this internally:
> > 
> >         schedule_work_on(cpu, &wfc.work);
> >         flush_work(&wfc.work);
> > 
> > So if you are running probe on CPU1, and cause another
> > probe on the same CPU, this will try to flush
> > workqueue from inside same workqueue which of course
> > deadlocks.
> > 
> > Nested probing might be tricky to get right generally.
> 
> Hmm... how about adding a work_on_cpu_nested() which takes @subclass
> argument?  Wouldn't that be much cleaner?
> 
> Thanks.

Is that 3.9 material though?

> -- 
> tejun
