From: nhorman@tuxdriver.com
Subject: [PATCH] bonding: minor cleanups to bond + netpoll
Date: Tue, 19 Oct 2010 13:04:24 -0400
Message-ID: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59540 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab0JSRE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 13:04:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing that was onging when the the reset patchset to enable netpoll over
bonding revealed some minor corner cases that are worth correcting.  In summary:

1) Remove netpoll tx blocking from bond_release_all.  Its not needed and causes
some uglyness when removing the bonding module, in the form of a backtrace that
gets logged.  blocking isn't needed in this path anyway as the netconsole is
already unregistered from us at this point

2) Remove my changes to napi_poll.  Closer inspection of the bonding
poll_controller show that we wind up recursively calling the napi poll routines
for the slaves through sucsessive calls to netpoll_poll_dev.  My origional
change is harmless, but its not really needed, so lets make the code simpler.

Further details available in the individual commit messages

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

