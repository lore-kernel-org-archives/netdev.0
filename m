From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [PATCH net-next v2] hyper-v: allow access to vmbus from
 userspace driver
Date: Wed, 4 Feb 2015 15:20:29 -0800
Message-ID: <20150204152029.65f02d64@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dev-VfR2kkLFssw@public.gmane.org, devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: KY Srinivasan <kys-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Return-path: <dev-bounces-VfR2kkLFssw@public.gmane.org>
List-Unsubscribe: <http://dpdk.org/ml/options/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://dpdk.org/ml/archives/dev/>
List-Post: <mailto:dev-VfR2kkLFssw@public.gmane.org>
List-Help: <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=help>
List-Subscribe: <http://dpdk.org/ml/listinfo/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-VfR2kkLFssw@public.gmane.org
Sender: "dev" <dev-bounces-VfR2kkLFssw@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is enables the hyper-v driver for DPDK <dev-VfR2kkLFssw@public.gmane.org>.
The hv_uio driver needs to access the shared vmbus monitor
pages.

I would also like to put hv_uio in upstream kernel like other
uio drivers, but need to get API accepted with DPDK first.

Signed-off-by: Stas Egorov <segorov-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>
Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>

---
v2 - simplify and rename to vmbus_get_monitor_pages

 drivers/hv/connection.c |   20 +++++++++++++++++---
 include/linux/hyperv.h  |    3 +++
 2 files changed, 20 insertions(+), 3 deletions(-)

--- a/drivers/hv/connection.c	2015-02-03 10:58:51.751752450 -0800
+++ b/drivers/hv/connection.c	2015-02-04 14:59:51.636194383 -0800
@@ -64,6 +64,15 @@ static __u32 vmbus_get_next_version(__u3
 	}
 }
 
+void vmbus_get_monitor_pages(unsigned long *int_page,
+			     unsigned long monitor_pages[2])
+{
+	*int_page = (unsigned long)vmbus_connection.int_page;
+	monitor_pages[0] = (unsigned long)vmbus_connection.monitor_pages[0];
+	monitor_pages[1] = (unsigned long)vmbus_connection.monitor_pages[1];
+}
+EXPORT_SYMBOL_GPL(vmbus_get_monitor_pages);
+
 static int vmbus_negotiate_version(struct vmbus_channel_msginfo *msginfo,
 					__u32 version)
 {
@@ -347,10 +356,7 @@ static void process_chn_event(u32 relid)
 			else
 				bytes_to_read = 0;
 		} while (read_state && (bytes_to_read != 0));
-	} else {
-		pr_err("no channel callback for relid - %u\n", relid);
 	}
-
 }
 
 /*
--- a/include/linux/hyperv.h	2015-02-03 10:58:51.751752450 -0800
+++ b/include/linux/hyperv.h	2015-02-04 15:00:26.388355012 -0800
@@ -868,6 +868,9 @@ extern int vmbus_recvpacket_raw(struct v
 
 extern void vmbus_ontimer(unsigned long data);
 
+extern void vmbus_get_monitor_pages(unsigned long *int_page,
+				    unsigned long monitor_pages[2]);
+
 /* Base driver object */
 struct hv_driver {
 	const char *name;
