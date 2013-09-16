From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] net loopback: Set loopback_dev to NULL when freed
Date: Mon, 16 Sep 2013 16:52:41 -0700
Message-ID: <87k3iggw8m.fsf_-_@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51973 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab3IPXwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 19:52:53 -0400
In-Reply-To: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	(Francesco Ruggeri's message of "Mon, 16 Sep 2013 13:30:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It has recently turned up that we have a number of long standing bugs
in the network stack cleanup code with use of the loopback device
after it has been freed that have not turned up because in most cases
the storage allocated to the loopback device is not reused, when those
accesses happen.

Set looback_dev to NULL to trigger oopses instead of silent data corrupt
when we hit this class of bug.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/loopback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index fcbf680..a17d85a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -146,6 +146,7 @@ static int loopback_dev_init(struct net_device *dev)
 
 static void loopback_dev_free(struct net_device *dev)
 {
+	dev_net(dev)->loopback_dev = NULL;
 	free_percpu(dev->lstats);
 	free_netdev(dev);
 }
-- 
1.7.5.4
