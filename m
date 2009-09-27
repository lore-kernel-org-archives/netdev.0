From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] treewide: use %pU to print UUID/GUIDs
Date: Sat, 26 Sep 2009 22:57:20 -0700
Message-ID: <ed3d30edbe451d63bf778a84ead8b7ca090d03b7.1254030722.git.joe@perches.com>
References: <cover.1254030722.git.joe@perches.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752916AbZI0F50@vger.kernel.org>
In-Reply-To: <cover.1254030722.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Converted individual GUID/UUID printing functions
to use the new %pU[Xr] in lib/vsprintf.c

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/char/random.c                |   10 +---
 drivers/firmware/dmi_scan.c          |    5 +--
 drivers/md/md.c                      |   16 ++------
 drivers/media/video/uvc/uvc_ctrl.c   |   69 ++++++++++++++++------------------
 drivers/media/video/uvc/uvc_driver.c |    7 +--
 drivers/media/video/uvc/uvcvideo.h   |   10 -----
 fs/gfs2/sys.c                        |   16 +------
 fs/ubifs/debug.c                     |    9 +---
 fs/ubifs/super.c                     |    7 +---
 fs/xfs/xfs_log_recover.c             |   14 ++-----
 include/linux/efi.h                  |    6 +--
 11 files changed, 54 insertions(+), 115 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 04b505e..7104df9 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1245,12 +1245,8 @@ static int proc_do_uuid(ctl_table *table, int write,
 	if (uuid[8] == 0)
 		generate_random_uuid(uuid);
 
-	sprintf(buf, "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-"
-		"%02x%02x%02x%02x%02x%02x",
-		uuid[0],  uuid[1],  uuid[2],  uuid[3],
-		uuid[4],  uuid[5],  uuid[6],  uuid[7],
-		uuid[8],  uuid[9],  uuid[10], uuid[11],
-		uuid[12], uuid[13], uuid[14], uuid[15]);
+	sprintf(buf, "%pU", uuid);
+
 	fake_table.data = buf;
 	fake_table.maxlen = sizeof(buf);
 
@@ -1350,7 +1346,7 @@ ctl_table random_table[] = {
 
 /********************************************************************
  *
- * Random funtions for networking
+ * Random functions for networking
  *
  ********************************************************************/
 
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index 938100f..c0deabb 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -169,10 +169,7 @@ static void __init dmi_save_uuid(const struct dmi_header *dm, int slot, int inde
 	if (!s)
 		return;
 
-	sprintf(s,
-		"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
-		d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7],
-		d[8], d[9], d[10], d[11], d[12], d[13], d[14], d[15]);
+	sprintf(s, "%pUX", d);
 
         dmi_ident[slot] = s;
 }
diff --git a/drivers/md/md.c b/drivers/md/md.c
index 26ba42a..68b52d7 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -1813,15 +1813,11 @@ static void print_sb_1(struct mdp_superblock_1 *sb)
 
 	uuid = sb->set_uuid;
 	printk(KERN_INFO
-	       "md:  SB: (V:%u) (F:0x%08x) Array-ID:<%02x%02x%02x%02x"
-	       ":%02x%02x:%02x%02x:%02x%02x:%02x%02x%02x%02x%02x%02x>\n"
+	       "md:  SB: (V:%u) (F:0x%08x) Array-ID:<%pU>\n"
 	       "md:    Name: \"%s\" CT:%llu\n",
 		le32_to_cpu(sb->major_version),
 		le32_to_cpu(sb->feature_map),
-		uuid[0], uuid[1], uuid[2], uuid[3],
-		uuid[4], uuid[5], uuid[6], uuid[7],
-		uuid[8], uuid[9], uuid[10], uuid[11],
-		uuid[12], uuid[13], uuid[14], uuid[15],
+		uuid,
 		sb->set_name,
 		(unsigned long long)le64_to_cpu(sb->ctime)
 		       & MD_SUPERBLOCK_1_TIME_SEC_MASK);
@@ -1830,8 +1826,7 @@ static void print_sb_1(struct mdp_superblock_1 *sb)
 	printk(KERN_INFO
 	       "md:       L%u SZ%llu RD:%u LO:%u CS:%u DO:%llu DS:%llu SO:%llu"
 			" RO:%llu\n"
-	       "md:     Dev:%08x UUID: %02x%02x%02x%02x:%02x%02x:%02x%02x:%02x%02x"
-	                ":%02x%02x%02x%02x%02x%02x\n"
+	       "md:     Dev:%08x UUID: %pU\n"
 	       "md:       (F:0x%08x) UT:%llu Events:%llu ResyncOffset:%llu CSUM:0x%08x\n"
 	       "md:         (MaxDev:%u) \n",
 		le32_to_cpu(sb->level),
@@ -1844,10 +1839,7 @@ static void print_sb_1(struct mdp_superblock_1 *sb)
 		(unsigned long long)le64_to_cpu(sb->super_offset),
 		(unsigned long long)le64_to_cpu(sb->recovery_offset),
 		le32_to_cpu(sb->dev_number),
-		uuid[0], uuid[1], uuid[2], uuid[3],
-		uuid[4], uuid[5], uuid[6], uuid[7],
-		uuid[8], uuid[9], uuid[10], uuid[11],
-		uuid[12], uuid[13], uuid[14], uuid[15],
+		uuid,
 		sb->devflags,
 		(unsigned long long)le64_to_cpu(sb->utime) & MD_SUPERBLOCK_1_TIME_SEC_MASK,
 		(unsigned long long)le64_to_cpu(sb->events),
diff --git a/drivers/media/video/uvc/uvc_ctrl.c b/drivers/media/video/uvc/uvc_ctrl.c
index c3225a5..2959e46 100644
--- a/drivers/media/video/uvc/uvc_ctrl.c
+++ b/drivers/media/video/uvc/uvc_ctrl.c
@@ -1093,8 +1093,8 @@ int uvc_xu_ctrl_query(struct uvc_video_chain *chain,
 
 	if (!found) {
 		uvc_trace(UVC_TRACE_CONTROL,
-			"Control " UVC_GUID_FORMAT "/%u not found.\n",
-			UVC_GUID_ARGS(entity->extension.guidExtensionCode),
+			"Control %pUr/%u not found.\n",
+			entity->extension.guidExtensionCode,
 			xctrl->selector);
 		return -EINVAL;
 	}
@@ -1171,9 +1171,9 @@ int uvc_ctrl_resume_device(struct uvc_device *dev)
 			    (ctrl->info->flags & UVC_CONTROL_RESTORE) == 0)
 				continue;
 
-			printk(KERN_INFO "restoring control " UVC_GUID_FORMAT
-				"/%u/%u\n", UVC_GUID_ARGS(ctrl->info->entity),
-				ctrl->info->index, ctrl->info->selector);
+			printk(KERN_INFO "restoring control %pUr/%u/%u\n",
+			       ctrl->info->entity,
+			       ctrl->info->index, ctrl->info->selector);
 			ctrl->dirty = 1;
 		}
 
@@ -1228,46 +1228,43 @@ static void uvc_ctrl_add_ctrl(struct uvc_device *dev,
 			dev->intfnum, info->selector, (__u8 *)&size, 2);
 		if (ret < 0) {
 			uvc_trace(UVC_TRACE_CONTROL, "GET_LEN failed on "
-				"control " UVC_GUID_FORMAT "/%u (%d).\n",
-				UVC_GUID_ARGS(info->entity), info->selector,
-				ret);
+				  "control %pUr/%u (%d).\n",
+				  info->entity, info->selector, ret);
 			return;
 		}
 
 		if (info->size != le16_to_cpu(size)) {
-			uvc_trace(UVC_TRACE_CONTROL, "Control " UVC_GUID_FORMAT
-				"/%u size doesn't match user supplied "
-				"value.\n", UVC_GUID_ARGS(info->entity),
-				info->selector);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "Control %pUr/%u size doesn't match user supplied value.\n",
+				  info->entity, info->selector);
 			return;
 		}
 
 		ret = uvc_query_ctrl(dev, UVC_GET_INFO, ctrl->entity->id,
 			dev->intfnum, info->selector, &inf, 1);
 		if (ret < 0) {
-			uvc_trace(UVC_TRACE_CONTROL, "GET_INFO failed on "
-				"control " UVC_GUID_FORMAT "/%u (%d).\n",
-				UVC_GUID_ARGS(info->entity), info->selector,
-				ret);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "GET_INFO failed on control %pUr/%u (%d).\n",
+				  info->entity, info->selector, ret);
 			return;
 		}
 
 		flags = info->flags;
 		if (((flags & UVC_CONTROL_GET_CUR) && !(inf & (1 << 0))) ||
 		    ((flags & UVC_CONTROL_SET_CUR) && !(inf & (1 << 1)))) {
-			uvc_trace(UVC_TRACE_CONTROL, "Control "
-				UVC_GUID_FORMAT "/%u flags don't match "
-				"supported operations.\n",
-				UVC_GUID_ARGS(info->entity), info->selector);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "Control %pUr/%u flags don't match supported operations.\n",
+				  info->entity, info->selector);
 			return;
 		}
 	}
 
 	ctrl->info = info;
 	ctrl->data = kmalloc(ctrl->info->size * UVC_CTRL_NDATA, GFP_KERNEL);
