From: Mike Ditto <mditto@consentry.com>
Subject: Re: [PATCH v2] powerpc/fs_enet: Add missing irq free in error path.
Date: Mon, 27 Oct 2008 14:46:28 -0700
Message-ID: <490636B4.2010202@consentry.com>
References: <49027044.90509@consentry.com>
	<1D4ED273-13FB-4D2F-82B1-89D2F6F0B9A1@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1D4ED273-13FB-4D2F-82B1-89D2F6F0B9A1@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

If something goes wrong attaching to phy driver, we weren't freeing
the IRQ.

Signed-off-by: Mike Ditto <mditto@consentry.com>
---
Reposting to CC netdev list.  (Thanks, Kumar)

diff -r -upN 2.6.28-rc1/drivers/net/fs_enet/fs_enet-main.c NEW/drivers/net/fs_enet/fs_enet-main.c
--- 2.6.28-rc1/drivers/net/fs_enet/fs_enet-main.c	2008-10-24 17:54:31.000000000 -0700
+++ NEW/drivers/net/fs_enet/fs_enet-main.c	2008-10-24 17:57:03.000000000 -0700
@@ -795,6 +795,7 @@ static int fs_enet_open(struct net_devic

 	err = fs_init_phy(dev);
 	if (err) {
+		free_irq(fep->interrupt, dev);
 		if (fep->fpi->use_napi)
 			napi_disable(&fep->napi);
 		return err;
