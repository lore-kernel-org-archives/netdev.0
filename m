From: David Miller <davem@davemloft.net>
Subject: Re: [net 00/10][pull request] Intel Wired LAN Driver Updates
 2015-06-26
Date: Sun, 28 Jun 2015 17:20:50 -0700 (PDT)
Message-ID: <20150628.172050.1197989737543500259.davem@davemloft.net>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637AbbF2AUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 20:20:52 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Jun 2015 03:20:30 -0700

> This series contains fixes for igb, e1000e and i40evf.
> 
> Todd disables IPv6 extension header processing due to a hardware errata
> and bumps the driver version.
> 
> Yanir provides six fixes for e1000e.  First is a fix for a locking issue
> where we were not always taking the pci_bus_sem semaphore all the time
> when calling pci_disable_link_state_locked(), so fix the code to only call
> pci_disable_link_state_locked() when the semaphore has been acquired,
> otherwise call pci_disable_link_state().  A previous fix for i219 where
> the hardware prevented ULP entry caused EEE in Sx not the be enabled, so
> modify the code flow that allows both ULP and EEE in Sx.  Fix an issue
> when running 10/100 full duplex on i219 where CRC errors were occurring
> by increasing the IPG from 8 to 0xC as per the hardware developers.
> Fix a data corruption issue found on some platforms by increasing the
> minimum gap between the PHY FIFO read and write pointers.  Fix i219,
> which does not require the K1 workaround for LPT devices.
> 
> Mitch provides a i40evf fix for a panic when changing MTU.  Down was
> requesting queue disables, but then exited immediately without waiting
> for the queues to actually be disabled.  This could allow any function
> called after i40evf_down() to run immediately, including i40evf_up(),
> and causes a memory leak.  Fixed the issue by removing the whole
> reinit_locked function which allows for the driver to handle the state
> changes by requesting reset from the periodic timer.  The second fix
> resolves an issue where RSS was being configured as though it is using
> the maximum number of queue.  This can cause the device to drop a lot
> of receive traffic, as the packets get assigned to non-functional queues.
> This is resolved by only configuring RSS with the number of active queues.

Pulled, thanks Jeff.
