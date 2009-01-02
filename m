From: Stephen Hemminger <shemminger@vyatta.com>
Subject: ixgbe select_queue broken in 2.6.28
Date: Thu, 1 Jan 2009 22:54:56 -0800
Message-ID: <20090101225456.68f4fe9d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33665 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbZABGzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 01:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ixgbe driver in 2.6.28 modifies select_queue. This is bad
in a couple of ways:
  1) select_queue is now in net_device_ops so the driver won't build
     unless CONFIG_COMPAT_NET_DEV_OPS is defined
  2) it is changing data that is shared and supposed to be immutable.

Looks like a some of the DCB stuff forgot to look at net_device_ops
