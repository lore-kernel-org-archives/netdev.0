From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 11:08:51 -0700
Message-ID: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755513Ab2DJSIy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:08:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit needs to be reverted. It removed an available sysfs file, a=
nd sysfs
files are part of the ABI. It caused a bug in our current release of Vy=
atta because
the shell script was using the sysfs file to see if VLAN was supported =
on a device.

An API maybe redundant, but you can't just remove it.


commit 974151e6119f20d2af4acb97526c780ae0f18ccb
Author: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Date:   Thu Jul 14 14:45:15 2011 -0700

    net: remove /sys/class/net/*/features
   =20
    The same information and more can be obtained by using ethtool
    with ETHTOOL_GFEATURES.
   =20
    Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
    Signed-off-by: David S. Miller <davem@davemloft.net>
