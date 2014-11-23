From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/3] ixgbe: fix use after free adapter->state test in
 ixgbe_remove/ixgbe_probe
Date: Sun, 23 Nov 2014 14:27:09 -0500 (EST)
Message-ID: <20141123.142709.2057383946565296456.davem@davemloft.net>
References: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1416642774-17077-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com, stable@vger.kernel.org,
	mark.d.rustad@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1416642774-17077-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2014 23:52:53 -0800

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> While working on a different issue, I noticed an annoying use
> after free bug on my machine when unloading the ixgbe driver:
 ...
> The issue is that test_and_set_bit() done on adapter->state is being
> performed *after* the netdevice has been freed via free_netdev().
> 
> When netdev is being allocated on initialization time, it allocates
> a private area, here struct ixgbe_adapter, that resides after the
> net_device structure. In ixgbe_probe(), the device init routine,
> we set up the adapter after alloc_etherdev_mq() on the private area
> and add a reference for the pci_dev as well via pci_set_drvdata().
> 
> Both in the error path of ixgbe_probe(), but also on module unload
> when ixgbe_remove() is being called, commit 41c62843eb6a ("ixgbe:
> Fix rcu warnings induced by LER") accesses adapter after free_netdev().
> The patch stores the result in a bool and thus fixes above oops on my
> side.
> 
> Fixes: 41c62843eb6a ("ixgbe: Fix rcu warnings induced by LER")
> Cc: stable <stable@vger.kernel.org>
> Cc: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