-	uvc_trace(UVC_TRACE_CONTROL, "Added control " UVC_GUID_FORMAT "/%u "
-		"to device %s entity %u\n", UVC_GUID_ARGS(ctrl->info->entity),
-		ctrl->info->selector, dev->udev->devpath, entity->id);
+	uvc_trace(UVC_TRACE_CONTROL,
+		  "Added control %pUr/%u to device %s entity %u\n",
+		  ctrl->info->entity, ctrl->info->selector,
+		  dev->udev->devpath, entity->id);
 }
 
 /*
@@ -1293,17 +1290,16 @@ int uvc_ctrl_add_info(struct uvc_control_info *info)
 			continue;
 
 		if (ctrl->selector == info->selector) {
-			uvc_trace(UVC_TRACE_CONTROL, "Control "
-				UVC_GUID_FORMAT "/%u is already defined.\n",
-				UVC_GUID_ARGS(info->entity), info->selector);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "Control %pUr/%u is already defined.\n",
+				  info->entity, info->selector);
 			ret = -EEXIST;
 			goto end;
 		}
 		if (ctrl->index == info->index) {
-			uvc_trace(UVC_TRACE_CONTROL, "Control "
-				UVC_GUID_FORMAT "/%u would overwrite index "
-				"%d.\n", UVC_GUID_ARGS(info->entity),
-				info->selector, info->index);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "Control %pUr/%u would overwrite index %d.\n",
+				  info->entity, info->selector, info->index);
 			ret = -EEXIST;
 			goto end;
 		}
@@ -1344,10 +1340,9 @@ int uvc_ctrl_add_mapping(struct uvc_control_mapping *mapping)
 			continue;
 
 		if (info->size * 8 < mapping->size + mapping->offset) {
-			uvc_trace(UVC_TRACE_CONTROL, "Mapping '%s' would "
-				"overflow control " UVC_GUID_FORMAT "/%u\n",
-				mapping->name, UVC_GUID_ARGS(info->entity),
-				info->selector);
+			uvc_trace(UVC_TRACE_CONTROL,
+				  "Mapping '%s' would overflow control %pUr/%u\n",
+				  mapping->name, info->entity, info->selector);
 			ret = -EOVERFLOW;
 			goto end;
 		}
@@ -1366,9 +1361,9 @@ int uvc_ctrl_add_mapping(struct uvc_control_mapping *mapping)
 
 		mapping->ctrl = info;
 		list_add_tail(&mapping->list, &info->mappings);
-		uvc_trace(UVC_TRACE_CONTROL, "Adding mapping %s to control "
-			UVC_GUID_FORMAT "/%u.\n", mapping->name,
-			UVC_GUID_ARGS(info->entity), info->selector);
+		uvc_trace(UVC_TRACE_CONTROL,
+			  "Adding mapping %s to control %pUr/%u.\n",
+			  mapping->name, info->entity, info->selector);
 
 		ret = 0;
 		break;
diff --git a/drivers/media/video/uvc/uvc_driver.c b/drivers/media/video/uvc/uvc_driver.c
index 8756be5..647d0a2 100644
--- a/drivers/media/video/uvc/uvc_driver.c
+++ b/drivers/media/video/uvc/uvc_driver.c
@@ -328,11 +328,10 @@ static int uvc_parse_format(struct uvc_device *dev,
 				sizeof format->name);
 			format->fcc = fmtdesc->fcc;
 		} else {
-			uvc_printk(KERN_INFO, "Unknown video format "
-				UVC_GUID_FORMAT "\n",
-				UVC_GUID_ARGS(&buffer[5]));
+			uvc_printk(KERN_INFO, "Unknown video format %pUr\n",
+				   &buffer[5]);
 			snprintf(format->name, sizeof format->name,
-				UVC_GUID_FORMAT, UVC_GUID_ARGS(&buffer[5]));
+				 "%pUr", &Buffer[5]);
 			format->fcc = 0;
 		}
 
diff --git a/drivers/media/video/uvc/uvcvideo.h b/drivers/media/video/uvc/uvcvideo.h
index e7958aa..9f4a437 100644
--- a/drivers/media/video/uvc/uvcvideo.h
+++ b/drivers/media/video/uvc/uvcvideo.h
@@ -555,16 +555,6 @@ extern unsigned int uvc_trace_param;
 #define uvc_printk(level, msg...) \
 	printk(level "uvcvideo: " msg)
 
-#define UVC_GUID_FORMAT "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-" \
-			"%02x%02x%02x%02x%02x%02x"
-#define UVC_GUID_ARGS(guid) \
-	(guid)[3],  (guid)[2],  (guid)[1],  (guid)[0], \
-	(guid)[5],  (guid)[4], \
-	(guid)[7],  (guid)[6], \
-	(guid)[8],  (guid)[9], \
-	(guid)[10], (guid)[11], (guid)[12], \
-	(guid)[13], (guid)[14], (guid)[15]
-
 /* --------------------------------------------------------------------------
  * Internal functions.
  */
