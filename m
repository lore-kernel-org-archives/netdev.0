From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] netdevice ops
Date: Thu, 17 May 2007 21:07:37 -0700
Message-ID: <20070517210737.17d88401@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.189.120.12] ([207.189.120.12]:38785 "EHLO smtp.osdl.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757599AbXEREJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 00:09:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I want to take all the function pointers of 'struct net_device' and
move them to 'struct net_device_ops'. This will save memory for the
case of lots of devices, as well as reduce initialization code.

Rough plan:
1. Introduce inline accessors so protocols don't dereference dev->XXX directly.
2. Fix protocols to use #1
3. Add ops field to net_device, and netdevice_register will fill in old values
   in 'struct net_device'.
4...1300 Fix all network devices to use ops field
1301 Change accessors to use ops, get rid of old 'struct net_device' function pointers.

It isn't rocket science just another code exercise. I'll patch bomb it into something
like 2.6.23-mm first.

This should really help the people who like to do 1000's of vlans etc.
