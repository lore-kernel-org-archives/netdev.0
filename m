From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/12]: Proper compat WEXT support.
Date: Tue, 17 Jun 2008 00:52:55 -0700 (PDT)
Message-ID: <20080617.005255.135158143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno@sm.sony.co.jp, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752440AbYFQHwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:52:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is what I consider the final submission of this patch set, it's
ready to go.  I also made sure all the patches are checkpatch clean.

I've actually tested these exact patches on sparc64 with a RNDIS based
USB wireless device from Linksys.  I was able to perform iwconfig
commands, check iwlist, bring up the interface and use it properly.
All with 32-bit tools.  I've also done an allmodconfig sanity build
check on sparc64.  Masakazu-san has tested these patches extensively
on PS3 systems, using the gelic and zd1211 drivers.  In particular he
tested wpa_supplicant use.

The patch set starts by cleaning up the code so that we can avoid
having multiple copies of the WEXT main dispatch routines, one for
compat and one for the non-compat case.

Next, basic compat level handling of the WEXT ioctl is added, and the
equivalent code in the compat_ioctl.c file is removed.

Finally, compat IWE stream munging is added for the wireless layer.
When we get a compat WEXT ioctl request, we set a bit in the request
info blob, and the stream building helpers tip off this to format the
stream entries properly.

These patches are against net-next-2.6 and are also available as
a GIT tree at:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/wireless-2.6.git

John, please pull or apply as you deem appropriate.
