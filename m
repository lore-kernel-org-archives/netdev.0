From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 11 Apr 2013 11:05:17 -0700
Message-ID: <20130411180517.GJ17641@mtj.dyndns.org>
References: <20130411153030.GA22743@redhat.com>
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:62453 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936163Ab3DKSFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 14:05:24 -0400
Content-Disposition: inline
In-Reply-To: <20130411153030.GA22743@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Apr 11, 2013 at 06:30:30PM +0300, Michael S. Tsirkin wrote:
> The issue is that a driver, in it's probe function, calls
> pci_sriov_enable so a PF device probe causes VF probe (AKA nested
> probe).  Each probe in pci_device_probe is (normally) run through
> work_on_cpu (this is to get the right numa node for memory allocated by
> the driver).  In turn work_on_cpu does this internally:
> 
>         schedule_work_on(cpu, &wfc.work);
>         flush_work(&wfc.work);
> 
> So if you are running probe on CPU1, and cause another
> probe on the same CPU, this will try to flush
> workqueue from inside same workqueue which of course
> deadlocks.
> 
> Nested probing might be tricky to get right generally.

Hmm... how about adding a work_on_cpu_nested() which takes @subclass
argument?  Wouldn't that be much cleaner?

Thanks.

-- 
tejun
