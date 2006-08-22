From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: b44 (Broadcom BCM4401 100Base-T) + NETCONSOLE + link up == lockup
Date: Tue, 22 Aug 2006 11:20:24 +0200
Message-ID: <20060822092024.GA1089@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:7318 "EHLO
	janus.localdomain") by vger.kernel.org with ESMTP id S1751376AbWHVJUZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 05:20:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Noticed this on 2.6.17.8 and it is easily reproduced. When disconnecting
and connecting the network cable from a BCM4401 100Base-T NIC the usual
"link is down" and "link is up" messages show up unless netconsole
logging is enabled upon boot using (e.g.):

	netconsole=@172.17.1.65/,514@172.17.1.64/00:12:3f:85:17:52

In that case the "link is up" message no longer makes it to the virtual
console/remote machine and the machine seems to lock up. alt-sysrq-p
doesn't show anything on the VC (caps- and numlock are dead too) but
alt-sysrq-b works provided it is not preceded by too many unprinted kernel
messages (so it seems). The link does go up according to the link state
LED and there is some activity (incoming packets only I suppose).

unplugging and plugging again doesn't help.

During boot the kernel says:

	kernel: netconsole: device eth0 not up yet, forcing it
	kernel: b44: eth0: Link is up at 100 Mbps, full duplex.
	kernel: b44: eth0: Flow control is off for TX and off for RX.
	kernel: netconsole: network logging started

-- 
Frank
