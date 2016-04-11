From: Stefan Agner <stefan@agner.ch>
Subject: Configuring ethernet link fails with No such device
Date: Mon, 11 Apr 2016 15:46:08 -0700
Message-ID: <67b662523c63277fa95a59472cbf018f@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	u.kleine-koenig@pengutronix.de, bryan.wu@canonical.com,
	bob.ham@collabora.com
To: systemd-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:35914 "EHLO
	mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbcDKWt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I traced an issue in which we tried configuring duplex mode and speed in
a systemd-udevd .link file failed with the following error:
"Could not set speed or duplex of eth0 to 0 Mbps (half): No such device"

The FEC driver (fec_main.c) does not initialize phy_dev until the device
has been opened, and therefor the callback fec_enet_(get|set)_settings
returns -19.

What is the expectation/definition when link configuration should be
possible? Only after the network device got opened or before?

Or in other words: Is this a Kernel or systemd issue? At what point is
link configuration "guaranteed" to work?

It seems that the FEC driver used to probe the PHY earlier, it has been
moved to the open callback with commit 418bd0d4df ("netdev/fec: fix
ifconfig eth0 down hang issue")...

There has been a similar report on the systemd-devel mailing list a
while ago, probably the same underlying issue:
https://www.mail-archive.com/systemd-devel@lists.freedesktop.org/msg33186.html
