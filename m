From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 18 Apr 2013 11:48:32 +0300
Message-ID: <20130418084832.GA16728@redhat.com>
References: <20130411153030.GA22743@redhat.com>
 <20130414134339.GA3050@htj.dyndns.org>
 <20130418083347.GA16526@redhat.com>
 <201304181240.10239.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201304181240.10239.jackm@dev.mellanox.co.il>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 12:40:09PM +0300, Jack Morgenstein wrote:
> On Thursday 18 April 2013 11:33, Michael S. Tsirkin wrote:
> > But for pci_sriov_enable, the situation is actually very simple:
> > VFs almost never use the same driver as the PF so the warning
> > is bogus there.
> > 
> What about the case where the VF driver IS the same as the PF driver?

Then it can deadlock, e.g. if driver takes a global mutex.  But it's an
internal driver issue the, you can trigger a deadlock through hardware
too, e.g. if VF initialization blocks until PF is fully initialized.
I think it's not the case for Mellanox, is it?
This is what I refer to: would be nice to fix nested probing in general
but it seems disabling the warning is the best we can do for 3.9 since
it causes false positives.


-- 
MST