diff --git a/fs/gfs2/sys.c b/fs/gfs2/sys.c
index 4463297..56901be 100644
--- a/fs/gfs2/sys.c
+++ b/fs/gfs2/sys.c
@@ -85,11 +85,7 @@ static ssize_t uuid_show(struct gfs2_sbd *sdp, char *buf)
 	buf[0] = '\0';
 	if (!gfs2_uuid_valid(uuid))
 		return 0;
-	return snprintf(buf, PAGE_SIZE, "%02X%02X%02X%02X-%02X%02X-"
-			"%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X\n",
-			uuid[0], uuid[1], uuid[2], uuid[3], uuid[4], uuid[5],
-			uuid[6], uuid[7], uuid[8], uuid[9], uuid[10], uuid[11],
-			uuid[12], uuid[13], uuid[14], uuid[15]);
+	return snprintf(buf, PAGE_SIZE, "%pUX\n", uuid);
 }
 
 static ssize_t freeze_show(struct gfs2_sbd *sdp, char *buf)
@@ -573,14 +569,8 @@ static int gfs2_uevent(struct kset *kset, struct kobject *kobj,
 	add_uevent_var(env, "LOCKPROTO=%s", sdp->sd_proto_name);
 	if (!sdp->sd_args.ar_spectator)
 		add_uevent_var(env, "JOURNALID=%u", sdp->sd_lockstruct.ls_jid);
-	if (gfs2_uuid_valid(uuid)) {
-		add_uevent_var(env, "UUID=%02X%02X%02X%02X-%02X%02X-%02X%02X-"
-			       "%02X%02X-%02X%02X%02X%02X%02X%02X",
-			       uuid[0], uuid[1], uuid[2], uuid[3], uuid[4],
-			       uuid[5], uuid[6], uuid[7], uuid[8], uuid[9],
-			       uuid[10], uuid[11], uuid[12], uuid[13],
-			       uuid[14], uuid[15]);
-	}
+	if (gfs2_uuid_valid(uuid))
+		add_uevent_var(env, "UUID=%pUX", uuid);
 	return 0;
 }
 
diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
index dbc093a..b16779e 100644
--- a/fs/ubifs/debug.c
+++ b/fs/ubifs/debug.c
@@ -350,13 +350,8 @@ void dbg_dump_node(const struct ubifs_info *c, const void *node)
 		       le32_to_cpu(sup->fmt_version));
 		printk(KERN_DEBUG "\ttime_gran      %u\n",
 		       le32_to_cpu(sup->time_gran));
-		printk(KERN_DEBUG "\tUUID           %02X%02X%02X%02X-%02X%02X"
-		       "-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X\n",
-		       sup->uuid[0], sup->uuid[1], sup->uuid[2], sup->uuid[3],
-		       sup->uuid[4], sup->uuid[5], sup->uuid[6], sup->uuid[7],
-		       sup->uuid[8], sup->uuid[9], sup->uuid[10], sup->uuid[11],
-		       sup->uuid[12], sup->uuid[13], sup->uuid[14],
-		       sup->uuid[15]);
+		printk(KERN_DEBUG "\tUUID           %pUX\n",
+		       sup->uuid);
 		break;
 	}
 	case UBIFS_MST_NODE:
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 333e181..7d59ab7 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -1393,12 +1393,7 @@ static int mount_ubifs(struct ubifs_info *c)
 		c->leb_size, c->leb_size >> 10);
 	dbg_msg("data journal heads:  %d",
 		c->jhead_cnt - NONDATA_JHEADS_CNT);
