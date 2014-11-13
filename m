From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: generic dev_disable_lro() stacked
 device handling
Date: Thu, 13 Nov 2014 14:49:28 -0500 (EST)
Message-ID: <20141113.144928.993194909814299360.davem@davemloft.net>
References: <20141111.214752.266800170368088905.davem@davemloft.net>
	<20141113065450.1645FA0BEF@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	jiri@resnulli.us
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113065450.1645FA0BEF@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 13 Nov 2014 07:54:50 +0100 (CET)

> Large receive offloading is known to cause problems if received packets
> are passed to other host. Therefore the kernel disables it by calling
> dev_disable_lro() whenever a network device is enslaved in a bridge or
> forwarding is enabled for it (or globally). For virtual devices we need
> to disable LRO on the underlying physical device (which is actually
> receiving the packets).
> 
> Current dev_disable_lro() code handles this  propagation for a vlan
> (including 802.1ad nested vlan), macvlan or a vlan on top of a macvlan.
> It doesn't handle other stacked devices and their combinations, in
> particular propagation from a bond to its slaves which often causes
> problems in virtualization setups.
> 
> As we now have generic data structures describing the upper-lower device
> relationship, dev_disable_lro() can be generalized to disable LRO also
> for all lower devices (if any) once it is disabled for the device
> itself.
> 
> For bonding and teaming devices, it is necessary to disable LRO not only
> on current slaves at the moment when dev_disable_lro() is called but
> also on any slave (port) added later.
> 
> v2: use lower device links for all devices (including vlan and macvlan)
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thanks a lot.
