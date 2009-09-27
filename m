From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] drivers/staging/hv/: use %pU to print UUID/GUIDs
Date: Sat, 26 Sep 2009 22:57:21 -0700
Message-ID: <18389cc75bfc33f6703751a7902bae3cb90fbf46.1254030722.git.joe@perches.com>
References: <cover.1254030722.git.joe@perches.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1231 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbZI0F5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Sep 2009 01:57:18 -0400
In-Reply-To: <cover.1254030722.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converted individual GUID/UUID printing functions
to use the new %pU[Xr] in lib/vsprintf.c

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/staging/hv/ChannelMgmt.c |   22 +-------
 drivers/staging/hv/vmbus_drv.c   |  116 ++++----------------------------------
 2 files changed, 14 insertions(+), 124 deletions(-)

diff --git a/drivers/staging/hv/ChannelMgmt.c b/drivers/staging/hv/ChannelMgmt.c
index 3db62ca..8b0fb81 100644
--- a/drivers/staging/hv/ChannelMgmt.c
+++ b/drivers/staging/hv/ChannelMgmt.c
@@ -263,28 +263,10 @@ static void VmbusChannelOnOffer(struct vmbus_channel_message_header *hdr)
 
 	DPRINT_INFO(VMBUS, "Channel offer notification - "
 		    "child relid %d monitor id %d allocated %d, "
-		    "type {%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-		    "%02x%02x%02x%02x%02x%02x%02x%02x} "
-		    "instance {%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-		    "%02x%02x%02x%02x%02x%02x%02x%02x}",
+		    "type {%pUr} instance {%pUr}",
 		    offer->ChildRelId, offer->MonitorId,
 		    offer->MonitorAllocated,
-		    guidType->data[3], guidType->data[2],
-		    guidType->data[1], guidType->data[0],
-		    guidType->data[5], guidType->data[4],
-		    guidType->data[7], guidType->data[6],
-		    guidType->data[8], guidType->data[9],
-		    guidType->data[10], guidType->data[11],
-		    guidType->data[12], guidType->data[13],
-		    guidType->data[14], guidType->data[15],
-		    guidInstance->data[3], guidInstance->data[2],
-		    guidInstance->data[1], guidInstance->data[0],
-		    guidInstance->data[5], guidInstance->data[4],
-		    guidInstance->data[7], guidInstance->data[6],
-		    guidInstance->data[8], guidInstance->data[9],
-		    guidInstance->data[10], guidInstance->data[11],
-		    guidInstance->data[12], guidInstance->data[13],
-		    guidInstance->data[14], guidInstance->data[15]);
+		    guidType->data, guidInstance->data);
 
 	/* Allocate the channel object and save this offer. */
 	newChannel = AllocVmbusChannel();
diff --git a/drivers/staging/hv/vmbus_drv.c b/drivers/staging/hv/vmbus_drv.c
index 582318f..73119a9 100644
--- a/drivers/staging/hv/vmbus_drv.c
+++ b/drivers/staging/hv/vmbus_drv.c
@@ -143,43 +143,10 @@ static ssize_t vmbus_show_device_attr(struct device *dev,
 	vmbus_child_device_get_info(&device_ctx->device_obj, &device_info);
 
 	if (!strcmp(dev_attr->attr.name, "class_id")) {
-		return sprintf(buf, "{%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			       "%02x%02x%02x%02x%02x%02x%02x%02x}\n",
-			       device_info.ChannelType.data[3],
-			       device_info.ChannelType.data[2],
-			       device_info.ChannelType.data[1],
-			       device_info.ChannelType.data[0],
-			       device_info.ChannelType.data[5],
-			       device_info.ChannelType.data[4],
-			       device_info.ChannelType.data[7],
-			       device_info.ChannelType.data[6],
-			       device_info.ChannelType.data[8],
-			       device_info.ChannelType.data[9],
-			       device_info.ChannelType.data[10],
-			       device_info.ChannelType.data[11],
-			       device_info.ChannelType.data[12],
-			       device_info.ChannelType.data[13],
-			       device_info.ChannelType.data[14],
-			       device_info.ChannelType.data[15]);
+		return sprintf(buf, "{%pUr}\n", device_info.ChannelType.data);
 	} else if (!strcmp(dev_attr->attr.name, "device_id")) {
-		return sprintf(buf, "{%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			       "%02x%02x%02x%02x%02x%02x%02x%02x}\n",
-			       device_info.ChannelInstance.data[3],
-			       device_info.ChannelInstance.data[2],
-			       device_info.ChannelInstance.data[1],
-			       device_info.ChannelInstance.data[0],
-			       device_info.ChannelInstance.data[5],
-			       device_info.ChannelInstance.data[4],
-			       device_info.ChannelInstance.data[7],
-			       device_info.ChannelInstance.data[6],
-			       device_info.ChannelInstance.data[8],
-			       device_info.ChannelInstance.data[9],
-			       device_info.ChannelInstance.data[10],
-			       device_info.ChannelInstance.data[11],
-			       device_info.ChannelInstance.data[12],
-			       device_info.ChannelInstance.data[13],
-			       device_info.ChannelInstance.data[14],
-			       device_info.ChannelInstance.data[15]);
+		return sprintf(buf, "{%pUr}\n",
+			       device_info.ChannelInstance.data);
 	} else if (!strcmp(dev_attr->attr.name, "state")) {
 		return sprintf(buf, "%d\n", device_info.ChannelState);
 	} else if (!strcmp(dev_attr->attr.name, "id")) {
@@ -487,23 +454,9 @@ static struct hv_device *vmbus_child_device_create(struct hv_guid *type,
 	}
 
 	DPRINT_DBG(VMBUS_DRV, "child device (%p) allocated - "
-		"type {%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-		"%02x%02x%02x%02x%02x%02x%02x%02x},"
-		"id {%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-		"%02x%02x%02x%02x%02x%02x%02x%02x}",
+		"type {%pUr}, id {%pUr}",
 		&child_device_ctx->device,
