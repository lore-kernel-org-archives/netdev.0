From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Fri, 24 May 2013 10:49:31 -0500
Message-ID: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:49056 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab3EXPtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 11:49:47 -0400
Received: by mail-oa0-f52.google.com with SMTP id h1so6413195oag.11
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 08:49:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just started testing the 3.10 kernel, previously we were on 3.4 so
there is a fairly large jump.  I've additionally applied the following
four patches to the 3.10.0-rc2 kernel that I'm testing:

https://patchwork.kernel.org/patch/2484651/
https://patchwork.kernel.org/patch/2484671/
https://patchwork.kernel.org/patch/2484681/
https://patchwork.kernel.org/patch/2484641/

I don't know if those patches are related to my issues or not but I
plan on trying to reproduce without them soon.

The issue I'm seeing is that our applications listen on a number of
multicast addresses.  In this case I'm listening to about 350
different addresses per machine, across many different processes, with
usually one socket per address.  The problem is that some of the
sockets are not receiving any data and some are, even though they all
should be.  If I put the device in promiscuous mode then I start
receiving data on all of my sockets.  Running netstat -g shows all of
my memberships so it appears to me that the kernel and the switch
think I've joined the groups, but the card may be filtering the data.
This is with:

05:00.0 Network controller: Mellanox Technologies MT27500 Family [ConnectX-3]

# ethtool -i eth4
driver: mlx4_en
version: 2.0 (Dec 2011)
firmware-version: 2.11.500
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: no

The other strange part is that I've got multiple machines all running
the same kernel and not all of them are experiencing the issue.  At
one point they were all working fine, but the issue appeared after I
rebooted one of the machines and multiple reboots later it is still in
this bad state.  Rebooting that machine back to 3.4 causes it to work
as expected but no luck under 3.10.  I've now got two machines in this
bad state and they both started immediately after a reboot.

Does anyone have any ideas?

Thanks,
Shawn
