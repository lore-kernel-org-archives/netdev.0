From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next 06/11] ACPI: bus: move acpi_match_device_ids() to linux/acpi.h
Date: Fri, 13 May 2016 16:19:12 +0800
Message-ID: <1463127557-90824-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hanjun Guo <hanjun.guo@linaro.org>

acpi_match_device_ids() will be used for drivers to match
different hardware versions, it will be compiled in non-ACPI
case, but acpi_match_device_ids() in acpi_bus.h and it can
only be used in ACPI case, so move it to linux/acpi.h and
introduce a stub function for it.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 include/acpi/acpi_bus.h |  2 --
 include/linux/acpi.h    | 11 +++++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 3a93250..12cf2cb 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -513,8 +513,6 @@ void acpi_bus_unregister_driver(struct acpi_driver *driver);
 int acpi_bus_scan(acpi_handle handle);
 void acpi_bus_trim(struct acpi_device *start);
 acpi_status acpi_bus_get_ejd(acpi_handle handle, acpi_handle * ejd);
-int acpi_match_device_ids(struct acpi_device *device,
-			  const struct acpi_device_id *ids);
 int acpi_create_dir(struct acpi_device *);
 void acpi_remove_dir(struct acpi_device *);
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 06ed7e5..e578bce 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -933,7 +933,18 @@ int __acpi_probe_device_table(struct acpi_probe_entry *start, int nr);
 					  (&ACPI_PROBE_TABLE_END(t) -	\
 					   &ACPI_PROBE_TABLE(t)));	\
 	})
+
+int acpi_match_device_ids(struct acpi_device *device,
+			  const struct acpi_device_id *ids);
+
 #else
+
+static inline int acpi_match_device_ids(struct acpi_device *device,
+					const struct acpi_device_id *ids)
+{
+	return -ENOENT;
+}
+
 static inline int acpi_dev_get_property(struct acpi_device *adev,
 					const char *name, acpi_object_type type,
 					const union acpi_object **obj)
-- 
1.9.1
