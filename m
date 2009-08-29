From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 8/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5IdQU031901@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35851 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbZH2FXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 8/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_adapter.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_adapter.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_adapter.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_adapter.h	2009-08-28 21:09:29.302479000 -0700
@@ -0,0 +1,37 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_ADAPTER Module */
+#ifndef	__bfa_aen_adapter_h__
+#define	__bfa_aen_adapter_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_ADAPTER_ADD \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ADAPTER, BFA_ADAPTER_AEN_ADD)
+#define BFA_AEN_ADAPTER_REMOVE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ADAPTER, BFA_ADAPTER_AEN_REMOVE)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_audit.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_audit.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_audit.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_audit.h	2009-08-28 21:09:29.469480000 -0700
@@ -0,0 +1,37 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_AUDIT Module */
+#ifndef	__bfa_aen_audit_h__
+#define	__bfa_aen_audit_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_AUDIT_AUTH_ENABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_AUDIT, BFA_AUDIT_AEN_AUTH_ENABLE)
+#define BFA_AEN_AUDIT_AUTH_DISABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_AUDIT, BFA_AUDIT_AEN_AUTH_DISABLE)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_ethport.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_ethport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_ethport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_ethport.h	2009-08-28 21:09:29.363476000 -0700
@@ -0,0 +1,34 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+/* messages define for BFA_AEN_CAT_ETHPORT Module */
+#ifndef	__bfa_aen_ethport_h__
+#define	__bfa_aen_ethport_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_ETHPORT_LINKUP \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ETHPORT, BFA_ETHPORT_AEN_LINKUP)
+#define BFA_AEN_ETHPORT_LINKDOWN \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ETHPORT, BFA_ETHPORT_AEN_LINKDOWN)
+#define BFA_AEN_ETHPORT_ENABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ETHPORT, BFA_ETHPORT_AEN_ENABLE)
+#define BFA_AEN_ETHPORT_DISABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ETHPORT, BFA_ETHPORT_AEN_DISABLE)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen.h	2009-08-28 21:09:29.525491000 -0700
@@ -0,0 +1,112 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_AEN_H__
+#define __BFA_AEN_H__
+
+#include "defs/bfa_defs_aen.h"
+
+#define BFA_AEN_MAX_ENTRY   512
+
+extern s32 bfa_aen_max_cfg_entry;
+struct bfa_aen_s {
+	void *bfad;
+	s32 max_entry;
+	s32 write_index;
+	s32 read_index;
+	u32 bfad_num;
+	u32 seq_num;
+	void (*aen_cb_notify) (void *bfad);
+	void (*gettimeofday) (struct bfa_timeval_s * tv);
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_aen_entry_s list[BFA_AEN_MAX_ENTRY];	/* Must be the last */
+};
+
+
+/**
+ * Public APIs
+ */
+static inline void
+bfa_aen_set_max_cfg_entry(int max_entry)
+{
+	bfa_aen_max_cfg_entry = max_entry;
+}
+
+static inline s32
+bfa_aen_get_max_cfg_entry(void)
+{
+	return bfa_aen_max_cfg_entry;
+}
+
+static inline s32
+bfa_aen_get_meminfo(void)
+{
+	return (sizeof(struct bfa_aen_entry_s) * bfa_aen_get_max_cfg_entry());
+}
+
+static inline s32
+bfa_aen_get_wi(struct bfa_aen_s *aen)
+{
+	return aen->write_index;
+}
+
+static inline s32
+bfa_aen_get_ri(struct bfa_aen_s *aen)
+{
+	return aen->read_index;
+}
+
+static inline s32
+bfa_aen_fetch_count(struct bfa_aen_s *aen, s32 read_index)
+{
+	return ((aen->write_index + aen->max_entry) - read_index)
+		% aen->max_entry;
+}
+
+s32 bfa_aen_init(struct bfa_aen_s * aen, struct bfa_trc_mod_s * trcmod,
+		 void *bfad, u32 inst_id, void (*aen_cb_notify) (void *),
+		 void (*gettimeofday) (struct bfa_timeval_s *));
+
+s32 bfa_aen_post(struct bfa_aen_s *aen, enum bfa_aen_category aen_category,
+		 int aen_type, union bfa_aen_data_u *aen_data);
+
+s32 bfa_aen_fetch(struct bfa_aen_s *aen, struct bfa_aen_entry_s *aen_entry,
+		  s32 entry_space, s32 rii, s32 * ri_arr, s32 ri_arr_cnt);
+
+s32 bfa_aen_get_inst(struct bfa_aen_s *aen);
+
+static inline void
+wwn2str(char *wwn_str, u64 wwn)
+{
+	union {
+		u64 wwn;
+		u8 byte[8];
+	} w;
+
+	w.wwn = wwn;
+	sprintf(wwn_str, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x", w.byte[0],
+		w.byte[1], w.byte[2], w.byte[3], w.byte[4], w.byte[5],
+		w.byte[6], w.byte[7]);
+}
+
+#endif /* __BFA_AEN_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_ioc.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_ioc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_ioc.h	2009-08-28 21:09:29.499474000 -0700
@@ -0,0 +1,36 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+/* messages define for BFA_AEN_CAT_IOC Module */
+#ifndef	__bfa_aen_ioc_h__
+#define	__bfa_aen_ioc_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_IOC_HBGOOD \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_IOC, BFA_IOC_AEN_HBGOOD)
+#define BFA_AEN_IOC_HBFAIL \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_IOC, BFA_IOC_AEN_HBFAIL)
+#define BFA_AEN_IOC_ENABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_IOC, BFA_IOC_AEN_ENABLE)
+#define BFA_AEN_IOC_DISABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_IOC, BFA_IOC_AEN_DISABLE)
+#define BFA_AEN_IOC_FWMISMATCH \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_IOC, BFA_IOC_AEN_FWMISMATCH)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_itnim.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_itnim.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_itnim.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_itnim.h	2009-08-28 21:09:29.393475000 -0700
@@ -0,0 +1,39 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_ITNIM Module */
+#ifndef	__bfa_aen_itnim_h__
+#define	__bfa_aen_itnim_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_ITNIM_ONLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ITNIM, BFA_ITNIM_AEN_ONLINE)
+#define BFA_AEN_ITNIM_OFFLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ITNIM, BFA_ITNIM_AEN_OFFLINE)
+#define BFA_AEN_ITNIM_DISCONNECT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_ITNIM, BFA_ITNIM_AEN_DISCONNECT)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_lport.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_lport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_lport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_lport.h	2009-08-28 21:09:29.319469000 -0700
@@ -0,0 +1,57 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_LPORT Module */
+#ifndef	__bfa_aen_lport_h__
+#define	__bfa_aen_lport_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_LPORT_NEW \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NEW)
+#define BFA_AEN_LPORT_DELETE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_DELETE)
+#define BFA_AEN_LPORT_ONLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_ONLINE)
+#define BFA_AEN_LPORT_OFFLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_OFFLINE)
+#define BFA_AEN_LPORT_DISCONNECT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_DISCONNECT)
+#define BFA_AEN_LPORT_NEW_PROP \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NEW_PROP)
+#define BFA_AEN_LPORT_DELETE_PROP \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_DELETE_PROP)
+#define BFA_AEN_LPORT_NEW_STANDARD \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NEW_STANDARD)
+#define BFA_AEN_LPORT_DELETE_STANDARD \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_DELETE_STANDARD)
+#define BFA_AEN_LPORT_NPIV_DUP_WWN \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NPIV_DUP_WWN)
+#define BFA_AEN_LPORT_NPIV_FABRIC_MAX \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NPIV_FABRIC_MAX)
+#define BFA_AEN_LPORT_NPIV_UNKNOWN \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_LPORT, BFA_LPORT_AEN_NPIV_UNKNOWN)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_port.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_port.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_port.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_port.h	2009-08-28 21:09:29.378475000 -0700
@@ -0,0 +1,63 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_PORT Module */
+#ifndef	__bfa_aen_port_h__
+#define	__bfa_aen_port_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_PORT_ONLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_ONLINE)
+#define BFA_AEN_PORT_OFFLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_OFFLINE)
+#define BFA_AEN_PORT_RLIR \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_RLIR)
+#define BFA_AEN_PORT_SFP_INSERT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_SFP_INSERT)
+#define BFA_AEN_PORT_SFP_REMOVE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_SFP_REMOVE)
+#define BFA_AEN_PORT_SFP_POM \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_SFP_POM)
+#define BFA_AEN_PORT_ENABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_ENABLE)
+#define BFA_AEN_PORT_DISABLE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_DISABLE)
+#define BFA_AEN_PORT_AUTH_ON \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_AUTH_ON)
+#define BFA_AEN_PORT_AUTH_OFF \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_AUTH_OFF)
+#define BFA_AEN_PORT_DISCONNECT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_DISCONNECT)
+#define BFA_AEN_PORT_QOS_NEG \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_QOS_NEG)
+#define BFA_AEN_PORT_FABRIC_NAME_CHANGE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_FABRIC_NAME_CHANGE)
+#define BFA_AEN_PORT_SFP_ACCESS_ERROR \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_SFP_ACCESS_ERROR)
+#define BFA_AEN_PORT_SFP_UNSUPPORT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_PORT, BFA_PORT_AEN_SFP_UNSUPPORT)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_rport.h linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_rport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/aen/bfa_aen_rport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/aen/bfa_aen_rport.h	2009-08-28 21:09:29.272489000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for BFA_AEN_CAT_RPORT Module */
+#ifndef	__bfa_aen_rport_h__
+#define	__bfa_aen_rport_h__
+
+#include  <cs/bfa_log.h>
+#include  <defs/bfa_defs_aen.h>
+
+#define BFA_AEN_RPORT_ONLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_RPORT, BFA_RPORT_AEN_ONLINE)
+#define BFA_AEN_RPORT_OFFLINE \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_RPORT, BFA_RPORT_AEN_OFFLINE)
+#define BFA_AEN_RPORT_DISCONNECT \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_RPORT, BFA_RPORT_AEN_DISCONNECT)
+#define BFA_AEN_RPORT_QOS_PRIO \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_RPORT, BFA_RPORT_AEN_QOS_PRIO)
+#define BFA_AEN_RPORT_QOS_FLOWID \
+	BFA_LOG_CREATE_ID(BFA_AEN_CAT_RPORT, BFA_RPORT_AEN_QOS_FLOWID)
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_boot.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_boot.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_boot.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_boot.h	2009-08-28 21:09:29.927399000 -0700
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+/*
+ * bfi_boot.h
+ */
+
+#ifndef __BFI_BOOT_H__
+#define __BFI_BOOT_H__
+
+#define BFI_BOOT_TYPE_OFF		8
+#define BFI_BOOT_PARAM_OFF		12
+
+#define BFI_BOOT_TYPE_NORMAL 		0	/* param is device id */
+#define	BFI_BOOT_TYPE_FLASH		1
+#define	BFI_BOOT_TYPE_MEMTEST		2
+
+#define BFI_BOOT_MEMTEST_RES_ADDR   0x900
+#define BFI_BOOT_MEMTEST_RES_SIG    0xA0A1A2A3
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_cee.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_cee.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_cee.h	2009-08-28 21:09:29.616471000 -0700
@@ -0,0 +1,118 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/**
+ *  Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+ *  All rights reserved.
+ *
+ *  bfi_dcbx.h BFI Interface (Mailbox commands and related structures)
+ * between host driver and DCBX/LLDP firmware module.
+ *
+**/
+
+#ifndef __BFI_CEE_H__
+#define __BFI_CEE_H__
+
+#include <bfi/bfi.h>
+
+#pragma pack(1)
+
+
+enum bfi_cee_h2i_msgs_e {
+	BFI_CEE_H2I_GET_CFG_REQ = 1,
+	BFI_CEE_H2I_RESET_STATS = 2,
+	BFI_CEE_H2I_GET_STATS_REQ = 3,
+};
+
+
+enum bfi_cee_i2h_msgs_e {
+	BFI_CEE_I2H_GET_CFG_RSP = BFA_I2HM(1),
+	BFI_CEE_I2H_RESET_STATS_RSP = BFA_I2HM(2),
+	BFI_CEE_I2H_GET_STATS_RSP = BFA_I2HM(3),
+};
+
+
+/* Data structures */
+
+/*
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_lldp_reset_stats_s {
+	struct bfi_mhdr_s mh;
+};
+
+/*
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_cee_reset_stats_s {
+	struct bfi_mhdr_s mh;
+};
+
+/*
+ * BFI_CEE_H2I_GET_CFG_REQ
+ */
+struct bfi_cee_get_req_s {
+	struct bfi_mhdr_s mh;
+	union bfi_addr_u dma_addr;
+};
+
+
+/*
+ * BFI_CEE_I2H_GET_CFG_RSP
+ */
+struct bfi_cee_get_rsp_s {
+	struct bfi_mhdr_s mh;
+	u8 cmd_status;
+	u8 rsvd[3];
+};
+
+/*
+ * BFI_CEE_H2I_GET_STATS_REQ
+ */
+struct bfi_cee_stats_req_s {
+	struct bfi_mhdr_s mh;
+	union bfi_addr_u dma_addr;
+};
+
+
+/*
+ * BFI_CEE_I2H_GET_STATS_RSP
+ */
+struct bfi_cee_stats_rsp_s {
+	struct bfi_mhdr_s mh;
+	u8 cmd_status;
+	u8 rsvd[3];
+};
+
+
+
+union bfi_cee_h2i_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_cee_get_req_s get_req;
+	struct bfi_cee_stats_req_s stats_req;
+};
+
+
+union bfi_cee_i2h_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_cee_get_rsp_s get_rsp;
+	struct bfi_cee_stats_rsp_s stats_rsp;
+};
+
+#pragma pack()
+
+
+#endif /* __BFI_CEE_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ctreg.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ctreg.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ctreg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ctreg.h	2009-08-28 21:09:29.800401000 -0700
@@ -0,0 +1,610 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+/*
+ * bfi_ctreg.h catapult host block register definitions
+ *
+ * !!! Do not edit. Auto generated. !!!
+ */
+
+#ifndef __BFI_CTREG_H__
+#define __BFI_CTREG_H__
+
+
+#define HOSTFN0_LPU_MBOX0_0              0x00019200
+#define HOSTFN1_LPU_MBOX0_8              0x00019260
+#define LPU_HOSTFN0_MBOX0_0              0x00019280
+#define LPU_HOSTFN1_MBOX0_8              0x000192e0
+#define HOSTFN2_LPU_MBOX0_0              0x00019400
+#define HOSTFN3_LPU_MBOX0_8              0x00019460
+#define LPU_HOSTFN2_MBOX0_0              0x00019480
+#define LPU_HOSTFN3_MBOX0_8              0x000194e0
+#define HOSTFN0_INT_STATUS               0x00014000
+#define __HOSTFN0_HALT_OCCURRED          0x01000000
+#define __HOSTFN0_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN0_INT_STATUS_LVL_SH      20
+#define __HOSTFN0_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN0_INT_STATUS_LVL_SH)
+#define __HOSTFN0_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN0_INT_STATUS_P_SH        16
+#define __HOSTFN0_INT_STATUS_P(_v)       ((_v) << __HOSTFN0_INT_STATUS_P_SH)
+#define __HOSTFN0_INT_STATUS_F           0x0000ffff
+#define HOSTFN0_INT_MSK                  0x00014004
+#define HOST_PAGE_NUM_FN0                0x00014008
+#define __HOST_PAGE_NUM_FN               0x000001ff
+#define HOST_MSIX_ERR_INDEX_FN0          0x0001400c
+#define __MSIX_ERR_INDEX_FN              0x000001ff
+#define HOSTFN1_INT_STATUS               0x00014100
+#define __HOSTFN1_HALT_OCCURRED          0x01000000
+#define __HOSTFN1_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN1_INT_STATUS_LVL_SH      20
+#define __HOSTFN1_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN1_INT_STATUS_LVL_SH)
+#define __HOSTFN1_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN1_INT_STATUS_P_SH        16
+#define __HOSTFN1_INT_STATUS_P(_v)       ((_v) << __HOSTFN1_INT_STATUS_P_SH)
+#define __HOSTFN1_INT_STATUS_F           0x0000ffff
+#define HOSTFN1_INT_MSK                  0x00014104
+#define HOST_PAGE_NUM_FN1                0x00014108
+#define HOST_MSIX_ERR_INDEX_FN1          0x0001410c
+#define APP_PLL_425_CTL_REG              0x00014204
+#define __P_425_PLL_LOCK                 0x80000000
+#define __APP_PLL_425_SRAM_USE_100MHZ    0x00100000
+#define __APP_PLL_425_RESET_TIMER_MK     0x000e0000
+#define __APP_PLL_425_RESET_TIMER_SH     17
+#define __APP_PLL_425_RESET_TIMER(_v)    ((_v) << __APP_PLL_425_RESET_TIMER_SH)
+#define __APP_PLL_425_LOGIC_SOFT_RESET   0x00010000
+#define __APP_PLL_425_CNTLMT0_1_MK       0x0000c000
+#define __APP_PLL_425_CNTLMT0_1_SH       14
+#define __APP_PLL_425_CNTLMT0_1(_v)      ((_v) << __APP_PLL_425_CNTLMT0_1_SH)
+#define __APP_PLL_425_JITLMT0_1_MK       0x00003000
+#define __APP_PLL_425_JITLMT0_1_SH       12
+#define __APP_PLL_425_JITLMT0_1(_v)      ((_v) << __APP_PLL_425_JITLMT0_1_SH)
+#define __APP_PLL_425_HREF               0x00000800
+#define __APP_PLL_425_HDIV               0x00000400
+#define __APP_PLL_425_P0_1_MK            0x00000300
+#define __APP_PLL_425_P0_1_SH            8
+#define __APP_PLL_425_P0_1(_v)           ((_v) << __APP_PLL_425_P0_1_SH)
+#define __APP_PLL_425_Z0_2_MK            0x000000e0
+#define __APP_PLL_425_Z0_2_SH            5
+#define __APP_PLL_425_Z0_2(_v)           ((_v) << __APP_PLL_425_Z0_2_SH)
+#define __APP_PLL_425_RSEL200500         0x00000010
+#define __APP_PLL_425_ENARST             0x00000008
+#define __APP_PLL_425_BYPASS             0x00000004
+#define __APP_PLL_425_LRESETN            0x00000002
+#define __APP_PLL_425_ENABLE             0x00000001
+#define APP_PLL_312_CTL_REG              0x00014208
+#define __P_312_PLL_LOCK                 0x80000000
+#define __ENABLE_MAC_AHB_1               0x00800000
+#define __ENABLE_MAC_AHB_0               0x00400000
+#define __ENABLE_MAC_1                   0x00200000
+#define __ENABLE_MAC_0                   0x00100000
+#define __APP_PLL_312_RESET_TIMER_MK     0x000e0000
+#define __APP_PLL_312_RESET_TIMER_SH     17
+#define __APP_PLL_312_RESET_TIMER(_v)    ((_v) << __APP_PLL_312_RESET_TIMER_SH)
+#define __APP_PLL_312_LOGIC_SOFT_RESET   0x00010000
+#define __APP_PLL_312_CNTLMT0_1_MK       0x0000c000
+#define __APP_PLL_312_CNTLMT0_1_SH       14
+#define __APP_PLL_312_CNTLMT0_1(_v)      ((_v) << __APP_PLL_312_CNTLMT0_1_SH)
+#define __APP_PLL_312_JITLMT0_1_MK       0x00003000
+#define __APP_PLL_312_JITLMT0_1_SH       12
+#define __APP_PLL_312_JITLMT0_1(_v)      ((_v) << __APP_PLL_312_JITLMT0_1_SH)
+#define __APP_PLL_312_HREF               0x00000800
+#define __APP_PLL_312_HDIV               0x00000400
+#define __APP_PLL_312_P0_1_MK            0x00000300
+#define __APP_PLL_312_P0_1_SH            8
+#define __APP_PLL_312_P0_1(_v)           ((_v) << __APP_PLL_312_P0_1_SH)
+#define __APP_PLL_312_Z0_2_MK            0x000000e0
+#define __APP_PLL_312_Z0_2_SH            5
+#define __APP_PLL_312_Z0_2(_v)           ((_v) << __APP_PLL_312_Z0_2_SH)
+#define __APP_PLL_312_RSEL200500         0x00000010
+#define __APP_PLL_312_ENARST             0x00000008
+#define __APP_PLL_312_BYPASS             0x00000004
+#define __APP_PLL_312_LRESETN            0x00000002
+#define __APP_PLL_312_ENABLE             0x00000001
+#define MBIST_CTL_REG                    0x00014220
+#define __EDRAM_BISTR_START              0x00000004
+#define __MBIST_RESET                    0x00000002
+#define __MBIST_START                    0x00000001
+#define MBIST_STAT_REG                   0x00014224
+#define __EDRAM_BISTR_STATUS             0x00000008
+#define __EDRAM_BISTR_DONE               0x00000004
+#define __MEM_BIT_STATUS                 0x00000002
+#define __MBIST_DONE                     0x00000001
+#define HOST_SEM0_REG                    0x00014230
+#define __HOST_SEMAPHORE                 0x00000001
+#define HOST_SEM1_REG                    0x00014234
+#define HOST_SEM2_REG                    0x00014238
+#define HOST_SEM3_REG                    0x0001423c
+#define HOST_SEM0_INFO_REG               0x00014240
+#define HOST_SEM1_INFO_REG               0x00014244
+#define HOST_SEM2_INFO_REG               0x00014248
+#define HOST_SEM3_INFO_REG               0x0001424c
+#define ETH_MAC_SER_REG                  0x00014288
+#define __APP_EMS_CKBUFAMPIN             0x00000020
+#define __APP_EMS_REFCLKSEL              0x00000010
+#define __APP_EMS_CMLCKSEL               0x00000008
+#define __APP_EMS_REFCKBUFEN2            0x00000004
+#define __APP_EMS_REFCKBUFEN1            0x00000002
+#define __APP_EMS_CHANNEL_SEL            0x00000001
+#define HOSTFN2_INT_STATUS               0x00014300
+#define __HOSTFN2_HALT_OCCURRED          0x01000000
+#define __HOSTFN2_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN2_INT_STATUS_LVL_SH      20
+#define __HOSTFN2_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN2_INT_STATUS_LVL_SH)
+#define __HOSTFN2_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN2_INT_STATUS_P_SH        16
+#define __HOSTFN2_INT_STATUS_P(_v)       ((_v) << __HOSTFN2_INT_STATUS_P_SH)
+#define __HOSTFN2_INT_STATUS_F           0x0000ffff
+#define HOSTFN2_INT_MSK                  0x00014304
+#define HOST_PAGE_NUM_FN2                0x00014308
+#define HOST_MSIX_ERR_INDEX_FN2          0x0001430c
+#define HOSTFN3_INT_STATUS               0x00014400
+#define __HALT_OCCURRED                  0x01000000
+#define __HOSTFN3_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN3_INT_STATUS_LVL_SH      20
+#define __HOSTFN3_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN3_INT_STATUS_LVL_SH)
+#define __HOSTFN3_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN3_INT_STATUS_P_SH        16
+#define __HOSTFN3_INT_STATUS_P(_v)       ((_v) << __HOSTFN3_INT_STATUS_P_SH)
+#define __HOSTFN3_INT_STATUS_F           0x0000ffff
+#define HOSTFN3_INT_MSK                  0x00014404
+#define HOST_PAGE_NUM_FN3                0x00014408
+#define HOST_MSIX_ERR_INDEX_FN3          0x0001440c
+#define FNC_ID_REG                       0x00014600
+#define __FUNCTION_NUMBER                0x00000007
+#define FNC_PERS_REG                     0x00014604
+#define __F3_FUNCTION_ACTIVE             0x80000000
+#define __F3_FUNCTION_MODE               0x40000000
+#define __F3_PORT_MAP_MK                 0x30000000
+#define __F3_PORT_MAP_SH                 28
+#define __F3_PORT_MAP(_v)                ((_v) << __F3_PORT_MAP_SH)
+#define __F3_VM_MODE                     0x08000000
+#define __F3_INTX_STATUS_MK              0x07000000
+#define __F3_INTX_STATUS_SH              24
+#define __F3_INTX_STATUS(_v)             ((_v) << __F3_INTX_STATUS_SH)
+#define __F2_FUNCTION_ACTIVE             0x00800000
+#define __F2_FUNCTION_MODE               0x00400000
+#define __F2_PORT_MAP_MK                 0x00300000
+#define __F2_PORT_MAP_SH                 20
+#define __F2_PORT_MAP(_v)                ((_v) << __F2_PORT_MAP_SH)
+#define __F2_VM_MODE                     0x00080000
+#define __F2_INTX_STATUS_MK              0x00070000
+#define __F2_INTX_STATUS_SH              16
+#define __F2_INTX_STATUS(_v)             ((_v) << __F2_INTX_STATUS_SH)
+#define __F1_FUNCTION_ACTIVE             0x00008000
+#define __F1_FUNCTION_MODE               0x00004000
+#define __F1_PORT_MAP_MK                 0x00003000
+#define __F1_PORT_MAP_SH                 12
+#define __F1_PORT_MAP(_v)                ((_v) << __F1_PORT_MAP_SH)
+#define __F1_VM_MODE                     0x00000800
+#define __F1_INTX_STATUS_MK              0x00000700
+#define __F1_INTX_STATUS_SH              8
+#define __F1_INTX_STATUS(_v)             ((_v) << __F1_INTX_STATUS_SH)
+#define __F0_FUNCTION_ACTIVE             0x00000080
+#define __F0_FUNCTION_MODE               0x00000040
+#define __F0_PORT_MAP_MK                 0x00000030
+#define __F0_PORT_MAP_SH                 4
+#define __F0_PORT_MAP(_v)                ((_v) << __F0_PORT_MAP_SH)
+#define __F0_VM_MODE                     0x00000008
+#define __F0_INTX_STATUS                 0x00000007
+enum {
+	__F0_INTX_STATUS_MSIX = 0x0,
+	__F0_INTX_STATUS_INTA = 0x1,
+	__F0_INTX_STATUS_INTB = 0x2,
+	__F0_INTX_STATUS_INTC = 0x3,
+	__F0_INTX_STATUS_INTD = 0x4,
+};
+#define OP_MODE                          0x0001460c
+#define __APP_ETH_CLK_LOWSPEED           0x00000004
+#define __GLOBAL_CORECLK_HALFSPEED       0x00000002
+#define __GLOBAL_FCOE_MODE               0x00000001
+#define HOST_SEM4_REG                    0x00014610
+#define HOST_SEM5_REG                    0x00014614
+#define HOST_SEM6_REG                    0x00014618
+#define HOST_SEM7_REG                    0x0001461c
+#define HOST_SEM4_INFO_REG               0x00014620
+#define HOST_SEM5_INFO_REG               0x00014624
+#define HOST_SEM6_INFO_REG               0x00014628
+#define HOST_SEM7_INFO_REG               0x0001462c
+#define HOSTFN0_LPU0_MBOX0_CMD_STAT      0x00019000
+#define __HOSTFN0_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN0_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN0_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN0_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN0_LPU1_MBOX0_CMD_STAT      0x00019004
+#define __HOSTFN0_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN0_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN0_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN0_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN0_MBOX0_CMD_STAT      0x00019008
+#define __LPU0_HOSTFN0_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN0_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN0_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN0_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN0_MBOX0_CMD_STAT      0x0001900c
+#define __LPU1_HOSTFN0_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN0_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN0_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN1_LPU0_MBOX0_CMD_STAT      0x00019010
+#define __HOSTFN1_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN1_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN1_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN1_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN1_LPU1_MBOX0_CMD_STAT      0x00019014
+#define __HOSTFN1_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN1_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN1_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN1_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN1_MBOX0_CMD_STAT      0x00019018
+#define __LPU0_HOSTFN1_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN1_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN1_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN1_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN1_MBOX0_CMD_STAT      0x0001901c
+#define __LPU1_HOSTFN1_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN1_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN1_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN1_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN2_LPU0_MBOX0_CMD_STAT      0x00019150
+#define __HOSTFN2_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN2_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN2_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN2_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN2_LPU1_MBOX0_CMD_STAT      0x00019154
+#define __HOSTFN2_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN2_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN2_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN2_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU1_MBOX0BOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN2_MBOX0_CMD_STAT      0x00019158
+#define __LPU0_HOSTFN2_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN2_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN2_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN2_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN2_MBOX0_CMD_STAT      0x0001915c
+#define __LPU1_HOSTFN2_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN2_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN2_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN2_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN3_LPU0_MBOX0_CMD_STAT      0x00019160
+#define __HOSTFN3_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN3_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN3_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN3_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN3_LPU1_MBOX0_CMD_STAT      0x00019164
+#define __HOSTFN3_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN3_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN3_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN3_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN3_MBOX0_CMD_STAT      0x00019168
+#define __LPU0_HOSTFN3_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN3_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN3_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN3_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN3_MBOX0_CMD_STAT      0x0001916c
+#define __LPU1_HOSTFN3_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN3_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN3_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN3_MBOX0_CMD_STATUS  0x00000001
+#define FW_INIT_HALT_P0                  0x000191ac
+#define __FW_INIT_HALT_P                 0x00000001
+#define FW_INIT_HALT_P1                  0x000191bc
+#define CPE_PI_PTR_Q0                    0x00038000
+#define __CPE_PI_UNUSED_MK               0xffff0000
+#define __CPE_PI_UNUSED_SH               16
+#define __CPE_PI_UNUSED(_v)              ((_v) << __CPE_PI_UNUSED_SH)
+#define __CPE_PI_PTR                     0x0000ffff
+#define CPE_PI_PTR_Q1                    0x00038040
+#define CPE_CI_PTR_Q0                    0x00038004
+#define __CPE_CI_UNUSED_MK               0xffff0000
+#define __CPE_CI_UNUSED_SH               16
+#define __CPE_CI_UNUSED(_v)              ((_v) << __CPE_CI_UNUSED_SH)
+#define __CPE_CI_PTR                     0x0000ffff
+#define CPE_CI_PTR_Q1                    0x00038044
+#define CPE_DEPTH_Q0                     0x00038008
+#define __CPE_DEPTH_UNUSED_MK            0xf8000000
+#define __CPE_DEPTH_UNUSED_SH            27
+#define __CPE_DEPTH_UNUSED(_v)           ((_v) << __CPE_DEPTH_UNUSED_SH)
+#define __CPE_MSIX_VEC_INDEX_MK          0x07ff0000
+#define __CPE_MSIX_VEC_INDEX_SH          16
+#define __CPE_MSIX_VEC_INDEX(_v)         ((_v) << __CPE_MSIX_VEC_INDEX_SH)
+#define __CPE_DEPTH                      0x0000ffff
+#define CPE_DEPTH_Q1                     0x00038048
+#define CPE_QCTRL_Q0                     0x0003800c
+#define __CPE_CTRL_UNUSED30_MK           0xfc000000
+#define __CPE_CTRL_UNUSED30_SH           26
+#define __CPE_CTRL_UNUSED30(_v)          ((_v) << __CPE_CTRL_UNUSED30_SH)
+#define __CPE_FUNC_INT_CTRL_MK           0x03000000
+#define __CPE_FUNC_INT_CTRL_SH           24
+#define __CPE_FUNC_INT_CTRL(_v)          ((_v) << __CPE_FUNC_INT_CTRL_SH)
+enum {
+	__CPE_FUNC_INT_CTRL_DISABLE = 0x0,
+	__CPE_FUNC_INT_CTRL_F2NF = 0x1,
+	__CPE_FUNC_INT_CTRL_3QUART = 0x2,
+	__CPE_FUNC_INT_CTRL_HALF = 0x3,
+};
+#define __CPE_CTRL_UNUSED20_MK           0x00f00000
+#define __CPE_CTRL_UNUSED20_SH           20
+#define __CPE_CTRL_UNUSED20(_v)          ((_v) << __CPE_CTRL_UNUSED20_SH)
+#define __CPE_SCI_TH_MK                  0x000f0000
+#define __CPE_SCI_TH_SH                  16
+#define __CPE_SCI_TH(_v)                 ((_v) << __CPE_SCI_TH_SH)
+#define __CPE_CTRL_UNUSED10_MK           0x0000c000
+#define __CPE_CTRL_UNUSED10_SH           14
+#define __CPE_CTRL_UNUSED10(_v)          ((_v) << __CPE_CTRL_UNUSED10_SH)
+#define __CPE_ACK_PENDING                0x00002000
+#define __CPE_CTRL_UNUSED40_MK           0x00001c00
+#define __CPE_CTRL_UNUSED40_SH           10
+#define __CPE_CTRL_UNUSED40(_v)          ((_v) << __CPE_CTRL_UNUSED40_SH)
+#define __CPE_PCIEID_MK                  0x00000300
+#define __CPE_PCIEID_SH                  8
+#define __CPE_PCIEID(_v)                 ((_v) << __CPE_PCIEID_SH)
+#define __CPE_CTRL_UNUSED00_MK           0x000000fe
+#define __CPE_CTRL_UNUSED00_SH           1
+#define __CPE_CTRL_UNUSED00(_v)          ((_v) << __CPE_CTRL_UNUSED00_SH)
+#define __CPE_ESIZE                      0x00000001
+#define CPE_QCTRL_Q1                     0x0003804c
+#define __CPE_CTRL_UNUSED31_MK           0xfc000000
+#define __CPE_CTRL_UNUSED31_SH           26
+#define __CPE_CTRL_UNUSED31(_v)          ((_v) << __CPE_CTRL_UNUSED31_SH)
+#define __CPE_CTRL_UNUSED21_MK           0x00f00000
+#define __CPE_CTRL_UNUSED21_SH           20
+#define __CPE_CTRL_UNUSED21(_v)          ((_v) << __CPE_CTRL_UNUSED21_SH)
+#define __CPE_CTRL_UNUSED11_MK           0x0000c000
+#define __CPE_CTRL_UNUSED11_SH           14
+#define __CPE_CTRL_UNUSED11(_v)          ((_v) << __CPE_CTRL_UNUSED11_SH)
+#define __CPE_CTRL_UNUSED41_MK           0x00001c00
+#define __CPE_CTRL_UNUSED41_SH           10
+#define __CPE_CTRL_UNUSED41(_v)          ((_v) << __CPE_CTRL_UNUSED41_SH)
+#define __CPE_CTRL_UNUSED01_MK           0x000000fe
+#define __CPE_CTRL_UNUSED01_SH           1
+#define __CPE_CTRL_UNUSED01(_v)          ((_v) << __CPE_CTRL_UNUSED01_SH)
+#define RME_PI_PTR_Q0                    0x00038020
+#define __LATENCY_TIME_STAMP_MK          0xffff0000
+#define __LATENCY_TIME_STAMP_SH          16
+#define __LATENCY_TIME_STAMP(_v)         ((_v) << __LATENCY_TIME_STAMP_SH)
+#define __RME_PI_PTR                     0x0000ffff
+#define RME_PI_PTR_Q1                    0x00038060
+#define RME_CI_PTR_Q0                    0x00038024
+#define __DELAY_TIME_STAMP_MK            0xffff0000
+#define __DELAY_TIME_STAMP_SH            16
+#define __DELAY_TIME_STAMP(_v)           ((_v) << __DELAY_TIME_STAMP_SH)
+#define __RME_CI_PTR                     0x0000ffff
+#define RME_CI_PTR_Q1                    0x00038064
+#define RME_DEPTH_Q0                     0x00038028
+#define __RME_DEPTH_UNUSED_MK            0xf8000000
+#define __RME_DEPTH_UNUSED_SH            27
+#define __RME_DEPTH_UNUSED(_v)           ((_v) << __RME_DEPTH_UNUSED_SH)
+#define __RME_MSIX_VEC_INDEX_MK          0x07ff0000
+#define __RME_MSIX_VEC_INDEX_SH          16
+#define __RME_MSIX_VEC_INDEX(_v)         ((_v) << __RME_MSIX_VEC_INDEX_SH)
+#define __RME_DEPTH                      0x0000ffff
+#define RME_DEPTH_Q1                     0x00038068
+#define RME_QCTRL_Q0                     0x0003802c
+#define __RME_INT_LATENCY_TIMER_MK       0xff000000
+#define __RME_INT_LATENCY_TIMER_SH       24
+#define __RME_INT_LATENCY_TIMER(_v)      ((_v) << __RME_INT_LATENCY_TIMER_SH)
+#define __RME_INT_DELAY_TIMER_MK         0x00ff0000
+#define __RME_INT_DELAY_TIMER_SH         16
+#define __RME_INT_DELAY_TIMER(_v)        ((_v) << __RME_INT_DELAY_TIMER_SH)
+#define __RME_INT_DELAY_DISABLE          0x00008000
+#define __RME_DLY_DELAY_DISABLE          0x00004000
+#define __RME_ACK_PENDING                0x00002000
+#define __RME_FULL_INTERRUPT_DISABLE     0x00001000
+#define __RME_CTRL_UNUSED10_MK           0x00000c00
+#define __RME_CTRL_UNUSED10_SH           10
+#define __RME_CTRL_UNUSED10(_v)          ((_v) << __RME_CTRL_UNUSED10_SH)
+#define __RME_PCIEID_MK                  0x00000300
+#define __RME_PCIEID_SH                  8
+#define __RME_PCIEID(_v)                 ((_v) << __RME_PCIEID_SH)
+#define __RME_CTRL_UNUSED00_MK           0x000000fe
+#define __RME_CTRL_UNUSED00_SH           1
+#define __RME_CTRL_UNUSED00(_v)          ((_v) << __RME_CTRL_UNUSED00_SH)
+#define __RME_ESIZE                      0x00000001
+#define RME_QCTRL_Q1                     0x0003806c
+#define __RME_CTRL_UNUSED11_MK           0x00000c00
+#define __RME_CTRL_UNUSED11_SH           10
+#define __RME_CTRL_UNUSED11(_v)          ((_v) << __RME_CTRL_UNUSED11_SH)
+#define __RME_CTRL_UNUSED01_MK           0x000000fe
+#define __RME_CTRL_UNUSED01_SH           1
+#define __RME_CTRL_UNUSED01(_v)          ((_v) << __RME_CTRL_UNUSED01_SH)
+#define PSS_CTL_REG                      0x00018800
+#define __PSS_I2C_CLK_DIV_MK             0x007f0000
+#define __PSS_I2C_CLK_DIV_SH             16
+#define __PSS_I2C_CLK_DIV(_v)            ((_v) << __PSS_I2C_CLK_DIV_SH)
+#define __PSS_LMEM_INIT_DONE             0x00001000
+#define __PSS_LMEM_RESET                 0x00000200
+#define __PSS_LMEM_INIT_EN               0x00000100
+#define __PSS_LPU1_RESET                 0x00000002
+#define __PSS_LPU0_RESET                 0x00000001
+#define HQM_QSET0_RXQ_DRBL_P0            0x00038000
+#define __RXQ0_ADD_VECTORS_P             0x80000000
+#define __RXQ0_STOP_P                    0x40000000
+#define __RXQ0_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET1_RXQ_DRBL_P0            0x00038080
+#define __RXQ1_ADD_VECTORS_P             0x80000000
+#define __RXQ1_STOP_P                    0x40000000
+#define __RXQ1_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET0_RXQ_DRBL_P1            0x0003c000
+#define HQM_QSET1_RXQ_DRBL_P1            0x0003c080
+#define HQM_QSET0_TXQ_DRBL_P0            0x00038020
+#define __TXQ0_ADD_VECTORS_P             0x80000000
+#define __TXQ0_STOP_P                    0x40000000
+#define __TXQ0_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET1_TXQ_DRBL_P0            0x000380a0
+#define __TXQ1_ADD_VECTORS_P             0x80000000
+#define __TXQ1_STOP_P                    0x40000000
+#define __TXQ1_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET0_TXQ_DRBL_P1            0x0003c020
+#define HQM_QSET1_TXQ_DRBL_P1            0x0003c0a0
+#define HQM_QSET0_IB_DRBL_1_P0           0x00038040
+#define __IB1_0_ACK_P                    0x80000000
+#define __IB1_0_DISABLE_P                0x40000000
+#define __IB1_0_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET1_IB_DRBL_1_P0           0x000380c0
+#define __IB1_1_ACK_P                    0x80000000
+#define __IB1_1_DISABLE_P                0x40000000
+#define __IB1_1_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET0_IB_DRBL_1_P1           0x0003c040
+#define HQM_QSET1_IB_DRBL_1_P1           0x0003c0c0
+#define HQM_QSET0_IB_DRBL_2_P0           0x00038060
+#define __IB2_0_ACK_P                    0x80000000
+#define __IB2_0_DISABLE_P                0x40000000
+#define __IB2_0_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET1_IB_DRBL_2_P0           0x000380e0
+#define __IB2_1_ACK_P                    0x80000000
+#define __IB2_1_DISABLE_P                0x40000000
+#define __IB2_1_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET0_IB_DRBL_2_P1           0x0003c060
+#define HQM_QSET1_IB_DRBL_2_P1           0x0003c0e0
+
+
+/*
+ * These definitions are either in error/missing in spec. Its auto-generated
+ * from hard coded values in regparse.pl.
+ */
+#define __EMPHPOST_AT_4G_MK_FIX          0x0000001c
+#define __EMPHPOST_AT_4G_SH_FIX          0x00000002
+#define __EMPHPRE_AT_4G_FIX              0x00000003
+#define __SFP_TXRATE_EN_FIX              0x00000100
+#define __SFP_RXRATE_EN_FIX              0x00000080
+
+
+/*
+ * These register definitions are auto-generated from hard coded values
+ * in regparse.pl.
+ */
+
+
+/*
+ * These register mapping definitions are auto-generated from mapping tables
+ * in regparse.pl.
+ */
+#define BFA_IOC0_HBEAT_REG               HOST_SEM0_INFO_REG
+#define BFA_IOC0_STATE_REG               HOST_SEM1_INFO_REG
+#define BFA_IOC1_HBEAT_REG               HOST_SEM2_INFO_REG
+#define BFA_IOC1_STATE_REG               HOST_SEM3_INFO_REG
+#define BFA_FW_USE_COUNT                 HOST_SEM4_INFO_REG
+
+#define CPE_DEPTH_Q(__n) \
+	(CPE_DEPTH_Q0 + (__n) * (CPE_DEPTH_Q1 - CPE_DEPTH_Q0))
+#define CPE_QCTRL_Q(__n) \
+	(CPE_QCTRL_Q0 + (__n) * (CPE_QCTRL_Q1 - CPE_QCTRL_Q0))
+#define CPE_PI_PTR_Q(__n) \
+	(CPE_PI_PTR_Q0 + (__n) * (CPE_PI_PTR_Q1 - CPE_PI_PTR_Q0))
+#define CPE_CI_PTR_Q(__n) \
+	(CPE_CI_PTR_Q0 + (__n) * (CPE_CI_PTR_Q1 - CPE_CI_PTR_Q0))
+#define RME_DEPTH_Q(__n) \
+	(RME_DEPTH_Q0 + (__n) * (RME_DEPTH_Q1 - RME_DEPTH_Q0))
+#define RME_QCTRL_Q(__n) \
+	(RME_QCTRL_Q0 + (__n) * (RME_QCTRL_Q1 - RME_QCTRL_Q0))
+#define RME_PI_PTR_Q(__n) \
+	(RME_PI_PTR_Q0 + (__n) * (RME_PI_PTR_Q1 - RME_PI_PTR_Q0))
+#define RME_CI_PTR_Q(__n) \
+	(RME_CI_PTR_Q0 + (__n) * (RME_CI_PTR_Q1 - RME_CI_PTR_Q0))
+#define HQM_QSET_RXQ_DRBL_P0(__n) \
+	(HQM_QSET0_RXQ_DRBL_P0 + (__n) * (HQM_QSET1_RXQ_DRBL_P0 - \
+	HQM_QSET0_RXQ_DRBL_P0))
+#define HQM_QSET_TXQ_DRBL_P0(__n) \
+	(HQM_QSET0_TXQ_DRBL_P0 + (__n) * (HQM_QSET1_TXQ_DRBL_P0 - \
+	HQM_QSET0_TXQ_DRBL_P0))
+#define HQM_QSET_IB_DRBL_1_P0(__n) \
+	(HQM_QSET0_IB_DRBL_1_P0 + (__n) * (HQM_QSET1_IB_DRBL_1_P0 - \
+	HQM_QSET0_IB_DRBL_1_P0))
+#define HQM_QSET_IB_DRBL_2_P0(__n) \
+	(HQM_QSET0_IB_DRBL_2_P0 + (__n) * (HQM_QSET1_IB_DRBL_2_P0 - \
+	HQM_QSET0_IB_DRBL_2_P0))
+#define HQM_QSET_RXQ_DRBL_P1(__n) \
+	(HQM_QSET0_RXQ_DRBL_P1 + (__n) * (HQM_QSET1_RXQ_DRBL_P1 - \
+	HQM_QSET0_RXQ_DRBL_P1))
+#define HQM_QSET_TXQ_DRBL_P1(__n) \
+	(HQM_QSET0_TXQ_DRBL_P1 + (__n) * (HQM_QSET1_TXQ_DRBL_P1 - \
+	HQM_QSET0_TXQ_DRBL_P1))
+#define HQM_QSET_IB_DRBL_1_P1(__n) \
+	(HQM_QSET0_IB_DRBL_1_P1 + (__n) * (HQM_QSET1_IB_DRBL_1_P1 - \
+	HQM_QSET0_IB_DRBL_1_P1))
+#define HQM_QSET_IB_DRBL_2_P1(__n) \
+	(HQM_QSET0_IB_DRBL_2_P1 + (__n) * (HQM_QSET1_IB_DRBL_2_P1 - \
+	HQM_QSET0_IB_DRBL_2_P1))
+
+#define CPE_Q_NUM(__fn, __q)  (((__fn) << 2) + (__q))
+#define RME_Q_NUM(__fn, __q)  (((__fn) << 2) + (__q))
+#define CPE_Q_MASK(__q)  ((__q) & 0x3)
+#define RME_Q_MASK(__q)  ((__q) & 0x3)
+
+
+/*
+ * PCI MSI-X vector defines
+ */
+enum {
+	BFA_MSIX_CPE_Q0 = 0,
+	BFA_MSIX_CPE_Q1 = 1,
+	BFA_MSIX_CPE_Q2 = 2,
+	BFA_MSIX_CPE_Q3 = 3,
+	BFA_MSIX_RME_Q0 = 4,
+	BFA_MSIX_RME_Q1 = 5,
+	BFA_MSIX_RME_Q2 = 6,
+	BFA_MSIX_RME_Q3 = 7,
+	BFA_MSIX_LPU_ERR = 8,
+	BFA_MSIX_CT_MAX = 9,
+};
+
+/*
+ * And corresponding host interrupt status bit field defines
+ */
+#define __HFN_INT_CPE_Q0                   0x00000001U
+#define __HFN_INT_CPE_Q1                   0x00000002U
+#define __HFN_INT_CPE_Q2                   0x00000004U
+#define __HFN_INT_CPE_Q3                   0x00000008U
+#define __HFN_INT_CPE_Q4                   0x00000010U
+#define __HFN_INT_CPE_Q5                   0x00000020U
+#define __HFN_INT_CPE_Q6                   0x00000040U
+#define __HFN_INT_CPE_Q7                   0x00000080U
+#define __HFN_INT_RME_Q0                   0x00000100U
+#define __HFN_INT_RME_Q1                   0x00000200U
+#define __HFN_INT_RME_Q2                   0x00000400U
+#define __HFN_INT_RME_Q3                   0x00000800U
+#define __HFN_INT_RME_Q4                   0x00001000U
+#define __HFN_INT_RME_Q5                   0x00002000U
+#define __HFN_INT_RME_Q6                   0x00004000U
+#define __HFN_INT_RME_Q7                   0x00008000U
+#define __HFN_INT_ERR_EMC                  0x00010000U
+#define __HFN_INT_ERR_LPU0                 0x00020000U
+#define __HFN_INT_ERR_LPU1                 0x00040000U
+#define __HFN_INT_ERR_PSS                  0x00080000U
+#define __HFN_INT_MBOX_LPU0                0x00100000U
+#define __HFN_INT_MBOX_LPU1                0x00200000U
+#define __HFN_INT_MBOX1_LPU0               0x00400000U
+#define __HFN_INT_MBOX1_LPU1               0x00800000U
+#define __HFN_INT_CPE_MASK                 0x000000ffU
+#define __HFN_INT_RME_MASK                 0x0000ff00U
+
+
+/*
+ * catapult memory map.
+ */
+#define LL_PGN_HQM0                      0x0096
+#define LL_PGN_HQM1                      0x0097
+#define PSS_SMEM_PAGE_START	0x8000
+#define PSS_SMEM_PGNUM(_pg0, _ma)	((_pg0) + ((_ma) >> 15))
+#define PSS_SMEM_PGOFF(_ma)	((_ma) & 0x7fff)
+
+/*
+ * End of catapult memory map
+ */
+
+
+#endif /* __BFI_CTREG_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fabric.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fabric.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fabric.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fabric.h	2009-08-28 21:09:29.763417000 -0700
@@ -0,0 +1,98 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_FABRIC_H__
+#define __BFI_FABRIC_H__
+
+#include <bfi/bfi.h>
+
+#pragma pack(1)
+
+enum bfi_fabric_h2i_msgs {
+	BFI_FABRIC_H2I_CREATE_REQ = 1,
+	BFI_FABRIC_H2I_DELETE_REQ = 2,
+	BFI_FABRIC_H2I_SETAUTH = 3,
+};
+
+enum bfi_fabric_i2h_msgs {
+	BFI_FABRIC_I2H_CREATE_RSP = BFA_I2HM(1),
+	BFI_FABRIC_I2H_DELETE_RSP = BFA_I2HM(2),
+	BFI_FABRIC_I2H_SETAUTH_RSP = BFA_I2HM(3),
+	BFI_FABRIC_I2H_ONLINE = BFA_I2HM(4),
+	BFI_FABRIC_I2H_OFFLINE = BFA_I2HM(5),
+};
+
+struct bfi_fabric_create_req_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u8 vf_en;		/*  virtual fabric enable       */
+	u8 rsvd;
+	u16 vf_id;		/*  virtual fabric ID           */
+	wwn_t pwwn;		/*  port name                   */
+	wwn_t nwwn;		/*  node name                   */
+};
+
+struct bfi_fabric_create_rsp_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 bfa_handle;		/*  host fabric handle          */
+	u8 status;		/*  fabric create status        */
+	u8 rsvd;
+};
+
+struct bfi_fabric_delete_req_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 fw_handle;		/*  firmware fabric handle      */
+	u16 rsvd;
+};
+
+struct bfi_fabric_delete_rsp_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 bfa_handle;		/*  host fabric handle          */
+	u8 status;		/*  fabric deletion status      */
+	u8 rsvd;
+};
+
+#define BFI_FABRIC_AUTHSECRET_LEN	64
+struct bfi_fabric_setauth_req_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 fw_handle;		/*  f/w handle of fabric        */
+	u8 algorithm;
+	u8 group;
+	u8 secret[BFI_FABRIC_AUTHSECRET_LEN];
+};
+
+union bfi_fabric_h2i_msg_u {
+	bfi_msg_t *msg;
+	struct bfi_fabric_create_req_s *create_req;
+	struct bfi_fabric_delete_req_s *delete_req;
+};
+
+union bfi_fabric_i2h_msg_u {
+	bfi_msg_t *msg;
+	struct bfi_fabric_create_rsp_s *create_rsp;
+	struct bfi_fabric_delete_rsp_s *delete_rsp;
+};
+
+#pragma pack()
+
+#endif /* __BFI_FABRIC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fcpim.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fcpim.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fcpim.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fcpim.h	2009-08-28 21:09:29.685480000 -0700
@@ -0,0 +1,307 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_FCPIM_H__
+#define __BFI_FCPIM_H__
+
+#include "bfi.h"
+#include <protocol/fcp.h>
+
+#pragma pack(1)
+
+/*
+ * Initiator mode I-T nexus interface defines.
+ */
+
+enum bfi_itnim_h2i {
+	BFI_ITNIM_H2I_CREATE_REQ = 1,	/*  i-t nexus creation */
+	BFI_ITNIM_H2I_DELETE_REQ = 2,	/*  i-t nexus deletion */
+};
+
+enum bfi_itnim_i2h {
+	BFI_ITNIM_I2H_CREATE_RSP = BFA_I2HM(1),
+	BFI_ITNIM_I2H_DELETE_RSP = BFA_I2HM(2),
+	BFI_ITNIM_I2H_SLER_EVENT = BFA_I2HM(3),
+};
+
+struct bfi_itnim_create_req_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 fw_handle;		/*  f/w handle for itnim         */
+	u8 class;		/*  FC class for IO              */
+	u8 seq_rec;		/*  sequence recovery support    */
+	u8 msg_no;		/*  seq id of the msg            */
+};
+
+struct bfi_itnim_create_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 bfa_handle;		/*  bfa handle for itnim         */
+	u8 status;		/*  fcp request status           */
+	u8 seq_id;		/*  seq id of the msg            */
+};
+
+struct bfi_itnim_delete_req_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 fw_handle;		/*  f/w itnim handle             */
+	u8 seq_id;		/*  seq id of the msg            */
+	u8 rsvd;
+};
+
+struct bfi_itnim_delete_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 bfa_handle;		/*  bfa handle for itnim         */
+	u8 status;		/*  fcp request status           */
+	u8 seq_id;		/*  seq id of the msg            */
+};
+
+struct bfi_itnim_sler_event_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 bfa_handle;		/*  bfa handle for itnim         */
+	u16 rsvd;
+};
+
+union bfi_itnim_h2i_msg_u {
+	struct bfi_itnim_create_req_s *create_req;
+	struct bfi_itnim_delete_req_s *delete_req;
+	struct bfi_msg_s *msg;
+};
+
+union bfi_itnim_i2h_msg_u {
+	struct bfi_itnim_create_rsp_s *create_rsp;
+	struct bfi_itnim_delete_rsp_s *delete_rsp;
+	struct bfi_itnim_sler_event_s *sler_event;
+	struct bfi_msg_s *msg;
+};
+
+/*
+ * Initiator mode IO interface defines.
+ */
+
+enum bfi_ioim_h2i {
+	BFI_IOIM_H2I_IOABORT_REQ = 1,	/*  IO abort request     */
+	BFI_IOIM_H2I_IOCLEANUP_REQ = 2,	/*  IO cleanup request   */
+};
+
+enum bfi_ioim_i2h {
+	BFI_IOIM_I2H_IO_RSP = BFA_I2HM(1),	/*  non-fp IO response   */
+	BFI_IOIM_I2H_IOABORT_RSP = BFA_I2HM(2),	/*  ABORT rsp     */
+};
+
+/**
+ * IO command DIF info
+ */
+struct bfi_ioim_dif_s {
+	u32 dif_info[4];
+};
+
+/**
+ * FCP IO messages overview
+ *
+ * @note
+ * - Max CDB length supported is 64 bytes.
+ * - SCSI Linked commands and SCSI bi-directional Commands not
+ * 	 supported.
+ *
+ */
+struct bfi_ioim_req_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header            */
+	u16 io_tag;		/*  I/O tag                      */
+	u16 rport_hdl;		/*  itnim/rport firmware handle */
+	struct fcp_cmnd_s cmnd;	/*  IO request info              */
+
+	/**
+	 * SG elements array within the IO request must be double word
+	 * aligned. This aligment is required to optimize SGM setup for the IO.
+	 */
+	struct bfi_sge_s sges[BFI_SGE_INLINE_MAX];
+	u8 io_timeout;
+	u8 dif_en;
+	u8 rsvd_a[2];
+	struct bfi_ioim_dif_s dif;
+};
+
+/**
+ * 	This table shows various IO status codes from firmware and their
+ *	meaning. Host driver can use these status codes to further process
+ *	IO completions.
+ *
+ * 	BFI_IOIM_STS_OK		: IO completed with error free SCSI &
+ *					   transport status.
+ * 					   - io-tag can be reused.
+ *
+ * 	BFA_IOIM_STS_SCSI_ERR		: IO completed with scsi error.
+ * 					  - io-tag can be reused.
+ *
+ * 	BFI_IOIM_STS_HOST_ABORTED	: IO was aborted successfully due to
+ *					   host request.
+ * 					   - io-tag cannot be reused yet.
+ *
+ * 	BFI_IOIM_STS_ABORTED		: IO was aborted successfully
+ *					   internally by f/w.
+ * 					   - io-tag cannot be reused yet.
+ *
+ * 	BFI_IOIM_STS_TIMEDOUT	: IO timedout and ABTS/RRQ is happening
+ *					   in the firmware and
+ * 					   - io-tag cannot be reused yet.
+ *
+ * 	BFI_IOIM_STS_SQER_NEEDED	: Firmware could not recover the IO
+ *					  with sequence level error
+ * 					  logic and hence host needs to retry
+ *					  this IO with a different IO tag
+ * 					  - io-tag cannot be used yet.
+ *
+ * 	BFI_IOIM_STS_NEXUS_ABORT	: Second Level Error Recovery from host
+ *					  is required because 2 consecutive ABTS
+ *					  timedout and host needs logout and
+ *					  re-login with the target
+ * 					  - io-tag cannot be used yet.
+ *
+ * 	BFI_IOIM_STS_UNDERRUN	: IO completed with SCSI status good,
+ *					  but the data tranferred is less than
+ *					  the fcp data length in the command.
+ *					  ex. SCSI INQUIRY where transferred
+ *					  data length and residue count in FCP
+ *					  response accounts for total fcp-dl
+ * 					  - io-tag can be reused.
+ *
+ * 	BFI_IOIM_STS_OVERRUN	: IO completed with SCSI status good,
+ *					  but the data transerred is more than
+ *					  fcp data length in the command. ex.
+ *					  TAPE IOs where blocks can of unequal
+ *					  lengths.
+ * 					  - io-tag can be reused.
+ *
+ * 	BFI_IOIM_STS_RES_FREE	: Firmware has completed using io-tag
+ *					  during abort process
+ * 					  - io-tag can be reused.
+ *
+ * 	BFI_IOIM_STS_PROTO_ERR	: Firmware detected a protocol error.
+ *					  ex target sent more data than
+ *					  requested, or there was data frame
+ *					  loss and other reasons
+ * 					  - io-tag cannot be used yet.
+ *
+ * 	BFI_IOIM_STS_DIF_ERR	: Firwmare detected DIF error. ex: DIF
+ * 					  CRC err or Ref Tag err or App tag err.
+ * 					  - io-tag can be reused.
+ *
+ * 	BFA_IOIM_STS_TSK_MGT_ABORT	: IO was aborted because of Task
+ *					  Management command from the host
+ * 					  - io-tag can be reused.
+ *
+ * 	BFI_IOIM_STS_UTAG		: Firmware does not know about this
+ *					  io_tag.
+ * 					  - io-tag can be reused.
+ */
+enum bfi_ioim_status {
+	BFI_IOIM_STS_OK = 0,
+	BFI_IOIM_STS_HOST_ABORTED = 1,
+	BFI_IOIM_STS_ABORTED = 2,
+	BFI_IOIM_STS_TIMEDOUT = 3,
+	BFI_IOIM_STS_RES_FREE = 4,
+	BFI_IOIM_STS_SQER_NEEDED = 5,
+	BFI_IOIM_STS_PROTO_ERR = 6,
+	BFI_IOIM_STS_UTAG = 7,
+	BFI_IOIM_STS_PATHTOV = 8,
+};
+
+#define BFI_IOIM_SNSLEN	(256)
+/**
+ * I/O response message
+ */
+struct bfi_ioim_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header            */
+	u16 io_tag;		/*  completed IO tag             */
+	u16 bfa_rport_hndl;	/*  releated rport handle        */
+	u8 io_status;		/*  IO completion status         */
+	u8 reuse_io_tag;	/*  IO tag can be reused        */
+	u16 abort_tag;		/*  host abort request tag      */
+	u8 scsi_status;		/*  scsi status from target      */
+	u8 sns_len;		/*  scsi sense length            */
+	u8 resid_flags;		/*  IO residue flags             */
+	u8 rsvd_a;
+	u32 residue;		/*  IO residual length in bytes */
+	u32 rsvd_b[3];
+};
+
+struct bfi_ioim_abort_req_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header  */
+	u16 io_tag;		/*  I/O tag            */
+	u16 abort_tag;		/*  unique request tag */
+};
+
+/*
+ * Initiator mode task management command interface defines.
+ */
+
+enum bfi_tskim_h2i {
+	BFI_TSKIM_H2I_TM_REQ = 1,	/*  task-mgmt command         */
+	BFI_TSKIM_H2I_ABORT_REQ = 2,	/*  task-mgmt command         */
+};
+
+enum bfi_tskim_i2h {
+	BFI_TSKIM_I2H_TM_RSP = BFA_I2HM(1),
+};
+
+struct bfi_tskim_req_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header          */
+	u16 tsk_tag;		/*  task management tag        */
+	u16 itn_fhdl;		/*  itn firmware handle        */
+	lun_t lun;		/*  LU number                  */
+	u8 tm_flags;		/*  see fcp_tm_cmnd_t          */
+	u8 t_secs;		/*  Timeout value in seconds   */
+	u8 rsvd[2];
+};
+
+struct bfi_tskim_abortreq_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header          */
+	u16 tsk_tag;		/*  task management tag        */
+	u16 rsvd;
+};
+
+enum bfi_tskim_status {
+	/*
+	 * Following are FCP-4 spec defined status codes,
+	 * **DO NOT CHANGE THEM **
+	 */
+	BFI_TSKIM_STS_OK = 0,
+	BFI_TSKIM_STS_NOT_SUPP = 4,
+	BFI_TSKIM_STS_FAILED = 5,
+
+	/**
+	 * Defined by BFA
+	 */
+	BFI_TSKIM_STS_TIMEOUT = 10,	/*  TM request timedout     */
+	BFI_TSKIM_STS_ABORTED = 11,	/*  Aborted on host request */
+};
+
+struct bfi_tskim_rsp_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header            */
+	u16 tsk_tag;		/*  task mgmt cmnd tag           */
+	u8 tsk_status;		/*  @ref bfi_tskim_status */
+	u8 rsvd;
+};
+
+#pragma pack()
+
+#endif /* __BFI_FCPIM_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fcxp.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fcxp.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_fcxp.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_fcxp.h	2009-08-28 21:09:29.835401000 -0700
@@ -0,0 +1,77 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_FCXP_H__
+#define __BFI_FCXP_H__
+
+#include "bfi.h"
+
+#pragma pack(1)
+
+enum bfi_fcxp_h2i {
+	BFI_FCXP_H2I_SEND_REQ = 1,
+};
+
+enum bfi_fcxp_i2h {
+	BFI_FCXP_I2H_SEND_RSP = BFA_I2HM(1),
+};
+
+#define BFA_FCXP_MAX_SGES	2
+
+/**
+ * FCXP send request structure
+ */
+struct bfi_fcxp_send_req_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header               */
+	u16 fcxp_tag;		/*  driver request tag              */
+	u16 max_frmsz;		/*  max send frame size     */
+	u16 vf_id;		/*  vsan tag if applicable          */
+	u16 rport_fw_hndl;	/*  FW Handle for the remote port  */
+	u8 class;		/*  FC class used for req/rsp       */
+	u8 rsp_timeout;		/*  timeout in secs, 0-no response */
+	u8 cts;			/*  continue sequence               */
+	u8 lp_tag;		/*  lport tag                       */
+	struct fchs_s fchs;	/*  request FC header structure    */
+	u32 req_len;		/*  request payload length          */
+	u32 rsp_maxlen;		/*  max response length expected   */
+	struct bfi_sge_s req_sge[BFA_FCXP_MAX_SGES];	/*  request buf    */
+	struct bfi_sge_s rsp_sge[BFA_FCXP_MAX_SGES];	/*  response buf   */
+};
+
+/**
+ * FCXP send response structure
+ */
+struct bfi_fcxp_send_rsp_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header               */
+	u16 fcxp_tag;		/*  send request tag                */
+	u8 req_status;		/*  request status                  */
+	u8 rsvd;
+	u32 rsp_len;		/*  actual response length          */
+	u32 residue_len;	/*  residual response length        */
+	struct fchs_s fchs;	/*  response FC header structure   */
+};
+
+#pragma pack()
+
+#endif /* __BFI_FCXP_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi.h	2009-08-28 21:09:29.893415000 -0700
@@ -0,0 +1,176 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_H__
+#define __BFI_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_status.h>
+
+#pragma pack(1)
+
+/**
+ * Msg header common to all msgs
+ */
+struct bfi_mhdr_s {
+	u8 msg_class;		/*  @ref bfi_mclass_t       */
+	u8 msg_id;		/*  msg opcode with in the class   */
+	union {
+		struct {
+			u8 rsvd;
+			u8 lpu_id;	/*  msg destination         */
+		} h2i;
+		u16 i2htok;	/*  token in msgs to host           */
+	} mtag;
+};
+
+#define bfi_h2i_set(_mh, _mc, _op, _lpuid) do {		\
+	(_mh).msg_class 		= (_mc);      \
+	(_mh).msg_id			= (_op);      \
+	(_mh).mtag.h2i.lpu_id	= (_lpuid);      \
+} while (0)
+
+#define bfi_i2h_set(_mh, _mc, _op, _i2htok) do {		\
+	(_mh).msg_class 		= (_mc);      \
+	(_mh).msg_id			= (_op);      \
+	(_mh).mtag.i2htok		= (_i2htok);      \
+} while (0)
+
+/*
+ * Message opcodes: 0-127 to firmware, 128-255 to host
+ */
+#define BFI_I2H_OPCODE_BASE	128
+#define BFA_I2HM(_x) 			((_x) + BFI_I2H_OPCODE_BASE)
+
+/**
+ ****************************************************************************
+ *
+ * Scatter Gather Element and Page definition
+ *
+ ****************************************************************************
+ */
+
+#define BFI_SGE_INLINE	1
+#define BFI_SGE_INLINE_MAX	(BFI_SGE_INLINE + 1)
+
+/**
+ * SG Flags
+ */
+enum {
+	BFI_SGE_DATA = 0,	/*  data address, not last           */
+	BFI_SGE_DATA_CPL = 1,	/*  data addr, last in current page */
+	BFI_SGE_DATA_LAST = 3,	/*  data address, last               */
+	BFI_SGE_LINK = 2,	/*  link address                     */
+	BFI_SGE_PGDLEN = 2,	/*  cumulative data length for page */
+};
+
+/**
+ * DMA addresses
+ */
+union bfi_addr_u {
+	struct {
+		u32 addr_lo;
+		u32 addr_hi;
+	} a32;
+};
+
+/**
+ * Scatter Gather Element
+ */
+struct bfi_sge_s {
+#ifdef __BIGENDIAN
+	u32 flags:2, rsvd:2, sg_len:28;
+#else
+	u32 sg_len:28, rsvd:2, flags:2;
+#endif
+	union bfi_addr_u sga;
+};
+
+/**
+ * Scatter Gather Page
+ */
+#define BFI_SGPG_DATA_SGES		7
+#define BFI_SGPG_SGES_MAX		(BFI_SGPG_DATA_SGES + 1)
+#define BFI_SGPG_RSVD_WD_LEN	8
+struct bfi_sgpg_s {
+	struct bfi_sge_s sges[BFI_SGPG_SGES_MAX];
+	u32 rsvd[BFI_SGPG_RSVD_WD_LEN];
+};
+
+/*
+ * Large Message structure - 128 Bytes size Msgs
+ */
+#define BFI_LMSG_SZ		128
+#define BFI_LMSG_PL_WSZ	\
+			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr_s)) / 4)
+
+struct bfi_msg_s {
+	struct bfi_mhdr_s mhdr;
+	u32 pl[BFI_LMSG_PL_WSZ];
+};
+
+/**
+ * Mailbox message structure
+ */
+#define BFI_MBMSG_SZ		7
+struct bfi_mbmsg_s {
+	struct bfi_mhdr_s mh;
+	u32 pl[BFI_MBMSG_SZ];
+};
+
+/**
+ * Message Classes
+ */
+enum bfi_mclass {
+	BFI_MC_IOC = 1,		/*  IO Controller (IOC)     */
+	BFI_MC_DIAG = 2,	/*  Diagnostic Msgs                 */
+	BFI_MC_FLASH = 3,	/*  Flash message class     */
+	BFI_MC_CEE = 4,
+	BFI_MC_FC_PORT = 5,	/*  FC port                         */
+	BFI_MC_IOCFC = 6,	/*  FC - IO Controller (IOC)        */
+	BFI_MC_LL = 7,		/*  Link Layer                      */
+	BFI_MC_UF = 8,		/*  Unsolicited frame receive       */
+	BFI_MC_FCXP = 9,	/*  FC Transport                    */
+	BFI_MC_LPS = 10,	/*  lport fc login services         */
+	BFI_MC_RPORT = 11,	/*  Remote port             */
+	BFI_MC_ITNIM = 12,	/*  I-T nexus (Initiator mode)      */
+	BFI_MC_IOIM_READ = 13,	/*  read IO (Initiator mode)        */
+	BFI_MC_IOIM_WRITE = 14,	/*  write IO (Initiator mode)       */
+	BFI_MC_IOIM_IO = 15,	/*  IO (Initiator mode)     */
+	BFI_MC_IOIM = 16,	/*  IO (Initiator mode)     */
+	BFI_MC_IOIM_IOCOM = 17,	/*  good IO completion              */
+	BFI_MC_TSKIM = 18,	/*  Initiator Task management       */
+	BFI_MC_SBOOT = 19,	/*  SAN boot services               */
+	BFI_MC_IPFC = 20,	/*  IP over FC Msgs                 */
+	BFI_MC_PORT = 21,	/*  Physical port                   */
+	BFI_MC_MAX = 32
+};
+
+#define BFI_IOC_MAX_CQS		4
+#define BFI_IOC_MAX_CQS_ASIC	8
+#define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
+
+#pragma pack()
+
+#endif /* __BFI_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_iocfc.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_iocfc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_iocfc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_iocfc.h	2009-08-28 21:09:29.651476000 -0700
@@ -0,0 +1,183 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_IOCFC_H__
+#define __BFI_IOCFC_H__
+
+#include "bfi.h"
+#include <defs/bfa_defs_ioc.h>
+#include <defs/bfa_defs_iocfc.h>
+#include <defs/bfa_defs_boot.h>
+
+#pragma pack(1)
+
+enum bfi_iocfc_h2i_msgs {
+	BFI_IOCFC_H2I_CFG_REQ = 1,
+	BFI_IOCFC_H2I_GET_STATS_REQ = 2,
+	BFI_IOCFC_H2I_CLEAR_STATS_REQ = 3,
+	BFI_IOCFC_H2I_SET_INTR_REQ = 4,
+	BFI_IOCFC_H2I_UPDATEQ_REQ = 5,
+};
+
+enum bfi_iocfc_i2h_msgs {
+	BFI_IOCFC_I2H_CFG_REPLY = BFA_I2HM(1),
+	BFI_IOCFC_I2H_GET_STATS_RSP = BFA_I2HM(2),
+	BFI_IOCFC_I2H_CLEAR_STATS_RSP = BFA_I2HM(3),
+	BFI_IOCFC_I2H_UPDATEQ_RSP = BFA_I2HM(5),
+};
+
+struct bfi_iocfc_cfg_s {
+	u8 num_cqs;		/*  Number of CQs to be used     */
+	u8 sense_buf_len;	/*  SCSI sense length            */
+	u8 trunk_enabled;	/*  port trunking enabled        */
+	u8 trunk_ports;		/*  trunk ports bit map          */
+	u32 endian_sig;		/*  endian signature of host     */
+
+	/**
+	 * Request and response circular queue base addresses, size and
+	 * shadow index pointers.
+	 */
+	union bfi_addr_u req_cq_ba[BFI_IOC_MAX_CQS];
+	union bfi_addr_u req_shadow_ci[BFI_IOC_MAX_CQS];
+	u16 req_cq_elems[BFI_IOC_MAX_CQS];
+	union bfi_addr_u rsp_cq_ba[BFI_IOC_MAX_CQS];
+	union bfi_addr_u rsp_shadow_pi[BFI_IOC_MAX_CQS];
+	u16 rsp_cq_elems[BFI_IOC_MAX_CQS];
+
+	union bfi_addr_u stats_addr;	/*  DMA-able address for stats    */
+	union bfi_addr_u cfgrsp_addr;	/*  config response dma address  */
+	union bfi_addr_u ioim_snsbase;	/*  IO sense buffer base address */
+	struct bfa_iocfc_intr_attr_s intr_attr;	/*  IOC interrupt attributes */
+};
+
+/**
+ * Boot target wwn information for this port. This contains either the stored
+ * or discovered boot target port wwns for the port.
+ */
+struct bfi_iocfc_bootwwns {
+	wwn_t wwn[BFA_BOOT_BOOTLUN_MAX];
+	u8 nwwns;
+	u8 rsvd[7];
+};
+
+struct bfi_iocfc_cfgrsp_s {
+	struct bfa_iocfc_fwcfg_s fwcfg;
+	struct bfa_iocfc_intr_attr_s intr_attr;
+	struct bfi_iocfc_bootwwns bootwwns;
+};
+
+/**
+ * BFI_IOCFC_H2I_CFG_REQ message
+ */
+struct bfi_iocfc_cfg_req_s {
+	struct bfi_mhdr_s mh;
+	union bfi_addr_u ioc_cfg_dma_addr;
+};
+
+/**
+ * BFI_IOCFC_I2H_CFG_REPLY message
+ */
+struct bfi_iocfc_cfg_reply_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header          */
+	u8 cfg_success;		/*  cfg reply status           */
+	u8 lpu_bm;		/*  LPUs assigned for this IOC */
+	u8 rsvd[2];
+};
+
+/**
+ *  BFI_IOCFC_H2I_GET_STATS_REQ & BFI_IOCFC_H2I_CLEAR_STATS_REQ messages
+ */
+struct bfi_iocfc_stats_req_s {
+	struct bfi_mhdr_s mh;	/*  msg header            */
+	u32 msgtag;		/*  msgtag for reply      */
+};
+
+/**
+ * BFI_IOCFC_I2H_GET_STATS_RSP & BFI_IOCFC_I2H_CLEAR_STATS_RSP messages
+ */
+struct bfi_iocfc_stats_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header     */
+	u8 status;		/*  reply status          */
+	u8 rsvd[3];
+	u32 msgtag;		/*  msgtag for reply      */
+};
+
+/**
+ * BFI_IOCFC_H2I_SET_INTR_REQ message
+ */
+struct bfi_iocfc_set_intr_req_s {
+	struct bfi_mhdr_s mh;	/*  common msg header     */
+	u8 coalesce;		/*  enable intr coalescing */
+	u8 rsvd[3];
+	u16 delay;		/*  delay timer 0..1125us  */
+	u16 latency;		/*  latency timer 0..225us */
+};
+
+/**
+ * BFI_IOCFC_H2I_UPDATEQ_REQ message
+ */
+struct bfi_iocfc_updateq_req_s {
+	struct bfi_mhdr_s mh;	/*  common msg header     */
+	u32 reqq_ba;		/*  reqq base addr        */
+	u32 rspq_ba;		/*  rspq base addr        */
+	u32 reqq_sci;		/*  reqq shadow ci        */
+	u32 rspq_spi;		/*  rspq shadow pi        */
+};
+
+/**
+ * BFI_IOCFC_I2H_UPDATEQ_RSP message
+ */
+struct bfi_iocfc_updateq_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header     */
+	u8 status;		/*  updateq  status       */
+	u8 rsvd[3];
+};
+
+/**
+ * H2I Messages
+ */
+union bfi_iocfc_h2i_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_iocfc_cfg_req_s cfg_req;
+	struct bfi_iocfc_stats_req_s stats_get;
+	struct bfi_iocfc_stats_req_s stats_clr;
+	struct bfi_iocfc_updateq_req_s updateq_req;
+	u32 mboxmsg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * I2H Messages
+ */
+union bfi_iocfc_i2h_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_iocfc_cfg_reply_s cfg_reply;
+	struct bfi_iocfc_stats_rsp_s stats_get_rsp;
+	struct bfi_iocfc_stats_rsp_s stats_clr_rsp;
+	struct bfi_iocfc_updateq_rsp_s updateq_rsp;
+	u32 mboxmsg[BFI_IOC_MSGSZ];
+};
+
+#pragma pack()
+
+#endif /* __BFI_IOCFC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ioc.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ioc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ioc.h	2009-08-28 21:09:29.702474000 -0700
@@ -0,0 +1,208 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_IOC_H__
+#define __BFI_IOC_H__
+
+#include "bfi.h"
+#include <defs/bfa_defs_ioc.h>
+
+#pragma pack(1)
+
+enum bfi_ioc_h2i_msgs {
+	BFI_IOC_H2I_ENABLE_REQ = 1,
+	BFI_IOC_H2I_DISABLE_REQ = 2,
+	BFI_IOC_H2I_GETATTR_REQ = 3,
+	BFI_IOC_H2I_DBG_SYNC = 4,
+	BFI_IOC_H2I_DBG_DUMP = 5,
+};
+
+enum bfi_ioc_i2h_msgs {
+	BFI_IOC_I2H_ENABLE_REPLY = BFA_I2HM(1),
+	BFI_IOC_I2H_DISABLE_REPLY = BFA_I2HM(2),
+	BFI_IOC_I2H_GETATTR_REPLY = BFA_I2HM(3),
+	BFI_IOC_I2H_READY_EVENT = BFA_I2HM(4),
+	BFI_IOC_I2H_HBEAT = BFA_I2HM(5),
+};
+
+/**
+ * BFI_IOC_H2I_GETATTR_REQ message
+ */
+struct bfi_ioc_getattr_req_s {
+	struct bfi_mhdr_s mh;
+	union bfi_addr_u attr_addr;
+};
+
+struct bfi_ioc_attr_s {
+	wwn_t mfg_wwn;
+	mac_t mfg_mac;
+	u16 rsvd_a;
+	char brcd_serialnum[STRSZ(BFA_MFG_SERIALNUM_SIZE)];
+	u8 pcie_gen;
+	u8 pcie_lanes_orig;
+	u8 pcie_lanes;
+	u8 rx_bbcredit;		/*  receive buffer credits */
+	u32 adapter_prop;	/*  adapter properties     */
+	u16 maxfrsize;		/*  max receive frame size */
+	char asic_rev;
+	u8 rsvd_b;
+	char fw_version[BFA_VERSION_LEN];
+	char optrom_version[BFA_VERSION_LEN];
+	struct bfa_mfg_vpd_s vpd;
+};
+
+/**
+ * BFI_IOC_I2H_GETATTR_REPLY message
+ */
+struct bfi_ioc_getattr_reply_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header          */
+	u8 status;		/*  cfg reply status           */
+	u8 rsvd[3];
+};
+
+/**
+ * Firmware memory page offsets
+ */
+#define BFI_IOC_SMEM_PG0_CB	(0x40)
+#define BFI_IOC_SMEM_PG0_CT	(0x180)
+
+/**
+ * Firmware trace offset
+ */
+#define BFI_IOC_TRC_OFF		(0x4b00)
+#define BFI_IOC_TRC_ENTS	256
+
+#define BFI_IOC_FW_SIGNATURE	(0xbfadbfad)
+#define BFI_IOC_MD5SUM_SZ	4
+struct bfi_ioc_image_hdr_s {
+	u32 signature;		/*  constant signature */
+	u32 rsvd_a;
+	u32 exec;		/*  exec vector        */
+	u32 param;		/*  parameters         */
+	u32 rsvd_b[4];
+	u32 md5sum[BFI_IOC_MD5SUM_SZ];
+};
+
+/**
+ *  BFI_IOC_I2H_READY_EVENT message
+ */
+struct bfi_ioc_rdy_event_s {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 init_status;		/*  init event status */
+	u8 rsvd[3];
+};
+
+struct bfi_ioc_hbeat_s {
+	struct bfi_mhdr_s mh;	/*  common msg header           */
+	u32 hb_count;		/*  current heart beat count    */
+};
+
+/**
+ * IOC hardware/firmware state
+ */
+enum bfi_ioc_state {
+	BFI_IOC_UNINIT = 0,	/*  not initialized                 */
+	BFI_IOC_INITING = 1,	/*  h/w is being initialized        */
+	BFI_IOC_HWINIT = 2,	/*  h/w is initialized              */
+	BFI_IOC_CFG = 3,	/*  IOC configuration in progress   */
+	BFI_IOC_OP = 4,		/*  IOC is operational              */
+	BFI_IOC_DISABLING = 5,	/*  IOC is being disabled           */
+	BFI_IOC_DISABLED = 6,	/*  IOC is disabled                 */
+	BFI_IOC_CFG_DISABLED = 7,	/*  IOC is being disabled;transient */
+	BFI_IOC_HBFAIL = 8,	/*  IOC heart-beat failure          */
+	BFI_IOC_MEMTEST = 9,	/*  IOC is doing memtest            */
+};
+
+#define BFI_IOC_ENDIAN_SIG  0x12345678
+
+enum {
+	BFI_ADAPTER_TYPE_FC = 0x01,	/*  FC adapters           */
+	BFI_ADAPTER_TYPE_MK = 0x0f0000,	/*  adapter type mask     */
+	BFI_ADAPTER_TYPE_SH = 16,	/*  adapter type shift    */
+	BFI_ADAPTER_NPORTS_MK = 0xff00,	/*  number of ports mask  */
+	BFI_ADAPTER_NPORTS_SH = 8,	/*  number of ports shift */
+	BFI_ADAPTER_SPEED_MK = 0xff,	/*  adapter speed mask    */
+	BFI_ADAPTER_SPEED_SH = 0,	/*  adapter speed shift   */
+	BFI_ADAPTER_PROTO = 0x100000,	/*  prototype adapaters   */
+	BFI_ADAPTER_TTV = 0x200000,	/*  TTV debug capable     */
+	BFI_ADAPTER_UNSUPP = 0x400000,	/*  unknown adapter type  */
+};
+
+#define BFI_ADAPTER_GETP(__prop,__adap_prop)          		\
+    (((__adap_prop) & BFI_ADAPTER_ ## __prop ## _MK) >>         \
+     BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_SETP(__prop, __val)         		\
+    ((__val) << BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_IS_PROTO(__adap_type)   			\
+    ((__adap_type) & BFI_ADAPTER_PROTO)
+#define BFI_ADAPTER_IS_TTV(__adap_type)     			\
+    ((__adap_type) & BFI_ADAPTER_TTV)
+#define BFI_ADAPTER_IS_UNSUPP(__adap_type)  			\
+    ((__adap_type) & BFI_ADAPTER_UNSUPP)
+#define BFI_ADAPTER_IS_SPECIAL(__adap_type)                     \
+    ((__adap_type) & (BFI_ADAPTER_TTV | BFI_ADAPTER_PROTO |     \
+			BFI_ADAPTER_UNSUPP))
+
+/**
+ * BFI_IOC_H2I_ENABLE_REQ & BFI_IOC_H2I_DISABLE_REQ messages
+ */
+struct bfi_ioc_ctrl_req_s {
+	struct bfi_mhdr_s mh;
+	u8 ioc_class;
+	u8 rsvd[3];
+};
+
+/**
+ * BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages
+ */
+struct bfi_ioc_ctrl_reply_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header     */
+	u8 status;		/*  enable/disable status */
+	u8 rsvd[3];
+};
+
+#define BFI_IOC_MSGSZ   8
+/**
+ * H2I Messages
+ */
+union bfi_ioc_h2i_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_ioc_ctrl_req_s enable_req;
+	struct bfi_ioc_ctrl_req_s disable_req;
+	struct bfi_ioc_getattr_req_s getattr_req;
+	u32 mboxmsg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * I2H Messages
+ */
+union bfi_ioc_i2h_msg_u {
+	struct bfi_mhdr_s mh;
+	struct bfi_ioc_rdy_event_s rdy_event;
+	u32 mboxmsg[BFI_IOC_MSGSZ];
+};
+
+#pragma pack()
+
+#endif /* __BFI_IOC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ll.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ll.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_ll.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_ll.h	2009-08-28 21:09:29.746432000 -0700
@@ -0,0 +1,439 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ *	Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *	All rights reserved.
+ *
+ *	file bfi_if.h BNA Hardware and Firmware Interface
+ */
+#ifndef __BFI_LL_H__
+#define __BFI_LL_H__
+
+#include <bfi/bfi.h>
+#include <defs/bfa_defs_ioc.h>
+
+#pragma pack(1)
+
+/**
+ *	"enums" for all LL mailbox messages other than IOC
+ */
+enum {
+	BFI_LL_H2I_MAC_UCAST_SET_REQ = 1,
+	BFI_LL_H2I_MAC_UCAST_ADD_REQ = 2,
+	BFI_LL_H2I_MAC_UCAST_DEL_REQ = 3,
+
+	BFI_LL_H2I_MAC_MCAST_ADD_REQ = 4,
+	BFI_LL_H2I_MAC_MCAST_DEL_REQ = 5,
+	BFI_LL_H2I_MAC_MCAST_FILTER_REQ = 6,
+	BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ = 7,
+
+	BFI_LL_H2I_PORT_ADMIN_REQ = 8,
+	BFI_LL_H2I_STATS_GET_REQ = 9,
+	BFI_LL_H2I_STATS_CLEAR_REQ = 10,
+
+	BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ = 11,
+	BFI_LL_H2I_RXF_DEFAULT_SET_REQ = 12,
+
+	BFI_LL_H2I_TXQ_STOP_REQ = 13,
+	BFI_LL_H2I_RXQ_STOP_REQ = 14,
+
+	BFI_LL_H2I_DIAG_LOOPBACK_REQ = 15,
+
+	BFI_LL_H2I_SET_PAUSE_REQ = 16,
+	BFI_LL_H2I_MTU_INFO_REQ = 17,
+
+	BFI_LL_H2I_RX_REQ = 18,
+};
+
+enum {
+	BFI_LL_I2H_MAC_UCAST_SET_RSP = BFA_I2HM(1),
+	BFI_LL_I2H_MAC_UCAST_ADD_RSP = BFA_I2HM(2),
+	BFI_LL_I2H_MAC_UCAST_DEL_RSP = BFA_I2HM(3),
+
+	BFI_LL_I2H_MAC_MCAST_ADD_RSP = BFA_I2HM(4),
+	BFI_LL_I2H_MAC_MCAST_DEL_RSP = BFA_I2HM(5),
+	BFI_LL_I2H_MAC_MCAST_FILTER_RSP = BFA_I2HM(6),
+	BFI_LL_I2H_MAC_MCAST_DEL_ALL_RSP = BFA_I2HM(7),
+
+	BFI_LL_I2H_PORT_ADMIN_RSP = BFA_I2HM(8),
+	BFI_LL_I2H_STATS_GET_RSP = BFA_I2HM(9),
+	BFI_LL_I2H_STATS_CLEAR_RSP = BFA_I2HM(10),
+
+	BFI_LL_I2H_RXF_PROMISCUOUS_SET_RSP = BFA_I2HM(11),
+	BFI_LL_I2H_RXF_DEFAULT_SET_RSP = BFA_I2HM(12),
+
+	BFI_LL_I2H_TXQ_STOP_RSP = BFA_I2HM(13),
+	BFI_LL_I2H_RXQ_STOP_RSP = BFA_I2HM(14),
+
+	BFI_LL_I2H_DIAG_LOOPBACK_RSP = BFA_I2HM(15),
+
+	BFI_LL_I2H_SET_PAUSE_RSP = BFA_I2HM(16),
+
+	BFI_LL_I2H_MTU_INFO_RSP = BFA_I2HM(17),
+	BFI_LL_I2H_RX_RSP = BFA_I2HM(18),
+
+	BFI_LL_I2H_LINK_DOWN_AEN = BFA_I2HM(19),
+	BFI_LL_I2H_LINK_UP_AEN = BFA_I2HM(20),
+	BFI_LL_I2H_CEE_DOWN_AEN = BFA_I2HM(21),
+	BFI_LL_I2H_CEE_UP_AEN = BFA_I2HM(22),
+};
+
+/**
+ *        BFI_LL_H2I_MAC_UCAST_SET_REQ
+ *        BFI_LL_H2I_MAC_UCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_UCAST_DEL_REQ
+ *        BFI_LL_H2I_MAC_MCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_MCAST_DEL_REQ
+ */
+struct bfi_ll_mac_addr_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 rxf_id;
+	u8 rsvd1[3];
+	mac_t mac_addr;
+	u8 rsvd2[2];
+};
+
+/**
+ *	  BFI_LL_H2I_MAC_MCAST_FILTER_REQ
+ */
+struct bfi_ll_mcast_filter_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 rxf_id;
+	u8 enable;
+	u8 rsvd[2];
+};
+
+/**
+ *	  BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ
+ */
+struct bfi_ll_mcast_del_all_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 rxf_id;
+	u8 rsvd[3];
+};
+
+/**
+ *	BFI_LL_H2I_TXQ_STOP_REQ
+ *	BFI_LL_H2I_RXQ_STOP_REQ
+ */
+struct bfi_ll_q_stop_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u32 q_id_mask[2];	/*  bit-mask for queue ids */
+};
+
+/**
+ *    BFI_LL_I2H_STATS_GET_REQ
+ *    BFI_LL_I2H_STATS_CLEAR_REQ
+ */
+struct bfi_ll_stats_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u16 stats_mask;		/*  bit-mask for non-function statistics */
+	u8 rsvd[2];
+	u32 rxf_id_mask[2];	/*  bit-mask for RxF Statistics */
+	u32 txf_id_mask[2];	/*  bit-mask for TxF Statistics */
+	union bfi_addr_u host_buffer;	/*  where statistics are returned */
+};
+
+
+#define BFI_LL_STATS_MAC	(1 << 0)	/*  MAC Statistics */
+#define BFI_LL_STATS_BPC	(1 << 1)	/*  Pause Stats from BPC */
+#define BFI_LL_STATS_RAD	(1 << 2)	/*  Rx Admission Statistics */
+#define BFI_LL_STATS_RX_FC	(1 << 3)	/*  Rx FC Stats from RxA */
+#define BFI_LL_STATS_TX_FC	(1 << 4)	/*  Tx FC Stats from TxA */
+
+#define BFI_LL_STATS_ALL	0x1f
+
+
+
+struct bfi_ll_port_admin_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 up;
+	u8 rsvd[3];
+};
+
+/**
+ *      BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ
+ *      BFI_LL_H2I_RXF_DEFAULT_SET_REQ
+ */
+struct bfi_ll_rxf_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 rxf_id;
+	u8 enable;
+	u8 rsvd[2];
+};
+
+/**
+ *      BFI_LL_H2I_RX_REQ
+ */
+struct bfi_ll_rxf_multi_req {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u32 rxf_id_mask[2];
+	u8 enable;
+	u8 rsvd[3];
+};
+
+/**
+ *      BFI_LL_H2I_DIAG_LOOPBACK
+ */
+struct bfi_ll_diag_lb_req {
+	struct bfi_mhdr_s mh;	/* 4 bytes */
+	u8 enable;		/* =1 : enable, =0 : disable */
+	u8 mode;		/* cable or Serdes */
+	u8 rsvd[2];
+};
+
+
+enum {
+	BFI_LL_DIAG_LB_OPMODE_EXT = 0,
+	BFI_LL_DIAG_LB_OPMODE_CBL = 1,
+};
+
+/**
+ *	BFI_LL_H2I_SET_PAUSE_REQ
+ */
+struct bfi_ll_set_pause_req {
+	struct bfi_mhdr_s mh;
+	u8 tx_pause;		/* 1 = enable, 0 =  disable */
+	u8 rx_pause;		/* 1 = enable, 0 =  disable */
+	u8 rsvd[2];
+};
+
+/**
+ *	BFI_LL_H2I_MTU_INFO_REQ
+ */
+struct bfi_ll_mtu_info_req {
+	struct bfi_mhdr_s mh;
+	u16 mtu;
+	u8 rsvd[2];
+};
+
+/**
+ *	  Response header format used by all responses
+ *	  For both responses and asynchronous notifications
+ */
+struct bfi_ll_rsp {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u8 error;
+	u8 rsvd[3];
+};
+
+/**
+ *	BFI_LL_I2H_LINK_DOWN_AEN
+ *	BFI_LL_I2H_LINK_UP_AEN
+ *	BFI_LL_I2H_CEE_DOWN_AEN
+ *	BFI_LL_I2H_CEE_UP_AEN
+ */
+struct bfi_ll_aen {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	u32 reason;
+	u8 prio_map;		/*  LL priority bit-map */
+	u8 rsvd[3];
+};
+
+/**
+ * 	The following error codes can be returned
+ *	by the mbox commands
+ */
+enum {
+	BFI_LL_CMD_OK = 0,
+	BFI_LL_CMD_FAIL = 1,
+	BFI_LL_CMD_DUP_ENTRY = 2,	/*  Duplicate entry in CAM */
+	BFI_LL_CMD_CAM_FULL = 3,	/*  CAM is full */
+	BFI_LL_CMD_NOT_OWNER = 4,	/*  Not permitted, b'cos not owner */
+	BFI_LL_CMD_NOT_EXEC = 5,	/*  Was not sent to f/w at all */
+};
+
+/* Statistics */
+#define BFI_LL_TXF_ID_MAX  	64
+#define BFI_LL_RXF_ID_MAX  	64
+
+/* TxF Frame Statistics */
+struct bfi_ll_stats_txf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+
+	u64 errors;
+	u64 filter_vlan;	/* frames filtered due to VLAN */
+	u64 filter_mac_sa;	/* frames filtered due to SA check */
+};
+
+
+/* RxF Frame Statistics */
+struct bfi_ll_stats_rxf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+	u64 frame_drops;
+};
+
+
+/* FC Tx Frame Statistics */
+struct bfi_ll_stats_fc_tx {
+	u64 txf_ucast_octets;
+	u64 txf_ucast;
+	u64 txf_ucast_vlan;
+
+	u64 txf_mcast_octets;
+	u64 txf_mcast;
+	u64 txf_mcast_vlan;
+
+	u64 txf_bcast_octets;
+	u64 txf_bcast;
+	u64 txf_bcast_vlan;
+
+	u64 txf_parity_errors;
+	u64 txf_timeout;
+	u64 txf_fid_parity_errors;
+};
+
+
+/* FC Rx Frame Statistics */
+struct bfi_ll_stats_fc_rx {
+	u64 rxf_ucast_octets;
+	u64 rxf_ucast;
+	u64 rxf_ucast_vlan;
+
+	u64 rxf_mcast_octets;
+	u64 rxf_mcast;
+	u64 rxf_mcast_vlan;
+
+	u64 rxf_bcast_octets;
+	u64 rxf_bcast;
+	u64 rxf_bcast_vlan;
+};
+
+
+/* RAD Frame Statistics */
+struct bfi_ll_stats_rad {
+	u64 rx_frames;
+	u64 rx_octets;
+	u64 rx_vlan_frames;
+
+	u64 rx_ucast;
+	u64 rx_ucast_octets;
+	u64 rx_ucast_vlan;
+
+	u64 rx_mcast;
+	u64 rx_mcast_octets;
+	u64 rx_mcast_vlan;
+
+	u64 rx_bcast;
+	u64 rx_bcast_octets;
+	u64 rx_bcast_vlan;
+
+	u64 rx_drops;
+};
+
+
+/* BPC Tx Registers */
+struct bfi_ll_stats_bpc {
+	/* transmit stats */
+	u64 tx_pause[8];
+	u64 tx_zero_pause[8];	/*  Pause cancellation */
+	u64 tx_first_pause[8];	/*  Pause initiation rather than retention */
+
+	/* receive stats */
+	u64 rx_pause[8];
+	u64 rx_zero_pause[8];	/*  Pause cancellation */
+	u64 rx_first_pause[8];	/*  Pause initiation rather than retention */
+};
+
+
+/* MAC Rx Statistics */
+struct bfi_ll_stats_mac {
+	u64 frame_64;		/* both rx and tx counter */
+	u64 frame_65_127;	/* both rx and tx counter */
+	u64 frame_128_255;	/* both rx and tx counter */
+	u64 frame_256_511;	/* both rx and tx counter */
+	u64 frame_512_1023;	/* both rx and tx counter */
+	u64 frame_1024_1518;	/* both rx and tx counter */
+	u64 frame_1519_1522;	/* both rx and tx counter */
+
+	/* receive stats */
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_fcs_error;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_control_frames;
+	u64 rx_pause;
+	u64 rx_unknown_opcode;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_carrier_sense_error;
+	u64 rx_undersize;
+	u64 rx_oversize;
+	u64 rx_fragments;
+	u64 rx_jabber;
+	u64 rx_drop;
+
+	/* transmit stats */
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_pause;
+	u64 tx_deferral;
+	u64 tx_excessive_deferral;
+	u64 tx_single_collision;
+	u64 tx_muliple_collision;
+	u64 tx_late_collision;
+	u64 tx_excessive_collision;
+	u64 tx_total_collision;
+	u64 tx_pause_honored;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_control_frame;
+	u64 tx_oversize;
+	u64 tx_undersize;
+	u64 tx_fragments;
+};
+
+
+/* Complete statistics */
+struct bfi_ll_stats {
+	struct bfi_ll_stats_mac mac_stats;
+	struct bfi_ll_stats_bpc bpc_stats;
+	struct bfi_ll_stats_rad rad_stats;
+	struct bfi_ll_stats_fc_rx fc_rx_stats;
+	struct bfi_ll_stats_fc_tx fc_tx_stats;
+	struct bfi_ll_stats_rxf rxf_stats[BFI_LL_RXF_ID_MAX];
+	struct bfi_ll_stats_txf txf_stats[BFI_LL_TXF_ID_MAX];
+};
+
+#pragma pack()
+
+#endif /* __BFI_LL_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_lport.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_lport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_lport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_lport.h	2009-08-28 21:09:29.878478000 -0700
@@ -0,0 +1,95 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_LPORT_H__
+#define __BFI_LPORT_H__
+
+#include <bfi/bfi.h>
+
+#pragma pack(1)
+
+enum bfi_lport_h2i_msgs {
+	BFI_LPORT_H2I_CREATE_REQ = 1,
+	BFI_LPORT_H2I_DELETE_REQ = 2,
+};
+
+enum bfi_lport_i2h_msgs {
+	BFI_LPORT_I2H_CREATE_RSP = BFA_I2HM(1),
+	BFI_LPORT_I2H_DELETE_RSP = BFA_I2HM(2),
+	BFI_LPORT_I2H_ONLINE = BFA_I2HM(3),
+	BFI_LPORT_I2H_OFFLINE = BFA_I2HM(4),
+};
+
+#define BFI_LPORT_MAX_SYNNAME	64
+
+enum bfi_lport_role_e {
+	BFI_LPORT_ROLE_FCPIM = 1,
+	BFI_LPORT_ROLE_FCPTM = 2,
+	BFI_LPORT_ROLE_IPFC = 4,
+};
+
+struct bfi_lport_create_req_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 fabric_fwhdl;	/*  parent fabric instance      */
+	u8 roles;		/*  lport FC-4 roles            */
+	u8 rsvd;
+	wwn_t pwwn;		/*  port name                   */
+	wwn_t nwwn;		/*  node name                   */
+	u8 symname[BFI_LPORT_MAX_SYNNAME];
+};
+
+struct bfi_lport_create_rsp_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u8 status;		/*  lport creation status       */
+	u8 rsvd[3];
+};
+
+struct bfi_lport_delete_req_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 fw_handle;		/*  firmware lport handle       */
+	u16 rsvd;
+};
+
+struct bfi_lport_delete_rsp_s {
+	bfi_mhdr_t mh;		/*  common msg header           */
+	u16 bfa_handle;		/*  host lport handle           */
+	u8 status;		/*  lport deletion status       */
+	u8 rsvd;
+};
+
+union bfi_lport_h2i_msg_u {
+	bfi_msg_t *msg;
+	struct bfi_lport_create_req_s *create_req;
+	struct bfi_lport_delete_req_s *delete_req;
+};
+
+union bfi_lport_i2h_msg_u {
+	bfi_msg_t *msg;
+	struct bfi_lport_create_rsp_s *create_rsp;
+	struct bfi_lport_delete_rsp_s *delete_rsp;
+};
+
+#pragma pack()
+
+#endif /* __BFI_LPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_pport.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_pport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_pport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_pport.h	2009-08-28 21:09:29.910401000 -0700
@@ -0,0 +1,190 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFI_PPORT_H__
+#define __BFI_PPORT_H__
+
+#include <bfi/bfi.h>
+#include <defs/bfa_defs_pport.h>
+
+#pragma pack(1)
+
+enum bfi_pport_h2i {
+	BFI_PPORT_H2I_ENABLE_REQ = (1),
+	BFI_PPORT_H2I_DISABLE_REQ = (2),
+	BFI_PPORT_H2I_GET_STATS_REQ = (3),
+	BFI_PPORT_H2I_CLEAR_STATS_REQ = (4),
+	BFI_PPORT_H2I_SET_SVC_PARAMS_REQ = (5),
+	BFI_PPORT_H2I_ENABLE_RX_VF_TAG_REQ = (6),
+	BFI_PPORT_H2I_ENABLE_TX_VF_TAG_REQ = (7),
+	BFI_PPORT_H2I_GET_QOS_STATS_REQ = (8),
+	BFI_PPORT_H2I_CLEAR_QOS_STATS_REQ = (9),
+};
+
+enum bfi_pport_i2h {
+	BFI_PPORT_I2H_ENABLE_RSP = BFA_I2HM(1),
+	BFI_PPORT_I2H_DISABLE_RSP = BFA_I2HM(2),
+	BFI_PPORT_I2H_GET_STATS_RSP = BFA_I2HM(3),
+	BFI_PPORT_I2H_CLEAR_STATS_RSP = BFA_I2HM(4),
+	BFI_PPORT_I2H_SET_SVC_PARAMS_RSP = BFA_I2HM(5),
+	BFI_PPORT_I2H_ENABLE_RX_VF_TAG_RSP = BFA_I2HM(6),
+	BFI_PPORT_I2H_ENABLE_TX_VF_TAG_RSP = BFA_I2HM(7),
+	BFI_PPORT_I2H_EVENT = BFA_I2HM(8),
+	BFI_PPORT_I2H_GET_QOS_STATS_RSP = BFA_I2HM(9),
+	BFI_PPORT_I2H_CLEAR_QOS_STATS_RSP = BFA_I2HM(10),
+};
+
+/**
+ * Generic REQ type
+ */
+struct bfi_pport_generic_req_s {
+	struct bfi_mhdr_s mh;	/*  msg header                      */
+	u32 msgtag;		/*  msgtag for reply                */
+};
+
+/**
+ * Generic RSP type
+ */
+struct bfi_pport_generic_rsp_s {
+	struct bfi_mhdr_s mh;	/*  common msg header               */
+	u8 status;		/*  port enable status              */
+	u8 rsvd[3];
+	u32 msgtag;		/*  msgtag for reply                */
+};
+
+/**
+ * BFI_PPORT_H2I_ENABLE_REQ
+ */
+struct bfi_pport_enable_req_s {
+	struct bfi_mhdr_s mh;	/*  msg header                      */
+	u32 rsvd1;
+	wwn_t nwwn;		/*  node wwn of physical port       */
+	wwn_t pwwn;		/*  port wwn of physical port       */
+	struct bfa_pport_cfg_s port_cfg;	/*  port configuration      */
+	union bfi_addr_u stats_dma_addr;	/*  DMA address for stats  */
+	u32 msgtag;		/*  msgtag for reply                */
+	u32 rsvd2;
+};
+
+/**
+ * BFI_PPORT_I2H_ENABLE_RSP
+ */
+#define bfi_pport_enable_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_DISABLE_REQ
+ */
+#define bfi_pport_disable_req_t struct bfi_pport_generic_req_s
+
+/**
+ * BFI_PPORT_I2H_DISABLE_RSP
+ */
+#define bfi_pport_disable_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_GET_STATS_REQ
+ */
+#define bfi_pport_get_stats_req_t struct bfi_pport_generic_req_s
+
+/**
+ * BFI_PPORT_I2H_GET_STATS_RSP
+ */
+#define bfi_pport_get_stats_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_CLEAR_STATS_REQ
+ */
+#define bfi_pport_clear_stats_req_t struct bfi_pport_generic_req_s
+
+/**
+ * BFI_PPORT_I2H_CLEAR_STATS_RSP
+ */
+#define bfi_pport_clear_stats_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_GET_QOS_STATS_REQ
+ */
+#define bfi_pport_get_qos_stats_req_t struct bfi_pport_generic_req_s
+
+/**
+ * BFI_PPORT_H2I_GET_QOS_STATS_RSP
+ */
+#define bfi_pport_get_qos_stats_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_CLEAR_QOS_STATS_REQ
+ */
+#define bfi_pport_clear_qos_stats_req_t struct bfi_pport_generic_req_s
+
+/**
+ * BFI_PPORT_H2I_CLEAR_QOS_STATS_RSP
+ */
+#define bfi_pport_clear_qos_stats_rsp_t struct bfi_pport_generic_rsp_s
+
+/**
+ * BFI_PPORT_H2I_SET_SVC_PARAMS_REQ
+ */
+struct bfi_pport_set_svc_params_req_s {
+	struct bfi_mhdr_s mh;	/*  msg header */
+	u16 tx_bbcredit;	/*  Tx credits */
+	u16 rsvd;
+};
+
+/**
+ * BFI_PPORT_I2H_SET_SVC_PARAMS_RSP
+ */
+
+/**
+ * BFI_PPORT_I2H_EVENT
+ */
+struct bfi_pport_event_s {
+	struct bfi_mhdr_s mh;	/*  common msg header */
+	struct bfa_pport_link_s link_state;
+};
+
+union bfi_pport_h2i_msg_u {
+	struct bfi_mhdr_s *mhdr;
+	struct bfi_pport_enable_req_s *penable;
+	struct bfi_pport_generic_req_s *pdisable;
+	struct bfi_pport_generic_req_s *pgetstats;
+	struct bfi_pport_generic_req_s *pclearstats;
+	struct bfi_pport_set_svc_params_req_s *psetsvcparams;
+	struct bfi_pport_get_qos_stats_req_s *pgetqosstats;
+	struct bfi_pport_generic_req_s *pclearqosstats;
+};
+
+union bfi_pport_i2h_msg_u {
+	struct bfi_msg_s *msg;
+	struct bfi_pport_generic_rsp_s *enable_rsp;
+	struct bfi_pport_disable_rsp_s *disable_rsp;
+	struct bfi_pport_generic_rsp_s *getstats_rsp;
+	struct bfi_pport_clear_stats_rsp_s *clearstats_rsp;
+	struct bfi_pport_set_svc_params_rsp_s *setsvcparasm_rsp;
+	struct bfi_pport_get_qos_stats_rsp_s *getqosstats_rsp;
+	struct bfi_pport_clear_qos_stats_rsp_s *clearqosstats_rsp;
+	struct bfi_pport_event_s *event;
+};
+
+#pragma pack()
+
+#endif /* __BFI_PPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_uf.h linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_uf.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/bfi/bfi_uf.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/bfi/bfi_uf.h	2009-08-28 21:09:29.852401000 -0700
@@ -0,0 +1,59 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_UF_H__
+#define __BFI_UF_H__
+
+#include "bfi.h"
+
+#pragma pack(1)
+
+enum bfi_uf_h2i {
+	BFI_UF_H2I_BUF_POST = 1,
+};
+
+enum bfi_uf_i2h {
+	BFI_UF_I2H_FRM_RCVD = BFA_I2HM(1),
+};
+
+#define BFA_UF_MAX_SGES	2
+
+struct bfi_uf_buf_post_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header           */
+	u16 buf_tag;		/*  buffer tag                  */
+	u16 buf_len;		/*  total buffer length */
+	struct bfi_sge_s sge[BFA_UF_MAX_SGES];	/*  buffer DMA SGEs    */
+};
+
+struct bfi_uf_frm_rcvd_s {
+	struct bfi_mhdr_s mh;	/*  Common msg header           */
+	u16 buf_tag;		/*  buffer tag                  */
+	u16 rsvd;
+	u16 frm_len;		/*  received frame length       */
+	u16 xfr_len;		/*  tranferred length           */
+};
+
+#pragma pack()
+
+#endif /* __BFI_UF_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cee/bfa_cee.h linux-2.6.30.5-mod/drivers/net/bna/include/cee/bfa_cee.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cee/bfa_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cee/bfa_cee.h	2009-08-28 21:09:29.249469000 -0700
@@ -0,0 +1,82 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_CEE_H__
+#define __BFA_CEE_H__
+
+#include <defs/bfa_defs_cee.h>
+#include <bfa_ioc.h>
+#include <cs/bfa_trc.h>
+#include <cs/bfa_log.h>
+
+typedef void (*bfa_cee_get_attr_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_get_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_reset_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_hbfail_cbfn_t) (void *dev, bfa_status_t status);
+
+struct bfa_cee_cbfn_s {
+	bfa_cee_get_attr_cbfn_t get_attr_cbfn;
+	void *get_attr_cbarg;
+	bfa_cee_get_stats_cbfn_t get_stats_cbfn;
+	void *get_stats_cbarg;
+	bfa_cee_reset_stats_cbfn_t reset_stats_cbfn;
+	void *reset_stats_cbarg;
+};
+
+struct bfa_cee_s {
+	void *dev;
+	bfa_boolean_t get_attr_pending;
+	bfa_boolean_t get_stats_pending;
+	bfa_boolean_t reset_stats_pending;
+	bfa_status_t get_attr_status;
+	bfa_status_t get_stats_status;
+	bfa_status_t reset_stats_status;
+	struct bfa_cee_cbfn_s cbfn;
+	struct bfa_ioc_hbfail_notify_s hbfail;
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_cee_attr_s *attr;
+	struct bfa_cee_stats_s *stats;
+	struct bfa_dma_s attr_dma;
+	struct bfa_dma_s stats_dma;
+	struct bfa_ioc_s *ioc;
+	struct bfa_mbox_cmd_s get_cfg_mb;
+	struct bfa_mbox_cmd_s get_stats_mb;
+	struct bfa_mbox_cmd_s reset_stats_mb;
+};
+
+u32 bfa_cee_meminfo(void);
+void bfa_cee_mem_claim(struct bfa_cee_s *cee, u8 * dma_kva, u64 dma_pa);
+void bfa_cee_attach(struct bfa_cee_s *cee, struct bfa_ioc_s *ioc, void *dev,
+		    struct bfa_trc_mod_s *trcmod, struct bfa_log_mod_s *logmod);
+void bfa_cee_detach(struct bfa_cee_s *cee);
+bfa_status_t bfa_cee_get_attr(struct bfa_cee_s *cee,
+			      struct bfa_cee_attr_s *attr,
+			      bfa_cee_get_attr_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_get_stats(struct bfa_cee_s *cee,
+			       struct bfa_cee_stats_s *stats,
+			       bfa_cee_get_stats_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_reset_stats(struct bfa_cee_s *cee,
+				 bfa_cee_reset_stats_cbfn_t cbfn, void *cbarg);
+#endif /* __BFA_CEE_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/bfa_cee.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/bfa_cee.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/bfa_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/bfa_cee.h	2009-08-28 21:09:30.139410000 -0700
@@ -0,0 +1,82 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_CEE_H__
+#define __BFA_CEE_H__
+
+#include <defs/bfa_defs_cee.h>
+#include <bfa_ioc.h>
+#include <cs/bfa_trc.h>
+#include <cs/bfa_log.h>
+
+typedef void (*bfa_cee_get_attr_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_get_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_reset_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_hbfail_cbfn_t) (void *dev, bfa_status_t status);
+
+struct bfa_cee_cbfn_s {
+	bfa_cee_get_attr_cbfn_t get_attr_cbfn;
+	void *get_attr_cbarg;
+	bfa_cee_get_stats_cbfn_t get_stats_cbfn;
+	void *get_stats_cbarg;
+	bfa_cee_reset_stats_cbfn_t reset_stats_cbfn;
+	void *reset_stats_cbarg;
+};
+
+struct bfa_cee_s {
+	void *dev;
+	bfa_boolean_t get_attr_pending;
+	bfa_boolean_t get_stats_pending;
+	bfa_boolean_t reset_stats_pending;
+	bfa_status_t get_attr_status;
+	bfa_status_t get_stats_status;
+	bfa_status_t reset_stats_status;
+	struct bfa_cee_cbfn_s cbfn;
+	struct bfa_ioc_hbfail_notify_s hbfail;
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_cee_attr_s *attr;
+	struct bfa_cee_stats_s *stats;
+	struct bfa_dma_s attr_dma;
+	struct bfa_dma_s stats_dma;
+	struct bfa_ioc_s *ioc;
+	struct bfa_mbox_cmd_s get_cfg_mb;
+	struct bfa_mbox_cmd_s get_stats_mb;
+	struct bfa_mbox_cmd_s reset_stats_mb;
+};
+
+u32 bfa_cee_meminfo(void);
+void bfa_cee_mem_claim(struct bfa_cee_s *cee, u8 * dma_kva, u64 dma_pa);
+void bfa_cee_attach(struct bfa_cee_s *cee, struct bfa_ioc_s *ioc, void *dev,
+		    struct bfa_trc_mod_s *trcmod, struct bfa_log_mod_s *logmod);
+void bfa_cee_detach(struct bfa_cee_s *cee);
+bfa_status_t bfa_cee_get_attr(struct bfa_cee_s *cee,
+			      struct bfa_cee_attr_s *attr,
+			      bfa_cee_get_attr_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_get_stats(struct bfa_cee_s *cee,
+			       struct bfa_cee_stats_s *stats,
+			       bfa_cee_get_stats_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_reset_stats(struct bfa_cee_s *cee,
+				 bfa_cee_reset_stats_cbfn_t cbfn, void *cbarg);
+#endif /* __BFA_CEE_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/bfa_cna_trcmod.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/bfa_cna_trcmod.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/bfa_cna_trcmod.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/bfa_cna_trcmod.h	2009-08-28 21:09:30.057403000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_cna_trcmod.h CNA trace modules
+ */
+
+#ifndef __BFA_CNA_TRCMOD_H__
+#define __BFA_CNA_TRCMOD_H__
+
+#include <cs/bfa_trc.h>
+
+/*
+ * !!! Only append to the enums defined here to avoid any versioning
+ * !!! needed between trace utility and driver version
+ */
+enum {
+	BFA_TRC_CNA_CEE = 1,
+	BFA_TRC_CNA_PORT = 2,
+};
+
+#endif /* __BFA_CNA_TRCMOD_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/cee_cli.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/cee_cli.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/cee_cli.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/cee_cli.h	2009-08-28 21:09:29.951404000 -0700
@@ -0,0 +1,32 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ *      Copyright (c) 2007-2009 Brocade Communications Systems, Inc.
+ *      All rights reserved.
+ *
+ *      @file cee_cli.h CEE common header file for CLI data parsing APIs.
+ */
+
+#ifndef __CEE_CLI_H__
+#define __CEE_CLI_H__
+
+#include <defs/bfa_defs_cee.h>
+
+void cee_cli_format_cee_stats(void *buffer);
+void cee_cli_format_cee_cfg(void *buffer);
+
+#endif /* __CEE_CLI_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/ethport_defs.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/ethport_defs.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/ethport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/ethport_defs.h	2009-08-28 21:09:30.032407000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __ETHPORT_DEFS_H__
+#define __ETHPORT_DEFS_H__
+
+struct bnad_drv_stats {
+	u64 netif_queue_stop;
+	u64 netif_queue_wakeup;
+	u64 tso4;
+	u64 tso6;
+	u64 tso_err;
+	u64 tcpcsum_offload;
+	u64 udpcsum_offload;
+	u64 csum_help;
+	u64 csum_help_err;
+
+	u64 hw_stats_updates;
+	u64 netif_rx_schedule;
+	u64 netif_rx_complete;
+	u64 netif_rx_dropped;
+};
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/phyport_defs.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/phyport_defs.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/phyport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/phyport_defs.h	2009-08-28 21:09:30.124405000 -0700
@@ -0,0 +1,225 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __PHYPORT_DEFS_H__
+#define __PHYPORT_DEFS_H__
+
+#define BNA_TXF_ID_MAX  	64
+#define BNA_RXF_ID_MAX  	64
+
+/*
+ * Statistics
+ */
+
+/*
+ * TxF Frame Statistics
+ */
+struct bna_stats_txf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+
+	u64 errors;
+	u64 filter_vlan;	/* frames filtered due to VLAN */
+	u64 filter_mac_sa;	/* frames filtered due to SA check */
+};
+
+/*
+ * RxF Frame Statistics
+ */
+struct bna_stats_rxf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+	u64 frame_drops;
+};
+
+/*
+ * FC Tx Frame Statistics
+ */
+struct bna_stats_fc_tx {
+	u64 txf_ucast_octets;
+	u64 txf_ucast;
+	u64 txf_ucast_vlan;
+
+	u64 txf_mcast_octets;
+	u64 txf_mcast;
+	u64 txf_mcast_vlan;
+
+	u64 txf_bcast_octets;
+	u64 txf_bcast;
+	u64 txf_bcast_vlan;
+
+	u64 txf_parity_errors;
+	u64 txf_timeout;
+	u64 txf_fid_parity_errors;
+};
+
+/*
+ * FC Rx Frame Statistics
+ */
+struct bna_stats_fc_rx {
+	u64 rxf_ucast_octets;
+	u64 rxf_ucast;
+	u64 rxf_ucast_vlan;
+
+	u64 rxf_mcast_octets;
+	u64 rxf_mcast;
+	u64 rxf_mcast_vlan;
+
+	u64 rxf_bcast_octets;
+	u64 rxf_bcast;
+	u64 rxf_bcast_vlan;
+};
+
+/*
+ * RAD Frame Statistics
+ */
+struct cna_stats_rad {
+	u64 rx_frames;
+	u64 rx_octets;
+	u64 rx_vlan_frames;
+
+	u64 rx_ucast;
+	u64 rx_ucast_octets;
+	u64 rx_ucast_vlan;
+
+	u64 rx_mcast;
+	u64 rx_mcast_octets;
+	u64 rx_mcast_vlan;
+
+	u64 rx_bcast;
+	u64 rx_bcast_octets;
+	u64 rx_bcast_vlan;
+
+	u64 rx_drops;
+};
+
+/*
+ * BPC Tx Registers
+ */
+struct cna_stats_bpc_tx {
+	u64 tx_pause[8];
+	u64 tx_zero_pause[8];	/*  Pause cancellation */
+	u64 tx_first_pause[8];	/*  Pause initiation rather
+				 *than retention */
+};
+
+/*
+ * BPC Rx Registers
+ */
+struct cna_stats_bpc_rx {
+	u64 rx_pause[8];
+	u64 rx_zero_pause[8];	/*  Pause cancellation */
+	u64 rx_first_pause[8];	/*  Pause initiation rather
+				 *than retention */
+};
+
+/*
+ * MAC Rx Statistics
+ */
+struct cna_stats_mac_rx {
+	u64 frame_64;		/* both rx and tx counter */
+	u64 frame_65_127;	/* both rx and tx counter */
+	u64 frame_128_255;	/* both rx and tx counter */
+	u64 frame_256_511;	/* both rx and tx counter */
+	u64 frame_512_1023;	/* both rx and tx counter */
+	u64 frame_1024_1518;	/* both rx and tx counter */
+	u64 frame_1518_1522;	/* both rx and tx counter */
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_fcs_error;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_control_frames;
+	u64 rx_pause;
+	u64 rx_unknown_opcode;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_carrier_sense_error;
+	u64 rx_undersize;
+	u64 rx_oversize;
+	u64 rx_fragments;
+	u64 rx_jabber;
+	u64 rx_drop;
+};
+
+/*
+ * MAC Tx Statistics
+ */
+struct cna_stats_mac_tx {
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_pause;
+	u64 tx_deferral;
+	u64 tx_excessive_deferral;
+	u64 tx_single_collision;
+	u64 tx_muliple_collision;
+	u64 tx_late_collision;
+	u64 tx_excessive_collision;
+	u64 tx_total_collision;
+	u64 tx_pause_honored;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_control_frame;
+	u64 tx_oversize;
+	u64 tx_undersize;
+	u64 tx_fragments;
+};
+
+/*
+ * Complete statistics
+ */
+struct bna_stats {
+	struct cna_stats_mac_rx mac_rx_stats;
+	struct cna_stats_bpc_rx bpc_rx_stats;
+	struct cna_stats_rad rad_stats;
+	struct bna_stats_fc_rx fc_rx_stats;
+	struct cna_stats_mac_tx mac_tx_stats;
+	struct cna_stats_bpc_tx bpc_tx_stats;
+	struct bna_stats_fc_tx fc_tx_stats;
+	struct bna_stats_rxf rxf_stats[BNA_TXF_ID_MAX];
+	struct bna_stats_txf txf_stats[BNA_RXF_ID_MAX];
+};
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/pstats/ethport_defs.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/pstats/ethport_defs.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/pstats/ethport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/pstats/ethport_defs.h	2009-08-28 21:09:29.976406000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __ETHPORT_DEFS_H__
+#define __ETHPORT_DEFS_H__
+
+struct bnad_drv_stats {
+	u64 netif_queue_stop;
+	u64 netif_queue_wakeup;
+	u64 tso4;
+	u64 tso6;
+	u64 tso_err;
+	u64 tcpcsum_offload;
+	u64 udpcsum_offload;
+	u64 csum_help;
+	u64 csum_help_err;
+
+	u64 hw_stats_updates;
+	u64 netif_rx_schedule;
+	u64 netif_rx_complete;
+	u64 netif_rx_dropped;
+};
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cna/pstats/phyport_defs.h linux-2.6.30.5-mod/drivers/net/bna/include/cna/pstats/phyport_defs.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cna/pstats/phyport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cna/pstats/phyport_defs.h	2009-08-28 21:09:30.007400000 -0700
@@ -0,0 +1,225 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __PHYPORT_DEFS_H__
+#define __PHYPORT_DEFS_H__
+
+#define BNA_TXF_ID_MAX  	64
+#define BNA_RXF_ID_MAX  	64
+
+/*
+ * Statistics
+ */
+
+/*
+ * TxF Frame Statistics
+ */
+struct bna_stats_txf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+
+	u64 errors;
+	u64 filter_vlan;	/* frames filtered due to VLAN */
+	u64 filter_mac_sa;	/* frames filtered due to SA check */
+};
+
+/*
+ * RxF Frame Statistics
+ */
+struct bna_stats_rxf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+	u64 frame_drops;
+};
+
+/*
+ * FC Tx Frame Statistics
+ */
+struct bna_stats_fc_tx {
+	u64 txf_ucast_octets;
+	u64 txf_ucast;
+	u64 txf_ucast_vlan;
+
+	u64 txf_mcast_octets;
+	u64 txf_mcast;
+	u64 txf_mcast_vlan;
+
+	u64 txf_bcast_octets;
+	u64 txf_bcast;
+	u64 txf_bcast_vlan;
+
+	u64 txf_parity_errors;
+	u64 txf_timeout;
+	u64 txf_fid_parity_errors;
+};
+
+/*
+ * FC Rx Frame Statistics
+ */
+struct bna_stats_fc_rx {
+	u64 rxf_ucast_octets;
+	u64 rxf_ucast;
+	u64 rxf_ucast_vlan;
+
+	u64 rxf_mcast_octets;
+	u64 rxf_mcast;
+	u64 rxf_mcast_vlan;
+
+	u64 rxf_bcast_octets;
+	u64 rxf_bcast;
+	u64 rxf_bcast_vlan;
+};
+
+/*
+ * RAD Frame Statistics
+ */
+struct cna_stats_rad {
+	u64 rx_frames;
+	u64 rx_octets;
+	u64 rx_vlan_frames;
+
+	u64 rx_ucast;
+	u64 rx_ucast_octets;
+	u64 rx_ucast_vlan;
+
+	u64 rx_mcast;
+	u64 rx_mcast_octets;
+	u64 rx_mcast_vlan;
+
+	u64 rx_bcast;
+	u64 rx_bcast_octets;
+	u64 rx_bcast_vlan;
+
+	u64 rx_drops;
+};
+
+/*
+ * BPC Tx Registers
+ */
+struct cna_stats_bpc_tx {
+	u64 tx_pause[8];
+	u64 tx_zero_pause[8];	/*  Pause cancellation */
+	u64 tx_first_pause[8];	/*  Pause initiation rather
+				 *than retention */
+};
+
+/*
+ * BPC Rx Registers
+ */
+struct cna_stats_bpc_rx {
+	u64 rx_pause[8];
+	u64 rx_zero_pause[8];	/*  Pause cancellation */
+	u64 rx_first_pause[8];	/*  Pause initiation rather
+				 *than retention */
+};
+
+/*
+ * MAC Rx Statistics
+ */
+struct cna_stats_mac_rx {
+	u64 frame_64;		/* both rx and tx counter */
+	u64 frame_65_127;	/* both rx and tx counter */
+	u64 frame_128_255;	/* both rx and tx counter */
+	u64 frame_256_511;	/* both rx and tx counter */
+	u64 frame_512_1023;	/* both rx and tx counter */
+	u64 frame_1024_1518;	/* both rx and tx counter */
+	u64 frame_1518_1522;	/* both rx and tx counter */
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_fcs_error;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_control_frames;
+	u64 rx_pause;
+	u64 rx_unknown_opcode;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_carrier_sense_error;
+	u64 rx_undersize;
+	u64 rx_oversize;
+	u64 rx_fragments;
+	u64 rx_jabber;
+	u64 rx_drop;
+};
+
+/*
+ * MAC Tx Statistics
+ */
+struct cna_stats_mac_tx {
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_pause;
+	u64 tx_deferral;
+	u64 tx_excessive_deferral;
+	u64 tx_single_collision;
+	u64 tx_muliple_collision;
+	u64 tx_late_collision;
+	u64 tx_excessive_collision;
+	u64 tx_total_collision;
+	u64 tx_pause_honored;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_control_frame;
+	u64 tx_oversize;
+	u64 tx_undersize;
+	u64 tx_fragments;
+};
+
+/*
+ * Complete statistics
+ */
+struct bna_stats {
+	struct cna_stats_mac_rx mac_rx_stats;
+	struct cna_stats_bpc_rx bpc_rx_stats;
+	struct cna_stats_rad rad_stats;
+	struct bna_stats_fc_rx fc_rx_stats;
+	struct cna_stats_mac_tx mac_tx_stats;
+	struct cna_stats_bpc_tx bpc_tx_stats;
+	struct bna_stats_fc_tx fc_tx_stats;
+	struct bna_stats_rxf rxf_stats[BNA_TXF_ID_MAX];
+	struct bna_stats_txf txf_stats[BNA_RXF_ID_MAX];
+};
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_debug.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_debug.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_debug.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_debug.h	2009-08-28 21:09:29.101477000 -0700
@@ -0,0 +1,51 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_debug.h BFA debug interfaces
+ */
+
+#ifndef __BFA_DEBUG_H__
+#define __BFA_DEBUG_H__
+
+#define bfa_assert(__cond)	do {					\
+	if (!(__cond)) 							\
+		bfa_panic(__LINE__, __FILE__, #__cond);      \
+} while (0)
+
+#define bfa_sm_fault(__mod, __event)	do {				\
+	bfa_sm_panic((__mod)->logm, __LINE__, __FILE__, __event);      \
+} while (0)
+
+#ifndef BFA_PERF_BUILD
+#define bfa_assert_fp(__cond)	bfa_assert(__cond)
+#else
+#define bfa_assert_fp(__cond)
+#endif
+
+struct bfa_log_mod_s;
+void bfa_panic(int line, char *file, char *panicstr);
+void bfa_sm_panic(struct bfa_log_mod_s *logm, int line, char *file, int event);
+
+#endif /* __BFA_DEBUG_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_log.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_log.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_log.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_log.h	2009-08-28 21:09:29.196469000 -0700
@@ -0,0 +1,192 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_log.h BFA log library data structure and function definition
+ */
+
+#ifndef __BFA_LOG_H__
+#define __BFA_LOG_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_status.h>
+#include <defs/bfa_defs_aen.h>
+
+/*
+ * BFA log module definition
+ *
+ * To create a new module id:
+ * Add a #define at the end of the list below. Select a value for your
+ * definition so that it is one (1) greater than the previous
+ * definition. Modify the definition of BFA_LOG_MODULE_ID_MAX to become
+ * your new definition.
+ * Should have no gaps in between the values because this is used in arrays.
+ * IMPORTANT: AEN_IDs must be at the begining, otherwise update bfa_defs_aen.h
+ */
+
+enum bfa_log_module_id {
+	BFA_LOG_UNUSED_ID = 0,
+
+	/* AEN defs begin */
+	BFA_LOG_AEN_MIN = BFA_LOG_UNUSED_ID,
+
+	BFA_LOG_AEN_ID_ADAPTER = BFA_LOG_AEN_MIN + BFA_AEN_CAT_ADAPTER,	/* 1 */
+	BFA_LOG_AEN_ID_PORT = BFA_LOG_AEN_MIN + BFA_AEN_CAT_PORT,	/* 2 */
+	BFA_LOG_AEN_ID_LPORT = BFA_LOG_AEN_MIN + BFA_AEN_CAT_LPORT,	/* 3 */
+	BFA_LOG_AEN_ID_RPORT = BFA_LOG_AEN_MIN + BFA_AEN_CAT_RPORT,	/* 4 */
+	BFA_LOG_AEN_ID_ITNIM = BFA_LOG_AEN_MIN + BFA_AEN_CAT_ITNIM,	/* 5 */
+	BFA_LOG_AEN_ID_TIN = BFA_LOG_AEN_MIN + BFA_AEN_CAT_TIN,	/* 6 */
+	BFA_LOG_AEN_ID_IPFC = BFA_LOG_AEN_MIN + BFA_AEN_CAT_IPFC,	/* 7 */
+	BFA_LOG_AEN_ID_AUDIT = BFA_LOG_AEN_MIN + BFA_AEN_CAT_AUDIT,	/* 8 */
+	BFA_LOG_AEN_ID_IOC = BFA_LOG_AEN_MIN + BFA_AEN_CAT_IOC,	/* 9 */
+	BFA_LOG_AEN_ID_ETHPORT = BFA_LOG_AEN_MIN + BFA_AEN_CAT_ETHPORT,	/* 10 */
+
+	BFA_LOG_AEN_MAX = BFA_LOG_AEN_ID_ETHPORT,
+	/* AEN defs end */
+
+	BFA_LOG_MODULE_ID_MIN = BFA_LOG_AEN_MAX,
+
+	BFA_LOG_FW_ID = BFA_LOG_MODULE_ID_MIN + 1,
+	BFA_LOG_HAL_ID = BFA_LOG_MODULE_ID_MIN + 2,
+	BFA_LOG_FCS_ID = BFA_LOG_MODULE_ID_MIN + 3,
+	BFA_LOG_WDRV_ID = BFA_LOG_MODULE_ID_MIN + 4,
+	BFA_LOG_LINUX_ID = BFA_LOG_MODULE_ID_MIN + 5,
+	BFA_LOG_SOLARIS_ID = BFA_LOG_MODULE_ID_MIN + 6,
+
+	BFA_LOG_MODULE_ID_MAX = BFA_LOG_SOLARIS_ID,
+
+	/* Not part of any arrays */
+	BFA_LOG_MODULE_ID_ALL = BFA_LOG_MODULE_ID_MAX + 1,
+	BFA_LOG_AEN_ALL = BFA_LOG_MODULE_ID_MAX + 2,
+	BFA_LOG_DRV_ALL = BFA_LOG_MODULE_ID_MAX + 3,
+};
+
+/*
+ * BFA log catalog name
+ */
+#define BFA_LOG_CAT_NAME	"BFA"
+
+/*
+ * bfa log severity values
+ */
+enum bfa_log_severity {
+	BFA_LOG_INVALID = 0,
+	BFA_LOG_CRITICAL = 1,
+	BFA_LOG_ERROR = 2,
+	BFA_LOG_WARNING = 3,
+	BFA_LOG_INFO = 4,
+	BFA_LOG_NONE = 5,
+	BFA_LOG_LEVEL_MAX = BFA_LOG_NONE
+};
+
+#define BFA_LOG_MODID_OFFSET		16
+
+
+struct bfa_log_msgdef_s {
+	u32 msg_id;		/*  message id */
+	int attributes;		/*  attributes */
+	int severity;		/*  severity level */
+	char *msg_value;
+	/*  msg string */
+	char *message;
+	/*  msg format string */
+	int arg_type;		/*  argument type */
+	int arg_num;		/*  number of argument */
+};
+
+/*
+ * supported argument type
+ */
+enum bfa_log_arg_type {
+	BFA_LOG_S = 0,		/*  string */
+	BFA_LOG_D,		/*  decimal */
+	BFA_LOG_I,		/*  integer */
+	BFA_LOG_O,		/*  oct number */
+	BFA_LOG_U,		/*  unsigned integer */
+	BFA_LOG_X,		/*  hex number */
+	BFA_LOG_F,		/*  floating */
+	BFA_LOG_C,		/*  character */
+	BFA_LOG_L,		/*  double */
+	BFA_LOG_P		/*  pointer */
+};
+
+#define BFA_LOG_ARG_TYPE	2
+#define BFA_LOG_ARG0		(0 * BFA_LOG_ARG_TYPE)
+#define BFA_LOG_ARG1		(1 * BFA_LOG_ARG_TYPE)
+#define BFA_LOG_ARG2		(2 * BFA_LOG_ARG_TYPE)
+#define BFA_LOG_ARG3		(3 * BFA_LOG_ARG_TYPE)
+
+#define BFA_LOG_GET_MOD_ID(msgid) ((msgid >> BFA_LOG_MODID_OFFSET) & 0xff)
+#define BFA_LOG_GET_MSG_IDX(msgid) (msgid & 0xffff)
+#define BFA_LOG_GET_MSG_ID(msgdef) ((msgdef)->msg_id)
+#define BFA_LOG_GET_MSG_FMT_STRING(msgdef) ((msgdef)->message)
+#define BFA_LOG_GET_SEVERITY(msgdef) ((msgdef)->severity)
+
+/*
+ * Event attributes
+ */
+#define BFA_LOG_ATTR_NONE	0
+#define BFA_LOG_ATTR_AUDIT	1
+#define BFA_LOG_ATTR_LOG	2
+#define BFA_LOG_ATTR_FFDC	4
+
+#define BFA_LOG_CREATE_ID(msw, lsw) \
+	(((u32)msw << BFA_LOG_MODID_OFFSET) | lsw)
+
+struct bfa_log_mod_s;
+
+/**
+ * callback function
+ */
+typedef void (*bfa_log_cb_t) (struct bfa_log_mod_s * log_mod, u32 msg_id,
+			      const char *format, ...);
+
+
+struct bfa_log_mod_s {
+	char instance_info[16];	/*  instance info */
+	int log_level[BFA_LOG_MODULE_ID_MAX + 1];
+	/*  log level for modules */
+	bfa_log_cb_t cbfn;	/*  callback function */
+};
+
+extern int bfa_log_init(struct bfa_log_mod_s *log_mod,
+			char *instance_name, bfa_log_cb_t cbfn);
+extern int bfa_log(struct bfa_log_mod_s *log_mod, u32 msg_id, ...);
+extern bfa_status_t bfa_log_set_level(struct bfa_log_mod_s *log_mod,
+				      int mod_id,
+				      enum bfa_log_severity log_level);
+extern bfa_status_t bfa_log_set_level_all(struct bfa_log_mod_s *log_mod,
+					  enum bfa_log_severity log_level);
+extern bfa_status_t bfa_log_set_level_aen(struct bfa_log_mod_s *log_mod,
+					  enum bfa_log_severity log_level);
+extern enum bfa_log_severity bfa_log_get_level(struct bfa_log_mod_s *log_mod,
+					       int mod_id);
+extern enum bfa_log_severity bfa_log_get_msg_level(struct bfa_log_mod_s
+						   *log_mod, u32 msg_id);
+/*
+ * array of messages generated from xml files
+ */
+extern struct bfa_log_msgdef_s bfa_log_msg_array[];
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_plog.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_plog.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_plog.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_plog.h	2009-08-28 21:09:29.135468000 -0700
@@ -0,0 +1,168 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_PORTLOG_H__
+#define __BFA_PORTLOG_H__
+
+#include "protocol/fc.h"
+#include <defs/bfa_defs_types.h>
+
+#define BFA_PL_NLOG_ENTS 256
+#define BFA_PL_LOG_REC_INCR(_x) ((_x)++, (_x) %= BFA_PL_NLOG_ENTS)
+
+#define BFA_PL_STRING_LOG_SZ   32	/* number of chars in string log */
+#define BFA_PL_INT_LOG_SZ      8	/* number of integers in the integer log */
+
+enum bfa_plog_log_type {
+	BFA_PL_LOG_TYPE_INVALID = 0,
+	BFA_PL_LOG_TYPE_INT = 1,
+	BFA_PL_LOG_TYPE_STRING = 2,
+};
+
+/*
+ * the (fixed size) record format for each entry in the portlog
+ */
+struct bfa_plog_rec_s {
+	u32 tv;			/* Filled by the portlog driver when the *
+				 * entry is added to the circular log.   */
+	u8 port;		/* Source port that logged this entry. CM
+				 * entities will use 0xFF */
+	u8 mid;			/* Integer value to be used by all entities *
+				 * while logging. The module id to string   *
+				 * conversion will be done by BFAL. See
+				 * enum bfa_plog_mid */
+	u8 eid;			/* indicates Rx, Tx, IOCTL, etc. See
+				 * enum bfa_plog_eid */
+	u8 log_type;		/* indicates string log or integer log.
+				 * see bfa_plog_log_type_t */
+	u8 log_num_ints;
+	/*
+	 * interpreted only if log_type is INT_LOG. indicates number of
+	 * integers in the int_log[] (0-PL_INT_LOG_SZ).
+	 */
+	u8 rsvd;
+	u16 misc;		/* can be used to indicate fc frame length,
+				 *etc.. */
+	union {
+		char string_log[BFA_PL_STRING_LOG_SZ];
+		u32 int_log[BFA_PL_INT_LOG_SZ];
+	} log_entry;
+
+};
+
+/*
+ * the following #defines will be used by the logging entities to indicate
+ * their module id. BFAL will convert the integer value to string format
+ *
+* process to be used while changing the following #defines:
+ *  - Always add new entries at the end
+ *  - define corresponding string in BFAL
+ *  - Do not remove any entry or rearrange the order.
+ */
+enum bfa_plog_mid {
+	BFA_PL_MID_INVALID = 0,
+	BFA_PL_MID_DEBUG = 1,
+	BFA_PL_MID_DRVR = 2,
+	BFA_PL_MID_HAL = 3,
+	BFA_PL_MID_HAL_FCXP = 4,
+	BFA_PL_MID_HAL_UF = 5,
+	BFA_PL_MID_FCS = 6,
+	BFA_PL_MID_MAX = 7
+};
+
+#define BFA_PL_MID_STRLEN    8
+struct bfa_plog_mid_strings_s {
+	char m_str[BFA_PL_MID_STRLEN];
+};
+
+/*
+ * the following #defines will be used by the logging entities to indicate
+ * their event type. BFAL will convert the integer value to string format
+ *
+* process to be used while changing the following #defines:
+ *  - Always add new entries at the end
+ *  - define corresponding string in BFAL
+ *  - Do not remove any entry or rearrange the order.
+ */
+enum bfa_plog_eid {
+	BFA_PL_EID_INVALID = 0,
+	BFA_PL_EID_IOC_DISABLE = 1,
+	BFA_PL_EID_IOC_ENABLE = 2,
+	BFA_PL_EID_PORT_DISABLE = 3,
+	BFA_PL_EID_PORT_ENABLE = 4,
+	BFA_PL_EID_PORT_ST_CHANGE = 5,
+	BFA_PL_EID_TX = 6,
+	BFA_PL_EID_TX_ACK1 = 7,
+	BFA_PL_EID_TX_RJT = 8,
+	BFA_PL_EID_TX_BSY = 9,
+	BFA_PL_EID_RX = 10,
+	BFA_PL_EID_RX_ACK1 = 11,
+	BFA_PL_EID_RX_RJT = 12,
+	BFA_PL_EID_RX_BSY = 13,
+	BFA_PL_EID_CT_IN = 14,
+	BFA_PL_EID_CT_OUT = 15,
+	BFA_PL_EID_DRIVER_START = 16,
+	BFA_PL_EID_RSCN = 17,
+	BFA_PL_EID_DEBUG = 18,
+	BFA_PL_EID_MISC = 19,
+	BFA_PL_EID_MAX = 20
+};
+
+#define BFA_PL_ENAME_STRLEN    	8
+struct bfa_plog_eid_strings_s {
+	char e_str[BFA_PL_ENAME_STRLEN];
+};
+
+#define BFA_PL_SIG_LEN	8
+#define BFA_PL_SIG_STR  "12pl123"
+
+/*
+ * per port circular log buffer
+ */
+struct bfa_plog_s {
+	char plog_sig[BFA_PL_SIG_LEN];	/* Start signature */
+	u8 plog_enabled;
+	u8 rsvd[7];
+	u32 ticks;
+	u16 head;
+	u16 tail;
+	struct bfa_plog_rec_s plog_recs[BFA_PL_NLOG_ENTS];
+};
+
+void bfa_plog_init(struct bfa_plog_s *plog);
+void bfa_plog_str(struct bfa_plog_s *plog, enum bfa_plog_mid mid,
+		  enum bfa_plog_eid event, u16 misc, char *log_str);
+void bfa_plog_intarr(struct bfa_plog_s *plog, enum bfa_plog_mid mid,
+		     enum bfa_plog_eid event, u16 misc,
+		     u32 * intarr, u32 num_ints);
+void bfa_plog_fchdr(struct bfa_plog_s *plog, enum bfa_plog_mid mid,
+		    enum bfa_plog_eid event, u16 misc, struct fchs_s *fchdr);
+void bfa_plog_fchdr_and_pl(struct bfa_plog_s *plog, enum bfa_plog_mid mid,
+			   enum bfa_plog_eid event, u16 misc,
+			   struct fchs_s *fchdr, u32 pld_w0);
+void bfa_plog_clear(struct bfa_plog_s *plog);
+void bfa_plog_enable(struct bfa_plog_s *plog);
+void bfa_plog_disable(struct bfa_plog_s *plog);
+bfa_boolean_t bfa_plog_get_setting(struct bfa_plog_s *plog);
+
+#endif /* __BFA_PORTLOG_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_q.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_q.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_q.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_q.h	2009-08-28 21:09:29.031471000 -0700
@@ -0,0 +1,88 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_q.h Circular queue definitions.
+ */
+
+#ifndef __BFA_Q_H__
+#define __BFA_Q_H__
+
+#define bfa_q_first(_q) ((void *)(((struct list_head *) (_q))->next))
+#define bfa_q_next(_qe)	(((struct list_head *) (_qe))->next)
+#define bfa_q_prev(_qe) (((struct list_head *) (_qe))->prev)
+
+/*
+ * bfa_q_qe_init - to initialize a queue element
+ */
+#define bfa_q_qe_init(_qe) {						\
+	bfa_q_next(_qe) = (struct list_head *) NULL;			\
+	bfa_q_prev(_qe) = (struct list_head *) NULL;			\
+}
+
+/*
+ * bfa_q_deq - dequeue an element from head of the queue
+ */
+#define bfa_q_deq(_q, _qe) {						\
+	if (!list_empty(_q)) {					\
+		(*((struct list_head **) (_qe))) = bfa_q_next(_q);	\
+		bfa_q_prev(bfa_q_next(*((struct list_head **) _qe))) =	\
+						(struct list_head *) (_q); \
+		bfa_q_next(_q) = bfa_q_next(*((struct list_head **) _qe)); \
+		BFA_Q_DBG_INIT(*((struct list_head **) _qe));		\
+	} else {							\
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								\
+}
+
+/*
+ * bfa_q_deq_tail - dequeue an element from tail of the queue
+ */
+#define bfa_q_deq_tail(_q, _qe) {					    \
+	if (!list_empty(_q)) {					            \
+		*((struct list_head **) (_qe)) = bfa_q_prev(_q);	    \
+		bfa_q_next(bfa_q_prev(*((struct list_head **) _qe))) = 	    \
+						(struct list_head *) (_q);  \
+		bfa_q_prev(_q) = bfa_q_prev(*(struct list_head **) _qe);    \
+		BFA_Q_DBG_INIT(*((struct list_head **) _qe));		    \
+	} else {							    \
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								    \
+}
+
+/*
+ * #ifdef BFA_DEBUG (Using bfa_assert to check for debug_build is not
+ * consistent across modules)
+ */
+#ifndef BFA_PERF_BUILD
+#define BFA_Q_DBG_INIT(_qe)	bfa_q_qe_init(_qe)
+#else
+#define BFA_Q_DBG_INIT(_qe)
+#endif
+
+#define bfa_q_is_on_q(_q, _qe)		\
+	bfa_q_is_on_q_func(_q, (struct list_head *)(_qe))
+extern int bfa_q_is_on_q_func(struct list_head *q, struct list_head *qe);
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_sm.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_sm.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_sm.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_sm.h	2009-08-28 21:09:29.223468000 -0700
@@ -0,0 +1,76 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfasm.h State machine defines
+ */
+
+#ifndef __BFA_SM_H__
+#define __BFA_SM_H__
+
+typedef void (*bfa_sm_t) (void *sm, int event);
+
+#define bfa_sm_set_state(_sm, _state)	(_sm)->sm = (bfa_sm_t)(_state)
+#define bfa_sm_send_event(_sm, _event)	(_sm)->sm((_sm), (_event))
+#define bfa_sm_get_state(_sm)		((_sm)->sm)
+#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
+
+/**
+ * For converting from state machine function to state encoding.
+ */
+struct bfa_sm_table_s {
+	bfa_sm_t sm;		/*  state machine function      */
+	int state;		/*  state machine encoding      */
+	char *name;		/*  state name for display      */
+};
+#define BFA_SM(_sm)	((bfa_sm_t)(_sm))
+
+int bfa_sm_to_state(struct bfa_sm_table_s *smt, bfa_sm_t sm);
+
+/**
+ * State machine with entry actions.
+ */
+typedef void (*bfa_fsm_t) (void *fsm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc_s
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_fsm_state_decl(oc, st, otype, etype)		\
+	static void oc ## _sm_ ## st(otype * fsm, etype event);      \
+	static void oc ## _sm_ ## st ## _entry(otype * fsm)
+
+#define bfa_fsm_set_state(_fsm, _state) do {	\
+	(_fsm)->fsm = (bfa_fsm_t)(_state);      \
+	_state ## _entry(_fsm);      \
+} while (0)
+
+#define bfa_fsm_send_event(_fsm, _event)	\
+	(_fsm)->fsm((_fsm), (_event))
+#define bfa_fsm_cmp_state(_fsm, _state)		\
+	((_fsm)->fsm == (bfa_fsm_t)(_state))
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_trc.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_trc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_trc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_trc.h	2009-08-28 21:09:29.178515000 -0700
@@ -0,0 +1,181 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_TRC_H__
+#define __BFA_TRC_H__
+
+#include <bfa_os_inc.h>
+
+#ifndef BFA_TRC_MAX
+#define BFA_TRC_MAX	(4 * 1024)
+#endif
+
+#ifndef BFA_TRC_TS
+#define BFA_TRC_TS(_trcm)	((_trcm)->ticks ++)
+#endif
+
+struct bfa_trc_s {
+#ifdef __BIGENDIAN
+	u16 fileno;
+	u16 line;
+#else
+	u16 line;
+	u16 fileno;
+#endif
+	u32 timestamp;
+	union {
+		struct {
+			u32 rsvd;
+			u32 u32;
+		} u32;
+		u64 u64;
+	} data;
+};
+
+
+struct bfa_trc_mod_s {
+	u32 head;
+	u32 tail;
+	u32 ntrc;
+	u32 stopped;
+	u32 ticks;
+	u32 rsvd[3];
+	struct bfa_trc_s trc[BFA_TRC_MAX];
+};
+
+
+enum {
+	BFA_TRC_FW = 1,		/*  firmware modules */
+	BFA_TRC_HAL = 2,	/*  BFA modules */
+	BFA_TRC_FCS = 3,	/*  BFA FCS modules */
+	BFA_TRC_LDRV = 4,	/*  Linux driver modules */
+	BFA_TRC_SDRV = 5,	/*  Solaris driver modules */
+	BFA_TRC_VDRV = 6,	/*  vmware driver modules */
+	BFA_TRC_WDRV = 7,	/*  windows driver modules */
+	BFA_TRC_AEN = 8,	/*  AEN module */
+	BFA_TRC_BIOS = 9,	/*  bios driver modules */
+	BFA_TRC_EFI = 10,	/*  EFI driver modules */
+	BNA_TRC_WDRV = 11,	/*  BNA windows driver modules */
+	BNA_TRC_VDRV = 12,	/*  BNA vmware driver modules */
+	BNA_TRC_SDRV = 13,	/*  BNA Solaris driver modules */
+	BNA_TRC_LDRV = 14,	/*  BNA Linux driver modules */
+	BNA_TRC_HAL = 15,	/*  BNA modules */
+	BFA_TRC_CNA = 16,	/*  Common modules */
+	BNA_TRC_IMDRV = 17	/*  BNA windows intermediate driver modules */
+};
+#define BFA_TRC_MOD_SH	10
+#define BFA_TRC_MOD(__mod)	((BFA_TRC_ ## __mod) << BFA_TRC_MOD_SH)
+
+/**
+ * Define a new tracing file (module). Module should match one defined above.
+ */
+#define BFA_TRC_FILE(__mod, __submod)					\
+	static int __trc_fileno = ((BFA_TRC_ ## __mod ## _ ## __submod) | \
+						 BFA_TRC_MOD(__mod))
+
+
+#define bfa_trc32(_trcp, _data)	\
+	__bfa_trc((_trcp)->trcmod, __trc_fileno, __LINE__, (u32)_data)
+
+
+#ifndef BFA_BOOT_BUILD
+#define bfa_trc(_trcp, _data)	\
+	__bfa_trc((_trcp)->trcmod, __trc_fileno, __LINE__, (u64)_data)
+#else
+void bfa_boot_trc(struct bfa_trc_mod_s *trcmod, u16 fileno, u16 line, u32 data);
+#define bfa_trc(_trcp, _data)	\
+	bfa_boot_trc((_trcp)->trcmod, __trc_fileno, __LINE__, (u32)_data)
+#endif
+
+
+static inline void
+bfa_trc_init(struct bfa_trc_mod_s *trcm)
+{
+	trcm->head = trcm->tail = trcm->stopped = 0;
+	trcm->ntrc = BFA_TRC_MAX;
+}
+
+
+static inline void
+bfa_trc_stop(struct bfa_trc_mod_s *trcm)
+{
+	trcm->stopped = 1;
+}
+
+#ifdef FWTRC
+extern void dc_flush(void *data);
+#else
+#define dc_flush(data)
+#endif
+
+
+static inline void
+__bfa_trc(struct bfa_trc_mod_s *trcm, int fileno, int line, u64 data)
+{
+	int tail = trcm->tail;
+	struct bfa_trc_s *trc = &trcm->trc[tail];
+
+	if (trcm->stopped)
+		return;
+
+	trc->fileno = (u16) fileno;
+	trc->line = (u16) line;
+	trc->data.u64 = data;
+	trc->timestamp = BFA_TRC_TS(trcm);
+	dc_flush(trc);
+
+	trcm->tail = (trcm->tail + 1) & (BFA_TRC_MAX - 1);
+	if (trcm->tail == trcm->head)
+		trcm->head = (trcm->head + 1) & (BFA_TRC_MAX - 1);
+	dc_flush(trcm);
+}
+
+
+static inline void
+__bfa_trc32(struct bfa_trc_mod_s *trcm, int fileno, int line, u32 data)
+{
+	int tail = trcm->tail;
+	struct bfa_trc_s *trc = &trcm->trc[tail];
+
+	if (trcm->stopped)
+		return;
+
+	trc->fileno = (u16) fileno;
+	trc->line = (u16) line;
+	trc->data.u32.u32 = data;
+	trc->timestamp = BFA_TRC_TS(trcm);
+	dc_flush(trc);
+
+	trcm->tail = (trcm->tail + 1) & (BFA_TRC_MAX - 1);
+	if (trcm->tail == trcm->head)
+		trcm->head = (trcm->head + 1) & (BFA_TRC_MAX - 1);
+	dc_flush(trcm);
+}
+
+#ifndef BFA_PERF_BUILD
+#define bfa_trc_fp(_trcp, _data)	bfa_trc(_trcp, _data)
+#else
+#define bfa_trc_fp(_trcp, _data)
+#endif
+
+#endif /* __BFA_TRC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_wc.h linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_wc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/cs/bfa_wc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/cs/bfa_wc.h	2009-08-28 21:09:29.061478000 -0700
@@ -0,0 +1,75 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_wc.h Generic wait counter.
+ */
+
+#ifndef __BFA_WC_H__
+#define __BFA_WC_H__
+
+typedef void (*bfa_wc_resume_t) (void *cbarg);
+
+struct bfa_wc_s {
+	bfa_wc_resume_t wc_resume;
+	void *wc_cbarg;
+	int wc_count;
+};
+
+static inline void
+bfa_wc_up(struct bfa_wc_s *wc)
+{
+	wc->wc_count++;
+}
+
+static inline void
+bfa_wc_down(struct bfa_wc_s *wc)
+{
+	wc->wc_count--;
+	if (wc->wc_count == 0)
+		wc->wc_resume(wc->wc_cbarg);
+}
+
+/**
+ * Initialize a waiting counter.
+ */
+static inline void
+bfa_wc_init(struct bfa_wc_s *wc, bfa_wc_resume_t wc_resume, void *wc_cbarg)
+{
+	wc->wc_resume = wc_resume;
+	wc->wc_cbarg = wc_cbarg;
+	wc->wc_count = 0;
+	bfa_wc_up(wc);
+}
+
+/**
+ * Wait for counter to reach zero
+ */
+static inline void
+bfa_wc_wait(struct bfa_wc_s *wc)
+{
+	bfa_wc_down(wc);
+}
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_fcs.h linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_fcs.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_fcs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_fcs.h	2009-08-28 21:09:30.215399000 -0700
@@ -0,0 +1,35 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/*
+ * messages define for FCS Module
+ */
+#ifndef	__BFA_LOG_FCS_H__
+#define	__BFA_LOG_FCS_H__
+#include  <cs/bfa_log.h>
+#define BFA_LOG_FCS_FABRIC_NOSWITCH 	\
+	(((u32) BFA_LOG_FCS_ID << BFA_LOG_MODID_OFFSET) | 1)
+#define BFA_LOG_FCS_FABRIC_ISOLATED 	\
+	(((u32) BFA_LOG_FCS_ID << BFA_LOG_MODID_OFFSET) | 2)
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_hal.h linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_hal.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_hal.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_hal.h	2009-08-28 21:09:30.301400000 -0700
@@ -0,0 +1,37 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for HAL Module */
+#ifndef	__BFA_LOG_HAL_H__
+#define	__BFA_LOG_HAL_H__
+#include  <cs/bfa_log.h>
+#define BFA_LOG_HAL_ASSERT \
+	(((u32) BFA_LOG_HAL_ID << BFA_LOG_MODID_OFFSET) | 1)
+#define BFA_LOG_HAL_HEARTBEAT_FAILURE \
+	(((u32) BFA_LOG_HAL_ID << BFA_LOG_MODID_OFFSET) | 2)
+#define BFA_LOG_HAL_FCPIM_PARM_INVALID \
+	(((u32) BFA_LOG_HAL_ID << BFA_LOG_MODID_OFFSET) | 3)
+#define BFA_LOG_HAL_SM_ASSERT \
+	(((u32) BFA_LOG_HAL_ID << BFA_LOG_MODID_OFFSET) | 4)
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_linux.h linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_linux.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_linux.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_linux.h	2009-08-28 21:09:30.237399000 -0700
@@ -0,0 +1,51 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/* messages define for LINUX Module */
+#ifndef	__BFA_LOG_LINUX_H__
+#define	__BFA_LOG_LINUX_H__
+#include  <cs/bfa_log.h>
+#define BFA_LOG_LINUX_DEVICE_CLAIMED \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 1)
+#define BFA_LOG_LINUX_HASH_INIT_FAILED \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 2)
+#define BFA_LOG_LINUX_SYSFS_FAILED \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 3)
+#define BFA_LOG_LINUX_MEM_ALLOC_FAILED \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 4)
+#define BFA_LOG_LINUX_DRIVER_REGISTRATION_FAILED \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 5)
+#define BFA_LOG_LINUX_ITNIM_FREE \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 6)
+#define BFA_LOG_LINUX_ITNIM_ONLINE \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 7)
+#define BFA_LOG_LINUX_ITNIM_OFFLINE \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 8)
+#define BFA_LOG_LINUX_SCSI_HOST_FREE \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 9)
+#define BFA_LOG_LINUX_SCSI_ABORT \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 10)
+#define BFA_LOG_LINUX_SCSI_ABORT_COMP \
+		(((u32) BFA_LOG_LINUX_ID << BFA_LOG_MODID_OFFSET) | 11)
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_wdrv.h linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_wdrv.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/log/bfa_log_wdrv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/log/bfa_log_wdrv.h	2009-08-28 21:09:30.266405000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/*
+ * messages define for WDRV Module
+ */
+#ifndef	__BFA_LOG_WDRV_H__
+#define	__BFA_LOG_WDRV_H__
+#include  <cs/bfa_log.h>
+#define BFA_LOG_WDRV_IOC_INIT_ERROR 	\
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 1)
+#define BFA_LOG_WDRV_IOC_INTERNAL_ERROR \
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 2)
+#define BFA_LOG_WDRV_IOC_START_ERROR 	\
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 3)
+#define BFA_LOG_WDRV_IOC_STOP_ERROR 	\
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 4)
+#define BFA_LOG_WDRV_INSUFFICIENT_RESOURCES \
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 5)
+#define BFA_LOG_WDRV_BASE_ADDRESS_MAP_ERROR \
+	(((u32) BFA_LOG_WDRV_ID << BFA_LOG_MODID_OFFSET) | 6)
+#endif
