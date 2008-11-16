From: Jesper Krogh <jesper@krogh.cc>
Subject: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Sun, 16 Nov 2008 10:41:41 +0100
Message-ID: <491FEAD5.4090205@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:39639 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbYKPJlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 04:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I have something that looks like a regression in bonding between 
2.6.26.8 and 2.6.27.6 (I'll try the mid-steps later).

Setup: LACP bond(mode=4,mmimon=100) with 3 NIC's and dhcp on top (static 
ip didn't work either).

Problem: The bond doesn't get up after bootup. Subsequence ifdown/ifup 
brings it up.

I suspect it it timing related. The interface being configured before 
it's ready:
root@quad01:~# dmesg | egrep '(dhc|bond)'
[   12.421963] bonding: MII link monitoring set to 100 ms
[   12.483370] bonding: bond0: enslaving eth0 as a backup interface with 
an up link.
[   12.523372] bonding: bond0: enslaving eth1 as a backup interface with 
an up link.
[   12.611731] bonding: bond0: enslaving eth2 as a backup interface with 
a down link.
[   12.780816] warning: `dhclient3' uses 32-bit capabilities (legacy 
support in use)
[   15.720491] bonding: bond0: link status definitely up for interface eth2.
[   87.800324] bond0: no IPv6 routers present


The setup is a 3 NIC bond on a Sun X2200 dual-cpu Quad-core server.
I have similar bond on a X4600 where they works with 2.6.27.6 so I 
suspect that the difference is that the X4600 has all NIC's from the
same vendor where as the X2200 has 2 Broadcom NIC's and 2 NVidia nics.

root@quad01:~# lspci | grep -i ethernet
00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
06:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 
Gigabit Ethernet (rev a3)
06:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 
Gigabit Ethernet (rev a3)




-- 
Jesper
