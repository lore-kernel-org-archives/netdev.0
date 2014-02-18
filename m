From: David Miller <davem@davemloft.net>
Subject: [PATCH v5 net-next 0/12] bonding: add an option to rely on
 unvalidated arp packets
Date: Tue, 18 Feb 2014 16:49:09 -0500 (EST)
Message-ID: <20140218.164909.2186300046654305367.davem@davemloft.net>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@landley.net, fubar@us.ibm.com,
	andy@greyhouse.net, dingtianhong@huawei.com, nikolay@redhat.com,
	nhorman@tuxdriver.com, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbaBRVtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 16:49:12 -0500
In-Reply-To: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 18 Feb 2014 07:48:35 +0100

> Currently, if arp_validate is off (0), slave_last_rx() returns the
> slave->dev->last_rx, which is always updated on *any* packet received by
> slave, and not only arps. This means that, if the validation of arps is
> off, we're treating *any* incoming packet as a proof of slave being up, and
> not only arps.
> 
> This might seem logical at the first glance, however it can cause a lot of
> troubles and false-positives, one example would be:
> 
> The arp_ip_target is NOT accessible, however someone in the broadcast domain
> spams with any broadcast traffic. This way bonding will be tricked that the
> slave is still up (as in - can access arp_ip_target), while it's not.
> 
> The net_device->last_rx is already used in a lot of drivers (even though the
> comment states to NOT do it :)), and it's also ugly to modify it from bonding.
> 
> However, some loadbalance setups might rely on the fact that even non-arp
> traffic is a sign of slave being up - and we definitely can't break anyones
> config - so an extension to arp_validate is needed.
> 
> So, to fix this, add an option for the user to specify if he wants to
> filter out non-arp traffic on unvalidated slaves, remove the last_rx from
> bonding, *always* call bond_arp_rcv() in slave's rx_handler (which is
> bond_handle_frame), and if we spot an arp there with this option on - update
> the slave->last_arp_rx - and use it instead of net_device->last_rx. Finally,
> rename last_arp_rx to last_rx to reflect the changes.
> 
> Also rename slave->jiffies to ->last_link_up, to reflect better its
> meaning, add the new option's documentation and update the arp_validate one
> to be a bit more descriptive.

Series applied, thanks.
