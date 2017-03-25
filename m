From: kys@exchange.microsoft.com
Subject: [PATCH net-next 1/2] netvsc: Fix a bug in sub-channel handling
Date: Fri, 24 Mar 2017 20:54:36 -0700
Message-ID: <1490414077-12617-1-git-send-email-kys@exchange.microsoft.com>
References: <1490414048-12578-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1490414048-12578-1-git-send-email-kys@exchange.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: K. Y. Srinivasan <kys@microsoft.com>

All netvsc channels are handled via NAPI. Setup the "read mode" correctly
for the netvsc sub-channels.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 91b3bcf..9835825 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1002,6 +1002,11 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	if (!nvchan->mrc.buf)
 		return;
 
+	/* Because the device uses NAPI, all the interrupt batching and
+	 * control is done via Net softirq, not the channel handling
+	 */
+	set_channel_read_mode(new_sc, HV_CALL_ISR);
+
 	ret = vmbus_open(new_sc, nvscdev->ring_size * PAGE_SIZE,
 			 nvscdev->ring_size * PAGE_SIZE, NULL, 0,
 			 netvsc_channel_cb, nvchan);
-- 
1.7.1
