From: Jonathan Cameron <jic23@jic23.retrosnub.co.uk>
Subject: Re: [PATCH v2 04/15] iio: make function argument and some structures const
Date: Mon, 16 Oct 2017 19:48:03 +0100
Message-ID: <7091CB3C-16A9-429D-B684-8141955611A7@jic23.retrosnub.co.uk>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-5-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8BIT
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1508167134-6243-5-git-send-email-bhumirks@gmail.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 16 October 2017 16:18:43 BST, Bhumika Goyal <bhumirks@gmail.com> wrote:
>Make the argument of the functions iio_sw{d/t}_group_init_type_name
>const
>as they are only passed to the function config_group_init_type_name
>having
>the argument as const.
>
>Make the config_item_type structures const as they are either passed to
>the functions having the argument as const or they are
>stored in the const "ci_type" field of a config_item structure.
>
>Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
Acked-by: Jonathan Cameron <Jonathan.Cameron@Huawei.com>
>---
>* Changes in v2- Combine all the followup patches and the
>constification
>patches into a series.
>
> drivers/iio/dummy/iio_simple_dummy.c   | 2 +-
> drivers/iio/industrialio-configfs.c    | 2 +-
> drivers/iio/industrialio-sw-device.c   | 6 +++---
> drivers/iio/industrialio-sw-trigger.c  | 6 +++---
> drivers/iio/trigger/iio-trig-hrtimer.c | 2 +-
> drivers/iio/trigger/iio-trig-loop.c    | 2 +-
> include/linux/iio/sw_device.h          | 2 +-
> include/linux/iio/sw_trigger.h         | 2 +-
> 8 files changed, 12 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/iio/dummy/iio_simple_dummy.c
>b/drivers/iio/dummy/iio_simple_dummy.c
>index a45d01e..6205247 100644
>--- a/drivers/iio/dummy/iio_simple_dummy.c
>+++ b/drivers/iio/dummy/iio_simple_dummy.c
>@@ -26,7 +26,7 @@
> #include <linux/iio/sw_device.h>
> #include "iio_simple_dummy.h"
> 
>-static struct config_item_type iio_dummy_type = {
>+static const struct config_item_type iio_dummy_type = {
> 	.ct_owner = THIS_MODULE,
> };
> 
>diff --git a/drivers/iio/industrialio-configfs.c
>b/drivers/iio/industrialio-configfs.c
>index 45ce2bc..5a0aae1 100644
>--- a/drivers/iio/industrialio-configfs.c
>+++ b/drivers/iio/industrialio-configfs.c
>@@ -17,7 +17,7 @@
> #include <linux/iio/iio.h>
> #include <linux/iio/configfs.h>
> 
>-static struct config_item_type iio_root_group_type = {
>+static const struct config_item_type iio_root_group_type = {
> 	.ct_owner       = THIS_MODULE,
> };
> 
>diff --git a/drivers/iio/industrialio-sw-device.c
>b/drivers/iio/industrialio-sw-device.c
>index 81b49cf..90df97c 100644
>--- a/drivers/iio/industrialio-sw-device.c
>+++ b/drivers/iio/industrialio-sw-device.c
>@@ -19,9 +19,9 @@
> #include <linux/configfs.h>
> 
> static struct config_group *iio_devices_group;
>-static struct config_item_type iio_device_type_group_type;
>+static const struct config_item_type iio_device_type_group_type;
> 
>-static struct config_item_type iio_devices_group_type = {
>+static const struct config_item_type iio_devices_group_type = {
> 	.ct_owner = THIS_MODULE,
> };
> 
>@@ -156,7 +156,7 @@ static void device_drop_group(struct config_group
>*group,
> 	.drop_item	= &device_drop_group,
> };
> 
>-static struct config_item_type iio_device_type_group_type = {
>+static const struct config_item_type iio_device_type_group_type = {
> 	.ct_group_ops = &device_ops,
> 	.ct_owner       = THIS_MODULE,
> };
>diff --git a/drivers/iio/industrialio-sw-trigger.c
>b/drivers/iio/industrialio-sw-trigger.c
>index 8d24fb1..bc6b7fb 100644
>--- a/drivers/iio/industrialio-sw-trigger.c
>+++ b/drivers/iio/industrialio-sw-trigger.c
>@@ -19,9 +19,9 @@
> #include <linux/configfs.h>
> 
> static struct config_group *iio_triggers_group;
>-static struct config_item_type iio_trigger_type_group_type;
>+static const struct config_item_type iio_trigger_type_group_type;
> 
>-static struct config_item_type iio_triggers_group_type = {
>+static const struct config_item_type iio_triggers_group_type = {
> 	.ct_owner = THIS_MODULE,
> };
> 
>@@ -156,7 +156,7 @@ static void trigger_drop_group(struct config_group
>*group,
> 	.drop_item	= &trigger_drop_group,
> };
> 
>-static struct config_item_type iio_trigger_type_group_type = {
>+static const struct config_item_type iio_trigger_type_group_type = {
> 	.ct_group_ops = &trigger_ops,
> 	.ct_owner       = THIS_MODULE,
> };
>diff --git a/drivers/iio/trigger/iio-trig-hrtimer.c
>b/drivers/iio/trigger/iio-trig-hrtimer.c
>index 3ee9216..7accd01 100644
>--- a/drivers/iio/trigger/iio-trig-hrtimer.c
>+++ b/drivers/iio/trigger/iio-trig-hrtimer.c
>@@ -30,7 +30,7 @@ struct iio_hrtimer_info {
> 	ktime_t period;
> };
> 
>-static struct config_item_type iio_hrtimer_type = {
>+static const struct config_item_type iio_hrtimer_type = {
> 	.ct_owner = THIS_MODULE,
> };
> 
>diff --git a/drivers/iio/trigger/iio-trig-loop.c
>b/drivers/iio/trigger/iio-trig-loop.c
>index b4b02db..94a90e0 100644
>--- a/drivers/iio/trigger/iio-trig-loop.c
>+++ b/drivers/iio/trigger/iio-trig-loop.c
>@@ -36,7 +36,7 @@ struct iio_loop_info {
> 	struct task_struct *task;
> };
> 
>-static struct config_item_type iio_loop_type = {
>+static const struct config_item_type iio_loop_type = {
> 	.ct_owner = THIS_MODULE,
> };
> 
>diff --git a/include/linux/iio/sw_device.h
>b/include/linux/iio/sw_device.h
>index fa79319..8642b91 100644
>--- a/include/linux/iio/sw_device.h
>+++ b/include/linux/iio/sw_device.h
>@@ -60,7 +60,7 @@ struct iio_sw_device *to_iio_sw_device(struct
>config_item *item)
> static inline
> void iio_swd_group_init_type_name(struct iio_sw_device *d,
> 				  const char *name,
>-				  struct config_item_type *type)
>+				  const struct config_item_type *type)
> {
> #if IS_ENABLED(CONFIG_CONFIGFS_FS)
> 	config_group_init_type_name(&d->group, name, type);
>diff --git a/include/linux/iio/sw_trigger.h
>b/include/linux/iio/sw_trigger.h
>index c97eab6..0c43738 100644
>--- a/include/linux/iio/sw_trigger.h
>+++ b/include/linux/iio/sw_trigger.h
>@@ -60,7 +60,7 @@ struct iio_sw_trigger *to_iio_sw_trigger(struct
>config_item *item)
> static inline
> void iio_swt_group_init_type_name(struct iio_sw_trigger *t,
> 				  const char *name,
>-				  struct config_item_type *type)
>+				  const struct config_item_type *type)
> {
> #if IS_ENABLED(CONFIG_CONFIGFS_FS)
> 	config_group_init_type_name(&t->group, name, type);

-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
