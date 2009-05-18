From: David Miller <davem@davemloft.net>
Subject: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when enabling
 ip_forward
Date: Mon, 18 May 2009 15:35:31 -0700 (PDT)
Message-ID: <20090518.153531.126023429.davem@davemloft.net>
References: <20090519010147.772f0bff@vingilot.sergknet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sergk@sergk.org.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583AbZERWfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:35:33 -0400
In-Reply-To: <20090519010147.772f0bff@vingilot.sergknet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Kononenko <sergk@sergk.org.ua>
Date: Tue, 19 May 2009 01:01:47 +0300

> I have system with two Intel 82575EB 1Gb/s NICs and two Intel 82598EB
> 10Gb/s NICs (motherboard Supermicro X7DWU). I'm using kernel 2.6.29.3
> with compiled in drivers for both types of NICs with LRO enabled:
> CONFIG_INET_LRO=y
> CONFIG_IGB=y
> CONFIG_IGB_LRO=y
> CONFIG_IGB_DCA=y
> CONFIG_IXGBE=y
> CONFIG_IXGBE_DCA=y
> 
> After boot process is completed according to ethtool LRO is disabled on igb
> and enabled on ixgbe. After I'm trying to turn on forwarding by
> sysctl -w net.ipv4.ip_forward=1 I get following in dmesg:

The problem is that the IGB driver in 2.6.29.3 is buggy, it supports
LRO but does not hook up a ->set_flags ethtool_ops function.  That's
why this warning triggers.

It should be pretty easy to fix, since there is a generic
implementation provided in net/core/ethtool.c, and IXGB properly
hooks up this method as well.
