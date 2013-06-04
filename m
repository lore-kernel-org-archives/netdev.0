From: John Clark <inindev@gmail.com>
Subject: Problems with Freescale FEC PHY driver
Date: Mon, 3 Jun 2013 23:07:46 -0400
Message-ID: <CALtTj7xGeXzUw0OSjSe94Be7Ve8=Kr8hfx4XC_=QkCpXNJUT5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:59558 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab3FDDHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 23:07:47 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so8682635obb.32
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 20:07:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having problems with the Freescale FEC PHY driver on a Boundary
Devices Nitrogen6x iMX6 quad-core board.  I noticed the problem with
the 3.9 kernels and it continues with the 3.10 series.  I just tested
the 3.10.0-rc4 kernel on wheezy and I am still seeing similar problems
(although it does appear to have improved since the 3.9 kernel).

[    2.412887] fec 2188000.ethernet eth0: registered PHC device 0
[    8.672688] fec 2188000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_a)
[    8.684003] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   13.130344] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready


The problem in 3.9:
Starting a compile or other processor intensive activity will cause a
series of link up / down messages to be logged:

[ 2654.484410] libphy: 2188000.ethernet:06 - Link is Up - 1000/Full
[ 2656.484371] libphy: 2188000.ethernet:06 - Link is Down
[ 2657.484425] libphy: 2188000.ethernet:06 - Link is Up - 1000/Full
[ 2669.494347] libphy: 2188000.ethernet:06 - Link is Down
[ 2671.494509] libphy: 2188000.ethernet:06 - Link is Up - 1000/Full
[ 2679.494387] libphy: 2188000.ethernet:06 - Link is Down
[ 2682.494398] libphy: 2188000.ethernet:06 - Link is Up - 1000/Full

The system starts stalling and lagging badly with unpredictable and
long lags between keystrokes for example.


In 3.10.0-rc4, I still am able to get the errors in the log by
starting a compile, but the stuttering and lagging seems to be gone
(just ran a few quick tests).

I saw this link which looks a lot like what I am seeing, but it may
not have been entirely fixed for 3.10.0-rc4:

http://permalink.gmane.org/gmane.linux.network/267535


John Clark
