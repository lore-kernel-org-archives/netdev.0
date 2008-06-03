From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/12]: Proper compat WEXT support.
Date: Tue, 03 Jun 2008 13:27:55 -0700 (PDT)
Message-ID: <20080603.132755.262737024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, mokuno@sm.sony.co.jp,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753049AbYFCUgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 16:36:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a refresh of my previous WEXT compat patch set.

I've actually tested these exact patches on sparc64 with a RNDIS based
USB wireless device from Linksys.  I was able to perform iwconfig
commands, check iwlist, bring up the interface and use it properly.
All with 32-bit tools.  I've also done an allmodconfig sanity
build check on sparc64.

The one thing I was not able to test yet is wpa_supplicant use, and
that likely doesn't work properly yet, but we can fix that on top and
these patches do not break native non-compat binaries.  They do make a
lot of compat stuff work which wasn't the case before.  So applying
this stuff makes sense, and we can get wpa_supplicant working if it
isn't working using follow-on patches.

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

Thanks!
