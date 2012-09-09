From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: ndo_get_stats and rtnl_netlink
Date: Sun, 9 Sep 2012 18:23:16 +0300
Message-ID: <504CB464.6010207@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:38833 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752199Ab2IIP35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2012 11:29:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just realized that dev_get_stats which calls into a netdevice 
ndo_get_stats64/ndo_get_stats can be
called with or without RTNL lock protection. If called from 
rtnl_fill_ifinfo e.g as of invocation of
"ip link show <interface>, there IS locking, however if called from 
dev_seq_printf_stats e.g as of
invocation of reading the /sys/class/net/<interface>/statistics/ 
entries, etc more cases -- no locking.

This turned to be problematic when implementing the ethtool 
"set_channels" directive which
changes the number of **rings**, since we stepped on a bug where the 
rings data structure was
changed by the ethtool flow in the same time a statistics call was done 
into the driver, etc.

What would be the way to continue here, per driver lock sounds non 
generic...

Regards
Shlomo Pongratz
