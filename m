From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 15:03:22 -0700
Message-ID: <20090325150322.40e0a1e6@nehalam>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33531 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974AbZCYWDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 18:03:41 -0400
In-Reply-To: <20090325215248.28529.62295.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Mar 2009 14:52:48 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This adds an igbvf driver to handle virtual functions provided by the
> igb driver when SR-IOV has been enabled.  A virtual function is a
> lightweight pci-e function that supports a single queue and shares
> resources with the 82576 physical function contained within the igb
> driver.
> 
> To spawn virtual functions from the igb driver all that is needed is to
> issue a echo X > /sys/class/ethY/num_vfs.  X can be a value between 0 and
> 7, 0 will disable SR-IOV functionality for the port and is the default.  If
> the num_vfs sysfs entry is not present then the device does not have SR-IOV
> capability enabled either in software or hardware.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Please don't use sysfs for this.
Instead build a proper rtnl_link netlink interface (see macvlan).

Intel doesn't invent unique hardware, other vendors will do the same
thing (or follow your lead), so doing it right the first time for these
kind of devices makes sense.