-	dbg_msg("UUID:                %02X%02X%02X%02X-%02X%02X"
-	       "-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
-	       c->uuid[0], c->uuid[1], c->uuid[2], c->uuid[3],
-	       c->uuid[4], c->uuid[5], c->uuid[6], c->uuid[7],
-	       c->uuid[8], c->uuid[9], c->uuid[10], c->uuid[11],
-	       c->uuid[12], c->uuid[13], c->uuid[14], c->uuid[15]);
+	dbg_msg("UUID:                %pUX", c->uuid);
 	dbg_msg("big_lpt              %d", c->big_lpt);
 	dbg_msg("log LEBs:            %d (%d - %d)",
 		c->log_lebs, UBIFS_LOG_LNUM, c->log_last);
diff --git a/fs/xfs/xfs_log_recover.c b/fs/xfs/xfs_log_recover.c
index 1099395..3b8e3df 100644
--- a/fs/xfs/xfs_log_recover.c
+++ b/fs/xfs/xfs_log_recover.c
@@ -225,16 +225,10 @@ xlog_header_check_dump(
 	xfs_mount_t		*mp,
 	xlog_rec_header_t	*head)
 {
-	int			b;
-
-	cmn_err(CE_DEBUG, "%s:  SB : uuid = ", __func__);
-	for (b = 0; b < 16; b++)
-		cmn_err(CE_DEBUG, "%02x", ((__uint8_t *)&mp->m_sb.sb_uuid)[b]);
-	cmn_err(CE_DEBUG, ", fmt = %d\n", XLOG_FMT);
-	cmn_err(CE_DEBUG, "    log : uuid = ");
-	for (b = 0; b < 16; b++)
-		cmn_err(CE_DEBUG, "%02x", ((__uint8_t *)&head->h_fs_uuid)[b]);
-	cmn_err(CE_DEBUG, ", fmt = %d\n", be32_to_cpu(head->h_fmt));
+	cmn_err(CE_DEBUG, "%s:  SB : uuid = %pU, fmt = %d\n",
+		__func__, &mp->m_sb.sb_uuid, XLOG_FMT);
+	cmn_err(CE_DEBUG, "    log : uuid = %pU, fmt = %d\n",
+		&head->h_fs_uuid, be32_to_cpu(head->h_fmt));
 }
 #else
 #define xlog_header_check_dump(mp, head)
diff --git a/include/linux/efi.h b/include/linux/efi.h
index ce4581f..dd85b39 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -280,11 +280,7 @@ efi_guidcmp (efi_guid_t left, efi_guid_t right)
 static inline char *
 efi_guid_unparse(efi_guid_t *guid, char *out)
 {
-	sprintf(out, "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-		guid->b[3], guid->b[2], guid->b[1], guid->b[0],
-		guid->b[5], guid->b[4], guid->b[7], guid->b[6],
-		guid->b[8], guid->b[9], guid->b[10], guid->b[11],
-		guid->b[12], guid->b[13], guid->b[14], guid->b[15]);
+	sprintf(out, "%pUr", guid->b);
         return out;
 }
 
-- 
1.6.3.1.10.g659a0.dirty
