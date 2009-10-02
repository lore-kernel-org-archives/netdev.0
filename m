From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri,  2 Oct 2009 14:40:03 +0200
Message-ID: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
Cc: dm-devel@redhat.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev-devel@lists.sourceforge.net,
	Philipp Reisner <philipp.reisner@linbit.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail09.linbit.com ([212.69.161.110]:53766 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756768AbZJBMkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 08:40:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Affected: All code that uses connector, in kernel and out of mainline

The connector, as it is today, does not allow the in kernel receiving
parts to do any checks on privileges of a message's sender.

I know, there are not many out there that like connector, but as
long as it is in the kernel, we have to fix the security issues it has!

Please either drop connector, or someone who feels a bit responsible
and has our beloved dictator's blessing, PLEASE PLEASE PLEASE take 
this into your tree, and send the pull request to Linus.

Patches 1 to 4 are already Acked-by Evgeny, the connector's maintainer.
Patches 5 to 7 are the obvious fixes to the connector user's code.

For convenience these patches are also available as git tree:
git://git.drbd.org/linux-2.6-drbd.git connector-fix

-Phil

Philipp Reisner (8):
  connector: Keep the skb in cn_callback_data
  connector: Provide the sender's credentials to the callback
  connector/dm: Fixed a compilation warning
  connector: Removed the destruct_data callback since it is always kfree_skb()
  dm/connector: Only process connector packages from privileged processes
  dst/connector: Disallow unpliviged users to configure dst
  pohmelfs/connector: Disallow unpliviged users to configure pohmelfs
  uvesafb/connector: Disallow unpliviged users to send netlink packets

 Documentation/connector/cn_test.c      |    2 +-
 Documentation/connector/connector.txt  |    8 ++++----
 drivers/connector/cn_queue.c           |   12 +++++++-----
 drivers/connector/connector.c          |   22 ++++++++--------------
 drivers/md/dm-log-userspace-transfer.c |    6 ++++--
 drivers/staging/dst/dcore.c            |    7 ++++++-
 drivers/staging/pohmelfs/config.c      |    5 ++++-
 drivers/video/uvesafb.c                |    5 ++++-
 drivers/w1/w1_netlink.c                |    2 +-
 include/linux/connector.h              |   11 ++++-------
 10 files changed, 43 insertions(+), 37 deletions(-)

