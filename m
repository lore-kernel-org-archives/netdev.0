From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH] connector: Allow permission checking in the receiver callbacks
Date: Tue, 29 Sep 2009 16:48:07 +0200
Message-ID: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	Philipp Reisner <philipp.reisner@linbit.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752765AbZI2OsR@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various users of the connector should actually check if the
sender's capabilities of a netlink/connector packet are
actually sufficient for the operation they trigger. Up to
now the connector framework did not allow the kernel side
receiver to do so.

This patch set does the groundwork.

Philipp Reisner (4):
  connector: Keep the skb in cn_callback_data
  connector: Provide the sender's credentials to the callback
  connector/dm: Fixed a compilation warning
  connector: Removed the destruct_data callback since it is always
    kfree_skb()

 Documentation/connector/cn_test.c      |    2 +-
 Documentation/connector/connector.txt  |    8 ++++----
 drivers/connector/cn_queue.c           |   12 +++++++-----
 drivers/connector/connector.c          |   22 ++++++++--------------
 drivers/md/dm-log-userspace-transfer.c |    3 +--
 drivers/staging/dst/dcore.c            |    2 +-
 drivers/staging/pohmelfs/config.c      |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 drivers/w1/w1_netlink.c                |    2 +-
 include/linux/connector.h              |   11 ++++-------
 10 files changed, 29 insertions(+), 37 deletions(-)
