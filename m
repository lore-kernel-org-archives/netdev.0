From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Cannot delete a bridge using 'ip' netlink interface
Date: Thu, 06 Oct 2011 10:18:52 -0700
Message-ID: <1317921532.6433.13.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52693 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab1JFRUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 13:20:00 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 6 Oct 2011 11:19:55 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p96HIsXk078504
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 11:19:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p96HIrAK024325
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 11:18:53 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a linux 3.1.0-rc9 system using the latest iproute2, i tried
creating a bridge and deleting it with an attached interface. 

Here is the sequence of steps i tried
ip link add br0 type bridge
ip link set dev eth1 master br0
ip link set br0 up
ip link del br0

The last command hangs with the following kernel messages
kernel:unregister_netdevice: waiting for br0 to become free. Usage count = 1

I see the same behavior even if the bridge is brought down
before trying to delete the bridge.

brctl delbr fails with an error message if the bridge is up.
But it succeeds if the bridge is brought down before doing a delbr
even if it has interfaces attached.

Thanks
Sridhar
