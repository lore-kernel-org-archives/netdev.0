From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Tue, 16 Dec 2008 14:06:51 +0000
Message-ID: <20081216140651.GA6537@ff.dom.local>
References: <20081214.224800.125614949.davem@davemloft.net> <20081215133521.GA6697@ff.dom.local> <20081216.012247.267028680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Huemer <alexander.huemer@sbg.ac.at>,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081216.012247.267028680.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 16, 2008 at 01:22:47AM -0800, David Miller wrote:
...
> Jarek this looks good and it looks to be tested as well.
> 
> Could you formally submit this?

------------------->

drivers/net: starfire: Fix napi ->poll() weight handling

starfire napi ->poll() handler can return work == weight after calling
netif_rx_complete() (if there is no more work). It is illegal and this
patch fixes it.

Reported-by: Alexander Huemer <alexander.huemer@sbg.ac.at>
Tested-by: Alexander Huemer <alexander.huemer@sbg.ac.at>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 drivers/net/starfire.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 0358809..f86d6bb 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1503,6 +1503,11 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		desc->status = 0;
 		np->rx_done = (np->rx_done + 1) % DONE_Q_SIZE;
 	}
+
+	if (*quota == 0) {	/* out of rx quota */
+		retcode = 1;
+		goto out;
+	}
 	writew(np->rx_done, np->base + CompletionQConsumerIdx);
 
  out:
