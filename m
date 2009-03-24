From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Fix build breakage caused by a merge
Date: Tue, 24 Mar 2009 18:37:34 +0300
Message-ID: <20090324153734.GA8276@oksana.dev.rtsoft.ru>
References: <382F4B5D-93C4-41BB-A00A-8A6C240CD170@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LinuxPPC Mailing List <linuxppc-dev@ozlabs.org>,
	Andy Fleming <afleming@freescale.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <382F4B5D-93C4-41BB-A00A-8A6C240CD170@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch fixes following build error:

  CC      ucc_geth.o
ucc_geth.c: In function 'ucc_geth_probe':
ucc_geth.c:3644: error: implicit declaration of function 'uec_mdio_bus_name'
make[2]: *** [ucc_geth.o] Error 1

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Tue, Mar 24, 2009 at 08:15:13AM -0500, Kumar Gala wrote:
> Anton, Andy
>
> Can you take a look at the recent net-next tree and make sure that the  
> merge between the fsl_pq_mdio.c support and the patch that went into  
> 2.6.29 to fix fixed-link support in ucc_geth.c is correct and still  
> works.
>
> See commits:
> 	Merge branch master... (8be7cdccacfbfc707e7370cad9bb168defed636f)
> 	ucc_geth: Fix merge error. (039a6f6a39d2aa30ee53afdb213ea6dd4482928b)

Thanks for heads up, there is indeed a small issue.

 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 5f866e2..0b67512 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3641,7 +3641,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		if (err)
 			return -1;
 
-		uec_mdio_bus_name(bus_name, mdio);
+		fsl_pq_mdio_bus_name(bus_name, mdio);
 		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
 			"%s:%02x", bus_name, *prop);
 	}
-- 
1.5.6.5
