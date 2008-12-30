From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: foreach_netdev_safe is insufficient in
 default_device_exit
Date: Mon, 29 Dec 2008 18:21:59 -0800 (PST)
Message-ID: <20081229.182159.234047580.davem@davemloft.net>
References: <m1y6y04t50.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751281AbYL3CV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 21:21:56 -0500
In-Reply-To: <m1y6y04t50.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 28 Dec 2008 00:10:35 -0800

> During network namespace teardown we either move or delete
> all of the network devices associated with a network namespace.
> In the case of veth devices deleting one will also delete it's
> pair device.  If both devices are in the same network namespace
> then for_each_netdev_safe is insufficient as next may point
> to the second veth device we have deleted.
> 
> To avoid problems I do what we do in __rtnl_kill_links and
> restart the scan of the device list, after we have deleted
> a device.
> 
> Currently dev_change_netnamespace does not appear to suffer from
> this problem, but wireless devices are also paired and likely
> should be moved between network namespaces together.  So I have
> errored on the side of caution and restart the scan of the network
> devices in that case as well.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Looks good, applied.

Thanks Eric.
