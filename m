From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Thu, 18 Apr 2013 12:57:50 +0300
Message-ID: <201304181257.50915.jackm@dev.mellanox.co.il>
References: <20130411153030.GA22743@redhat.com> <201304181240.10239.jackm@dev.mellanox.co.il> <20130418084832.GA16728@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:63768 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3DRJ5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 05:57:23 -0400
Received: by mail-we0-f177.google.com with SMTP id o7so2050227wea.8
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 02:57:22 -0700 (PDT)
In-Reply-To: <20130418084832.GA16728@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 April 2013 11:48, Michael S. Tsirkin wrote:
> On Thu, Apr 18, 2013 at 12:40:09PM +0300, Jack Morgenstein wrote:
> > On Thursday 18 April 2013 11:33, Michael S. Tsirkin wrote:
> > > But for pci_sriov_enable, the situation is actually very simple:
> > > VFs almost never use the same driver as the PF so the warning
> > > is bogus there.
> > > 
> > What about the case where the VF driver IS the same as the PF driver?
> 
> Then it can deadlock, e.g. if driver takes a global mutex.  But it's an
> internal driver issue the, you can trigger a deadlock through hardware
> too, e.g. if VF initialization blocks until PF is fully initialized.
> I think it's not the case for Mellanox, is it?

Correct, the Mellanox driver does not deadlock.

> This is what I refer to: would be nice to fix nested probing in general
> but it seems disabling the warning is the best we can do for 3.9 since
> it causes false positives.
> 
> 
