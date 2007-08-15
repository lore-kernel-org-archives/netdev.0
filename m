From: Brandon Philips <bphilips@suse.de>
Subject: [patch 3/4] Implement devm_kcalloc
Date: Wed, 15 Aug 2007 12:00:00 -0700
Message-ID: <20070815190000.GD7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename="kcalloc-devres.patch"
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

devm_kcalloc is a simple wrapper around devm_kzalloc for arrays.  This is
needed because kcalloc is often used in network devices. 

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/base/devres.c  |   16 ++++++++++++++++
 include/linux/device.h |    2 ++
 2 files changed, 18 insertions(+)

Index: linux-2.6/drivers/base/devres.c
===================================================================
--- linux-2.6.orig/drivers/base/devres.c
+++ linux-2.6/drivers/base/devres.c
@@ -630,6 +630,22 @@ void * devm_kzalloc(struct device *dev, 
 EXPORT_SYMBOL_GPL(devm_kzalloc);
 
 /**
+ * devm_kcalloc - resource-managed kcalloc
+ * @dev: Device to allocate memory for
+ * @n: number of elements.
+ * @size: element size.
+ * @flags: the type of memory to allocate.
+ */
+void *devm_kcalloc(struct device *dev, size_t n, size_t size,
+			   gfp_t flags)
+{
+	if (n != 0 && size > ULONG_MAX / n)
+		return NULL;
+	return devm_kzalloc(dev, n * size, flags);
+}
+EXPORT_SYMBOL_GPL(devm_kcalloc);
+
+/**
  * devm_kfree - Resource-managed kfree
  * @dev: Device this memory belongs to
  * @p: Memory to free
Index: linux-2.6/include/linux/device.h
===================================================================
--- linux-2.6.orig/include/linux/device.h
+++ linux-2.6/include/linux/device.h
@@ -402,6 +402,8 @@ extern int devres_release_group(struct d
 
 /* managed kzalloc/kfree for device drivers, no kmalloc, always use kzalloc */
 extern void *devm_kzalloc(struct device *dev, size_t size, gfp_t gfp);
+extern void *devm_kcalloc(struct device *dev, size_t n, size_t size,
+			  gfp_t flags);
 extern void devm_kfree(struct device *dev, void *p);
 
 struct device {

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