-		type->data[3], type->data[2], type->data[1], type->data[0],
-		type->data[5], type->data[4], type->data[7], type->data[6],
-		type->data[8], type->data[9], type->data[10], type->data[11],
-		type->data[12], type->data[13], type->data[14], type->data[15],
-		instance->data[3], instance->data[2],
-		instance->data[1], instance->data[0],
-		instance->data[5], instance->data[4],
-		instance->data[7], instance->data[6],
-		instance->data[8], instance->data[9],
-		instance->data[10], instance->data[11],
-		instance->data[12], instance->data[13],
-		instance->data[14], instance->data[15]);
+		type->data, instance->data);
 
 	child_device_obj = &child_device_ctx->device_obj;
 	child_device_obj->context = context;
@@ -629,65 +582,20 @@ static int vmbus_uevent(struct device *device, struct kobj_uevent_env *env)
 
 	DPRINT_ENTER(VMBUS_DRV);
 
-	DPRINT_INFO(VMBUS_DRV, "generating uevent - VMBUS_DEVICE_CLASS_GUID={"
-		    "%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-		    "%02x%02x%02x%02x%02x%02x%02x%02x}",
-		    device_ctx->class_id.data[3], device_ctx->class_id.data[2],
-		    device_ctx->class_id.data[1], device_ctx->class_id.data[0],
-		    device_ctx->class_id.data[5], device_ctx->class_id.data[4],
-		    device_ctx->class_id.data[7], device_ctx->class_id.data[6],
-		    device_ctx->class_id.data[8], device_ctx->class_id.data[9],
-		    device_ctx->class_id.data[10],
-		    device_ctx->class_id.data[11],
-		    device_ctx->class_id.data[12],
-		    device_ctx->class_id.data[13],
-		    device_ctx->class_id.data[14],
-		    device_ctx->class_id.data[15]);
+	DPRINT_INFO(VMBUS_DRV,
+		    "generating uevent - VMBUS_DEVICE_CLASS_GUID={%pUr}",
+		    device_ctx->class_id.data);
 
 	env->envp_idx = i;
 	env->buflen = len;
-	ret = add_uevent_var(env, "VMBUS_DEVICE_CLASS_GUID={"
-			     "%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			     "%02x%02x%02x%02x%02x%02x%02x%02x}",
-			     device_ctx->class_id.data[3],
-			     device_ctx->class_id.data[2],
-			     device_ctx->class_id.data[1],
-			     device_ctx->class_id.data[0],
-			     device_ctx->class_id.data[5],
-			     device_ctx->class_id.data[4],
-			     device_ctx->class_id.data[7],
-			     device_ctx->class_id.data[6],
-			     device_ctx->class_id.data[8],
-			     device_ctx->class_id.data[9],
-			     device_ctx->class_id.data[10],
-			     device_ctx->class_id.data[11],
-			     device_ctx->class_id.data[12],
-			     device_ctx->class_id.data[13],
-			     device_ctx->class_id.data[14],
-			     device_ctx->class_id.data[15]);
+	ret = add_uevent_var(env, "VMBUS_DEVICE_CLASS_GUID={%pUr}",
+			     device_ctx->class_id.data);
 
 	if (ret)
 		return ret;
 
-	ret = add_uevent_var(env, "VMBUS_DEVICE_DEVICE_GUID={"
-			     "%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			     "%02x%02x%02x%02x%02x%02x%02x%02x}",
-			     device_ctx->device_id.data[3],
-			     device_ctx->device_id.data[2],
-			     device_ctx->device_id.data[1],
-			     device_ctx->device_id.data[0],
-			     device_ctx->device_id.data[5],
-			     device_ctx->device_id.data[4],
-			     device_ctx->device_id.data[7],
-			     device_ctx->device_id.data[6],
-			     device_ctx->device_id.data[8],
-			     device_ctx->device_id.data[9],
-			     device_ctx->device_id.data[10],
-			     device_ctx->device_id.data[11],
-			     device_ctx->device_id.data[12],
-			     device_ctx->device_id.data[13],
-			     device_ctx->device_id.data[14],
-			     device_ctx->device_id.data[15]);
+	ret = add_uevent_var(env, "VMBUS_DEVICE_DEVICE_GUID={%pUr}",
+			     device_ctx->device_id.data);
 	if (ret)
 		return ret;
 
-- 
1.6.3.1.10.g659a0.dirty

