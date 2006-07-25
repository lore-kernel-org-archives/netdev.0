From: Pavel Roskin <proski@gnu.org>
Subject: Can we have GET_NETDEV_DEV?
Date: Tue, 25 Jul 2006 00:52:25 -0400
Message-ID: <1153803145.23803.19.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:46264 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932449AbWGYEwa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 00:52:30 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1G5EuD-0005VP-Ft
	for netdev@vger.kernel.org; Tue, 25 Jul 2006 00:52:29 -0400
To: netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

gregkh-driver-network-class_device-to-device.patch, which briefly
appeared in Linux 2.6.18-rc1-mm1 broke MadWifi, which is copying the
physical device information from the master network device to the
virtual network devices:

SET_NETDEV_DEV(dev, mdev->class_dev.dev);

The same code exists in hostap.  The patch is gone from 2.6.18-rc1-mm2,
but I'd like to be prepared if it reappears.

An easy solution would be to have GET_NETDEV_DEV macro.  Then the
drivers could do this:

SET_NETDEV_DEV(dev, GET_NETDEV_DEV(mdev));

without having to worry about the internals of struct net_device.  It
should be done before class_dev is removed or in the same time.

Should I send a patch?

-- 
Regards,
Pavel Roskin


