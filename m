From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 4/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:31:24 -0800
Message-ID: <20080217023124.b9de3b8d@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:48118 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbYBQCba convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:31:30 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:31:25 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

beclib header files.

-----------------------
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/pch.h benet/linux-2.6.24.2/drivers/message/beclib/pch.h
--- orig/linux-2.6.24.2/drivers/message/beclib/pch.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/pch.h	2008-02-14 15:23:07.797207408 +0530
@@ -0,0 +1,58 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+/*!
+@file
+   pch.h
+
+@brief
+
+    Each .c file in beclib includes this "precompiled header" file.
+    It should ONLY be included by beclib files.
+    Clients of beclib should include "beclib.h" instead.
+*/
+#ifndef __pch_h__
+#define __pch_h__
+
+/*
+ * -----------------------------------------------------------------------
+ *    Our custom includes
+ * 
+-----------------------------------------------------------------------
+ */
+
+#define _SA_MODULE_NAME "beclib_lk"
+#define BECLIB_BUILD
+
+#include "beclib_ll.h"
+#include "beclib_private_ll.h"
+#include "bestatus.h"
+
+#endif /* __pch_h__ */
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/beclib_common.h benet/linux-2.6.24.2/drivers/message/beclib/beclib_common.h
--- orig/linux-2.6.24.2/drivers/message/beclib/beclib_common.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/beclib_common.h	2008-02-14 15:23:07.797207408 +0530
@@ -0,0 +1,111 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#ifndef __beclib_common_h__
+#define __beclib_common_h__
+
+#include "sa.h"
+
+
+/* Enable each srcgen struct to be an array of dwords */ #define 
+SG_BMAP_UNION
+
+/* Pack srcgen structs */
+#ifndef SG_ATTRIBUTE_PACK
+#define SG_ATTRIBUTE_PACK
+#endif
+
+
+/* Define the static inline srcgen qualifier for inline functions. */
+#define SG_STATIC_INLINE    STATIC INLINE
+
+#if !defined(BE_CONFIG)
+#define BE_CONFIG 0
+#define CONFIG0
+#endif
+
+#define BE_GEN_STATIC_INLINE STATIC INLINE #define BE_GEN_ASSERT ASSERT 
+/*Id ranges and RID conversions based on config */ #include 
+"be_gen_id_ranges.h"
+
+/* Srcgen includes */
+
+#include "regmap.h"		/* srcgen array map output */
+#include "host_struct.h"	/* srcgen array map output */
+#include "ioctl_top.h"		/* srcgen array map output */
+
+#include "regmap_bmap.h"	/* srcgen bitmap output */
+#include "host_struct_bmap.h"	/* srcgen bitmap output */
+#include "ioctl_top_bmap.h"	/* srcgen bitmap output */
+
+#include "bestatus.h"
+
+/* Debug trace categories. */
+typedef enum _BE_DEBUG_LEVELS {
+	DL_HW = 0x00000100,
+	DL_IOCTL = 0x00000200,
+
+	BE_DL_MIN_VALUE = 0x100,	/* this is the min value used */
+	BE_DL_MAX_VALUE = 0x800	/* this is the higheset value used */
+} BE_DEBUG_LEVELS, *PBE_DEBUG_LEVELS;
+
+SA_GLOBAL_C_ASSERT(beclib_debug_level_range,
+		   ((u32) BE_DL_MIN_VALUE > (u32) SA_DL_MAX_VALUE));
+
+#include "beregister.h"	/* Macros for register access using srcgen structs */
+#include "beclib_stats.h"
+
+/*  BECLIB status data type maps to the SA_STATUS */ typedef SA_STATUS 
+BESTATUS, *PBESTATUS;
+
+/* BECLIB calling convention.  Use default currently. */ #define BECALL
+
+/* Forward declarations. */
+struct _BE_FUNCTION_OBJECT;
+struct _BE_EQ_OBJECT;
+struct _BE_CQ_OBJECT;
+
+/* Callback types.  Deprecate most of these. */ typedef void (BECALL 
+*MCC_WRB_CQE_CALLBACK) (PVOID context,
+					      BESTATUS status,
+					      MCC_WRB *optional_wrb);
+typedef void (BECALL *MCC_ASYNC_EVENT_CALLBACK) (PVOID context,
+						  u32 event_code,
+						  PVOID event);
+
+typedef BESTATUS(*EQ_CALLBACK) (struct _BE_FUNCTION_OBJECT *,
+				struct _BE_EQ_OBJECT *, PVOID context); typedef 
+BESTATUS(*CQ_CALLBACK) (struct _BE_FUNCTION_OBJECT *,
+				struct _BE_CQ_OBJECT *, PVOID context);
+
+#endif /* __beclib_common_h__ */
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/beclib_ll.h benet/linux-2.6.24.2/drivers/message/beclib/beclib_ll.h
--- orig/linux-2.6.24.2/drivers/message/beclib/beclib_ll.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/beclib_ll.h	2008-02-14 15:23:07.798207256 +0530
@@ -0,0 +1,682 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#ifndef __beclib_lower_h__
+#define __beclib_lower_h__
+
+#include "beclib_common.h"	/* High and low level API commonalities */
+
+SA_CPP_HEADER
+/*!
+@brief
+    Internal memory descriptor for memory shared by both the host driver and
+    the controller
+*/
+    typedef struct _BE_SHARED_MEM_DESCRIPTOR {
+	PVOID va;		/*! virtual address */
+	PSA_SGL sgl;		/*! memory descriptor list */
+	u32 tag;		/*! memory tracking tag */
+} BE_SHARED_MEM_DESCRIPTOR, *PBE_SHARED_MEM_DESCRIPTOR;
+
+/*!
+@brief
+    Locking structure for beklib.
+*/
+typedef struct _BE_LOCK {
+	SA_SPINLOCK lock;
+	SA_IRQ irql;
+} BE_LOCK, *PBE_LOCK;
+
+typedef SA_FAST_MUTEX BE_BLOCKING_LOCK, *PBE_BLOCKING_LOCK;
+
+/*!
+@brief
+    Represents a Blade Engine chip. This is used to manage
+    global chip resources.  Only the ARM uses this from the low
+    level API.
+*/
+typedef struct _BE_CHIP_OBJECT {
+	u32 magic;
+	u32 ref_count;
+	BE_LOCK lock;
+	SA_LIST_ENTRY function_list_head;
+
+} BE_CHIP_OBJECT, *PBE_CHIP_OBJECT;
+
+typedef struct _BE_MCC_WRB_RESPONSE_COPY {
+
+	u16 length;		/* bytes in response */
+	u16 ioctl_offset;	/* offset within the wrb of the response */
+	PVOID va;		/* user's va to copy response into */
+
+} BE_MCC_WRB_RESPONSE_COPY, *PBE_MCC_WRB_RESPONSE_COPY;
+
+typedef struct _BE_MCC_WRB_CONTEXT {
+
+	MCC_WRB_CQE_CALLBACK internal_callback;	/* Function to call on
+						completion */
+	PVOID internal_callback_context;	/* Parameter to pass
+						   to completion function */
+
+	MCC_WRB_CQE_CALLBACK callback;	/* Function to call on completion */
+	PVOID callback_context;	/* Parameter to pass to completion function */
+
+	volatile BESTATUS *users_final_status;	/* pointer to a local
+						   variable for synchronous
+						   commands */
+	MCC_WRB *wrb;		/* pointer to original wrb for embedded
+				   commands only */
+	SA_LIST_ENTRY next;	/* links context structs together in
+				   free list */
+
+	BE_MCC_WRB_RESPONSE_COPY copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+#if defined(SA_DEBUG)
+	u16 subsystem, opcode;	/* Track this IOCTL for debug builds. */
+	MCC_WRB *ring_wrb;
+	u32 consumed_count;
+#endif
+} BE_MCC_WRB_CONTEXT, *PBE_MCC_WRB_CONTEXT;
+
+/*!
+@brief
+    Represents a function object for network or storage.  This
+    is used to manage per-function resources like MCC CQs, etc.
+*/
+typedef struct _BE_FUNCTION_OBJECT {
+
+	u32 magic;		/*!< magic for detecting memory corruption. */
+	PBE_CHIP_OBJECT parent_chip;
+
+	/*
+	 *! Generic system abstraction (SA) device object for accessing
+	 * registers, physical memory, etc.
+	 */
+	SA_DEV *sa_dev;
+
+	u32 emulate;		/* if set, MPU is not available.
+				  Emulate everything.     */
+	u32 pend_queue_driving;	/* if set, drive the queued WRBs
+				   after releasing the WRB lock */
+
+	SA_SPINLOCK post_lock;	/* lock for verifying one thread posting wrbs */
+	SA_SPINLOCK cq_lock;	/* lock for verifying one thread
+				   processing cq */
+	SA_SPINLOCK mcc_context_lock;	/* lock for protecting mcc
+					   context free list */
+	SA_IRQ post_irq;
+	SA_IRQ cq_irq;
+
+	u32 ref_count;		/*!< number obejcts referencing this funcobj */
+	BE_LOCK lock;		/*!< synchronization lock         */
+	u32 type;
+	u32 pci_function_number;
+
+	SA_LIST_ENTRY function_list;	/*!< for linking these objects
+					  together */
+
+	struct {
+		SA_LIST_ENTRY pd_list_head;	/* protection domain list */
+		SA_LIST_ENTRY cq_list_head;	/* completion queue list */
+		SA_LIST_ENTRY eq_list_head;	/* event queue list     */
+		SA_LIST_ENTRY cxn_list_head;	/* list of active
+						   connections */
+		SA_LIST_ENTRY eth_sq_list_head;	/* list of ethernet
+						   send rings */
+		SA_LIST_ENTRY eth_rq_list_head;	/* list of ether RX rings */
+		SA_LIST_ENTRY rdma_qp_list_head;	/* queue pair list */
+
+		struct _BE_MCC_OBJECT *mcc;	/* mcc rings. */
+		struct _BE_PD_OBJECT *pd_object; /* perceived PD 0 */
+
+		union {
+			struct {
+				SA_LIST_ENTRY wrbq_list_head;
+				SA_LIST_ENTRY defq_list_head;
+			} iscsi;
+
+			struct {
+				SA_LIST_ENTRY dq_list_head;
+				SA_LIST_ENTRY sq_list_head;
+				SA_LIST_ENTRY rq_list_head;
+			} networking;
+		};
+	} links;
+
+	struct {
+		PMCC_MAILBOX va;	/* VA to the mailbox */
+		SA_PHYSICAL_ADDRESS pa;	/* PA to the mailbox */
+		u32 length;	/* byte length of mailbox */
+
+		/* One default context struct used for posting at
+		 * least one MCC_WRB
+		 */
+		BE_MCC_WRB_CONTEXT default_context;
+		boolean default_context_allocated;
+	} mailbox;
+
+	struct {
+		/* Page table     */
+		u32 num_page_table;
+		u32 num_sgl;
+
+		/* Wake on lans configured. */
+		u32 wol_bitmask;	/* bits 0,1,2,3 are set if
+					   corresponding index is enabled */
+		u32 num_jell;
+		u32 num_vlan;
+		u32 num_template;
+		u32 num_multicast;
+		u32 rss_type;
+		u32 num_zero;
+		u32 num_ooo;
+	} config;
+
+	u32 own_semaphore;
+	SA_IRQ current_irql;
+
+	BE_FIRMWARE_CONFIG fw_config;
+	BECLIB_FUNCTION_STATS stats;
+
+} BE_FUNCTION_OBJECT, *PBE_FUNCTION_OBJECT;
+
+/*!
+@brief
+    Represents a protection domain
+*/
+typedef struct _BE_PD_OBJECT {
+	u32 magic;
+	u32 ref_count;
+
+	PBE_FUNCTION_OBJECT parent_function;
+	SA_LIST_ENTRY pd_list;
+
+	u32 pd_id;
+	u8 *pd_page_va;
+	u64 pd_page_pa;
+
+} BE_PD_OBJECT, *PBE_PD_OBJECT;
+
+/*!
+  @brief
+      Represents an Event Queue
+*/
+typedef struct _BE_EQ_OBJECT {
+	u32 magic;
+	u32 ref_count;
+	BE_LOCK lock;
+
+	PBE_FUNCTION_OBJECT parent_function;
+
+	SA_LIST_ENTRY eq_list;
+	SA_LIST_ENTRY cq_list_head;
+
+	u32 eq_id;
+	EQ_CALLBACK callback;
+	PVOID callback_context;
+
+} BE_EQ_OBJECT, *PBE_EQ_OBJECT;
+
+/*!
+@brief
+    Manages a completion queue
+*/
+typedef struct _BE_CQ_OBJECT {
+	u32 magic;
+	u32 ref_count;
+
+	PBE_FUNCTION_OBJECT parent_function;
+	PBE_EQ_OBJECT eq_object;
+
+	SA_LIST_ENTRY cq_list;
+	SA_LIST_ENTRY cqlist_for_eq;
+
+	PVOID va;
+	u32 num_entries;
+
+	CQ_CALLBACK callback;
+	PVOID callback_context;
+
+	u32 cq_id;
+
+} BE_CQ_OBJECT, *PBE_CQ_OBJECT;
+
+/*!
+@brief
+    Manages an ethernet send queue
+*/
+typedef struct _BE_ETHSQ_OBJECT {
+	u32 magic;
+
+	SA_LIST_ENTRY list;
+
+	PBE_FUNCTION_OBJECT parent_function;
+	PBE_CQ_OBJECT cq_object;
+	u32 bid;
+
+} BE_ETHSQ_OBJECT, *PBE_ETHSQ_OBJECT;
+
+/*!
+@brief
+    Manages an ethernet receive queue
+*/
+typedef struct _BE_ETHRQ_OBJECT {
+	u32 magic;
+	SA_LIST_ENTRY list;
+	PBE_FUNCTION_OBJECT parent_function;
+	u32 rid;
+	PBE_CQ_OBJECT cq_object;
+	PBE_CQ_OBJECT rss_cq_object[4];
+
+} BE_ETHRQ_OBJECT, *PBE_ETHRQ_OBJECT;
+
+/*!
+@brief
+    Manages an MCC
+*/
+typedef struct _BE_MCC_OBJECT {
+	u32 magic;
+
+	PBE_FUNCTION_OBJECT parent_function;
+	SA_LIST_ENTRY mcc_list;
+
+	PBE_CQ_OBJECT cq_object;
+
+	/* Async event callback for MCC CQ. */
+	MCC_ASYNC_EVENT_CALLBACK async_callback;
+	PVOID async_context;
+
+	struct {
+		struct _BE_MCC_WRB_CONTEXT *base;
+		u32 num;
+		SA_LIST_ENTRY list_head;
+	} wrb_context;
+
+	struct {
+		PSA_SGL sgl;
+		BE_SHARED_MEM_DESCRIPTOR sm_descriptor;
+		SA_RING ring;
+	} sq;
+
+	struct {
+		BE_SHARED_MEM_DESCRIPTOR sm_descriptor;
+		SA_RING ring;
+	} cq;
+
+	u32 processing;		/* flag indicating that one thread
+				   is processing CQ */
+	u32 rearm;		/* doorbell rearm setting to make
+				   sure the active processing thread */
+	/* rearms the CQ if any of the threads requested it. */
+
+	SA_LIST_ENTRY backlog;
+	u32 backlog_length;
+	u32 driving_backlog;
+	u32 consumed_index;
+
+} BE_MCC_OBJECT, *PBE_MCC_OBJECT;
+
+/*!
+@brief
+   Manages an iSCSI default PDU
+*/
+typedef struct _BE_DEFAULT_PDU_QUEUE_OBJECT {
+	u32 magic;
+
+	PBE_FUNCTION_OBJECT parent_function;
+	SA_LIST_ENTRY func_list;
+	PBE_CQ_OBJECT cq_object;
+	PSA_SGL sgl;
+	u32 rid;
+} BE_DEFAULT_PDU_QUEUE_OBJECT, *PBE_DEFAULT_PDU_QUEUE_OBJECT;
+
+typedef struct _BE_ISCSI_WRB_QUEUE_OBJECT {
+
+	u32 magic;
+
+	PBE_FUNCTION_OBJECT parent_function;
+
+	SA_LIST_ENTRY wrbq_list;
+
+	/*u32 cra, length; */
+	u32 cid;
+	PSA_SGL sgl;
+	u32 length;
+
+} BE_ISCSI_WRB_QUEUE_OBJECT, *PBE_ISCSI_WRB_QUEUE_OBJECT;
+
+/*!
+@brief
+   Manages iSCSI connection resources like CID, WRB ring, etc.
+*/
+typedef struct _BE_ISCSI_CONNECTION_OBJECT {
+	u32 magic;
+	PBE_FUNCTION_OBJECT parent_function;
+
+	PBE_CQ_OBJECT cq;
+	PBE_ISCSI_WRB_QUEUE_OBJECT wrbq;
+	PBE_DEFAULT_PDU_QUEUE_OBJECT defq;
+
+	SA_LIST_ENTRY connection_list;
+} BE_ISCSI_CONNECTION_OBJECT, *PBE_ISCSI_CONNECTION_OBJECT;
+
+/* Queue context header -- the required software information for
+ * queueing a WRB.
+ */
+typedef struct _BE_QUEUE_DRIVER_CONTEXT {
+	MCC_WRB_CQE_CALLBACK internal_callback;	/* Function to call on
+						   completion */
+	PVOID internal_callback_context;	/* Parameter to pass
+						   to completion function */
+
+	MCC_WRB_CQE_CALLBACK callback;	/* Function to call on completion */
+	PVOID callback_context;	/* Parameter to pass to completion function */
+
+	BE_MCC_WRB_RESPONSE_COPY copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+	PVOID optional_ioctl_va;
+
+	SA_LIST_ENTRY list;
+
+	u32 bytes;
+
+} BE_QUEUE_DRIVER_CONTEXT, *PBE_QUEUE_DRIVER_CONTEXT;
+
+/*
+ *lint -e413
+ *lint -e831
+ *lint -e30
+ *lint -e84
+ * Common MCC WRB header that all commands require.
+ */
+typedef struct _BE_MCC_WRB_HEADER {
+	u8 rsvd[SA_FIELD_OFFSET(MCC_WRB, payload)]; } BE_MCC_WRB_HEADER, 
+*PBE_MCC_WRB_HEADER; SA_GLOBAL_C_ASSERT(queue_header,
+		   sizeof(BE_MCC_WRB_HEADER) == SA_FIELD_OFFSET(MCC_WRB,
+								payload));
+
+/*
+ * All non embedded commands supported by beclib functions only allow
+ * 1 SGE.  This queue context handles them all.
+ */
+typedef struct _BE_NONEMBEDDED_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	MCC_SGE sge[1];
+} BE_NONEMBEDDED_QUEUE_CONTEXT, *PBE_NONEMBEDDED_QUEUE_CONTEXT;
+
+/*
+ * 
+-----------------------------------------------------------------------
+-
+ *  This section contains the specific queue struct for each command.
+ *  The user could always provide a BE_GENERIC_QUEUE_CONTEXT but this 
+is a
+ *  rather large struct.  By using the specific struct, memory 
+consumption
+ *  can be reduced.
+ * 
+-----------------------------------------------------------------------
+-
+ */
+typedef BE_NONEMBEDDED_QUEUE_CONTEXT BE_ETH_STATS_QUEUE_CONTEXT,
+    *PBE_ETH_STATS_QUEUE_CONTEXT;
+
+typedef struct _BE_LINK_STATUS_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_NTWK_LINK_STATUS_QUERY ioctl; } 
+BE_LINK_STATUS_QUEUE_CONTEXT, *PBE_LINK_STATUS_QUEUE_CONTEXT;
+
+typedef struct _BE_MULTICAST_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_NTWK_MULTICAST_SET ioctl; } BE_MULTICAST_QUEUE_CONTEXT, 
+*PBE_MULTICAST_QUEUE_CONTEXT;
+
+typedef struct _BE_WAKE_ON_LAN_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_ETH_ACPI_CONFIG ioctl;
+} BE_WAKE_ON_LAN_QUEUE_CONTEXT, *PBE_WAKE_ON_LAN_QUEUE_CONTEXT;
+
+typedef struct _BE_VLAN_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_NTWK_VLAN_CONFIG ioctl;
+} BE_VLAN_QUEUE_CONTEXT, *PBE_VLAN_QUEUE_CONTEXT;
+
+typedef struct _BE_PROMISCUOUS_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_ETH_PROMISCUOUS ioctl;
+} BE_PROMISCUOUS_QUEUE_CONTEXT, *PBE_PROMISCUOUS_QUEUE_CONTEXT;
+
+typedef struct _BE_FORCE_FAILOVER_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_FORCE_FAILOVER ioctl;
+} BE_FORCE_FAILOVER_QUEUE_CONTEXT, *PBE_FORCE_FAILOVER_QUEUE_CONTEXT;
+
+typedef struct _BE_RSS_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_ETH_RSS_CONFIG ioctl;
+} BE_RSS_QUEUE_CONTEXT, *PBE_RSS_QUEUE_CONTEXT;
+
+typedef struct _BE_NOP_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_NOP ioctl;
+} BE_NOP_QUEUE_CONTEXT, *PBE_NOP_QUEUE_CONTEXT;
+
+typedef struct _BE_RXF_FILTER_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_NTWK_RX_FILTER ioctl;
+} BE_RXF_FILTER_QUEUE_CONTEXT, *PBE_RXF_FILTER_QUEUE_CONTEXT;
+
+typedef struct _BE_EQ_MODIFY_DELAY_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	IOCTL_COMMON_MODIFY_EQ_DELAY ioctl;
+} BE_EQ_MODIFY_DELAY_QUEUE_CONTEXT, *PBE_EQ_MODIFY_DELAY_QUEUE_CONTEXT;
+
+/*
+ * The generic context is the largest size that would be required.
+ * It is the software context plus an entire WRB.
+ */
+typedef struct _BE_GENERIC_QUEUE_CONTEXT {
+	BE_QUEUE_DRIVER_CONTEXT context;
+	BE_MCC_WRB_HEADER wrb_header;
+	MCC_WRB_PAYLOAD payload;
+} BE_GENERIC_QUEUE_CONTEXT, *PBE_GENERIC_QUEUE_CONTEXT;
+
+SA_GLOBAL_C_ASSERT(generic_queue_context,
+		   sizeof(BE_GENERIC_QUEUE_CONTEXT) >=
+		   sizeof(BE_QUEUE_DRIVER_CONTEXT) + sizeof(MCC_WRB));
+
+typedef BE_GENERIC_QUEUE_CONTEXT BE_CONFIG_RED_QUEUE_CONTEXT,
+    *PBE_CONFIG_RED_QUEUE_CONTEXT;
+typedef BE_GENERIC_QUEUE_CONTEXT BE_CONFIG_PORT_EQUALIXATION_QUEUE_CONTEXT,
+    *PBE_CONFIG_PORT_EQUALIXATION_QUEUE_CONTEXT;
+
+/*
+ * Types for the BE_QUEUE_CONTEXT object.
+ */
+#define BE_QUEUE_INVALID	(0)
+#define BE_QUEUE_LINK_STATUS	(0xA006)
+#define BE_QUEUE_ETH_STATS	(0xA007)
+#define BE_QUEUE_TPM_STATS	(0xA008)
+#define BE_QUEUE_TCP_STATS	(0xA009)
+#define BE_QUEUE_MULTICAST	(0xA00A)
+#define BE_QUEUE_VLAN		(0xA00B)
+#define BE_QUEUE_RSS		(0xA00C)
+#define BE_QUEUE_FORCE_FAILOVER	(0xA00D)
+#define BE_QUEUE_PROMISCUOUS	(0xA00E)
+#define BE_QUEUE_WAKE_ON_LAN	(0xA00F)
+#define BE_QUEUE_NOP		(0xA010)
+
+/*
+ * These define constant 32-bit values that are stored as the magic
+ * number in each data type.  The magic number is a debugging tool.
+ * In debug mode we use asserts to constantly check the integrity
+ * of the magic value, which spots double frees and some memory corruption.
+ * In release mode, the magic value can be used for post-mortem
+ * debugging without symbols to locate data types in memory -- this is
+ * easier using 4 character strings.
+ */
+#define BE_CHIP_MAGIC			SA_TAG("beco")
+#define BE_FUNCTION_MAGIC		SA_TAG("befo")
+#define BE_PD_MAGIC			SA_TAG("bepd")
+#define BE_CQ_MAGIC			SA_TAG("becq")
+#define BE_EQ_MAGIC			SA_TAG("beeq")
+#define BE_ETHSQ_MAGIC			SA_TAG("bees")
+#define BE_ETHRQ_MAGIC			SA_TAG("beer")
+#define BE_MCC_MAGIC			SA_TAG("bemc")
+#define BE_DEFAULT_PDU_QUEUE_MAGIC	SA_TAG("bedp")
+#define BE_ISCSI_CONNECTION_MAGIC	SA_TAG("beic")
+#define BE_TPM_CONNECTION_MAGIC		SA_TAG("betc")
+#define BE_TPM_SQ_MAGIC			SA_TAG("besq")
+#define BE_TPM_RQ_MAGIC			SA_TAG("berq")
+#define BE_TPM_DQ_MAGIC			SA_TAG("bedq")
+#define BE_ISCSI_WRB_QUEUE_MAGIC	SA_TAG("beiq")
+#define BE_RDMA_QP_MAGIC		SA_TAG("beqp")
+#define BE_RDMA_CXN_MAGIC		SA_TAG("brcx")
+
+/*
+ * Macro to declare an inline function that asserts on both a pointer 
+and
+ * the magic value.  Inline function nicely forces type safety at compile time.
+ */
+#define MAGIC_ASSERT_DECLARE(_short_type_) \ STATIC INLINE void 
+_short_type_##_ASSERT(BE_##_short_type_##_OBJECT *p) { \
+		ASSERT(p);					\
+		ASSERT(p->magic == BE_##_short_type_##_MAGIC);	\
+	}		\
+
+/*
+ * Declare inline functions, e.g. CHIP_ASSERT, that check the
+ * pointer for non-NULL and verify the magic constant.  Since they
+ * are functions, they also verify the type of the pointer at compile time.
+ */
+MAGIC_ASSERT_DECLARE(CHIP)
+MAGIC_ASSERT_DECLARE(FUNCTION)
+MAGIC_ASSERT_DECLARE(PD)
+MAGIC_ASSERT_DECLARE(CQ)
+MAGIC_ASSERT_DECLARE(EQ)
+MAGIC_ASSERT_DECLARE(ETHSQ)
+MAGIC_ASSERT_DECLARE(ETHRQ)
+MAGIC_ASSERT_DECLARE(MCC)
+MAGIC_ASSERT_DECLARE(DEFAULT_PDU_QUEUE)
+MAGIC_ASSERT_DECLARE(ISCSI_CONNECTION)
+MAGIC_ASSERT_DECLARE(ISCSI_WRB_QUEUE)
+/* Shorter names */
+#define ISCSI_CXN_ASSERT  ISCSI_CONNECTION_ASSERT #define 
+ISCSI_WRBQ_ASSERT ISCSI_WRB_QUEUE_ASSERT #define ISCSI_DEFQ_ASSERT 
+DEFAULT_PDU_QUEUE_ASSERT
+/* Include the srcgen API. */
+#include "beclib_ll_enum_nic.h"
+#include "beclib_ll_bmap_nic.h"
+/*
+ * ----------------------------------------------------------------------
+ *   API MACROS
+ * 
+----------------------------------------------------------------------
+ */
+#define BE_IOCTL_NAME(_short_name_)     IOCTL_##_short_name_
+#define BE_OPCODE_NAME(_short_name_)    OPCODE_##_short_name_
+#define BE_SUBSYSTEM_NAME(_short_name_) SUBSYSTEM_##_short_name_
+
+#define BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(_function_object_, _wrb_, \
+		_short_name_)  \
+	(BE_IOCTL_NAME(_short_name_)*)					\
+	be_function_prepare_embedded_ioctl (				\
+		_function_object_,					\
+		_wrb_,							\
+		sizeof (BE_IOCTL_NAME(_short_name_)),			\
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_));
+
+#define BE_FUNCTION_PREPARE_NONEMBEDDED_IOCTL(_function_object_, _wrb_, \
+				_ioctl_va_, _ioctl_pa_, _short_name_)	\
+	(BE_IOCTL_NAME(_short_name_)*)					\
+	be_function_prepare_nonembedded_ioctl (				\
+		(_function_object_),					\
+		(_wrb_),						\
+		(_ioctl_va_),						\
+		(_ioctl_pa_),						\
+		sizeof (BE_IOCTL_NAME(_short_name_)),			\
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_));
+
+/*
+ * ----------------------------------------------------------------------
+ *   API Inline Functions
+ * 
+----------------------------------------------------------------------
+ * Returns TRUE for the ISCSI function
+ */
+STATIC INLINE
+    boolean be_function_is_iscsi(PBE_FUNCTION_OBJECT function_object) {
+	FUNCTION_ASSERT(function_object);
+	return (function_object->type == BE_FUNCTION_TYPE_ISCSI); }
+
+/* Returns TRUE for the networking function */ STATIC INLINE
+    boolean be_function_is_networking(PBE_FUNCTION_OBJECT 
+function_object) {
+	FUNCTION_ASSERT(function_object);
+	return (function_object->type == BE_FUNCTION_TYPE_NETWORK); }
+
+STATIC INLINE void
+be_function_copy_stats(IN PBE_FUNCTION_OBJECT function_object,
+		       OUT PBECLIB_FUNCTION_STATS stats) {
+	FUNCTION_ASSERT(function_object);
+	ASSERT(stats);
+	sa_memcpy(stats, &function_object->stats,
+		  sizeof(function_object->stats));
+
+}
+
+/* Returns a pointer to the parent chip object for this function. */ 
+STATIC INLINE
+    PBE_CHIP_OBJECT be_function_get_chip_object(PBE_FUNCTION_OBJECT
+						function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return (function_object->parent_chip); }
+
+SA_CPP_TRAILER
+#endif /* __beclib_lower__ */
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/beclib_private_ll.h benet/linux-2.6.24.2/drivers/message/beclib/beclib_private_ll.h
--- orig/linux-2.6.24.2/drivers/message/beclib/beclib_private_ll.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/beclib_private_ll.h	2008-02-14 15:23:07.799207104 +0530
@@ -0,0 +1,451 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#ifndef __beclib_private_h__
+#define __beclib_private_h__
+
+/*
+ * ------------------------------------------------------
+ * Chip Object
+ * ------------------------------------------------------
+ */
+
+void be_chip_lock(IN PBE_CHIP_OBJECT chip_object); void 
+be_chip_unlock(IN PBE_CHIP_OBJECT chip_object);
+
+/*
+ * ------------------------------------------------------
+ *  Function Object
+ * ------------------------------------------------------
+ */
+
+/* Init function object. */
+BESTATUS be_function_create(SA_DEV *sa_dev,	/* previously created device */
+			u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+			PSA_SGL mailbox_sgl,
+			PBE_FUNCTION_OBJECT function_object);
+
+/* Creates one chip object. */
+BESTATUS be_chip_create(OUT PBE_CHIP_OBJECT chip);
+
+/*
+ * Inserts the function object into the chip object.  Both must be 
+previously
+ * created.  This function will initialize the chip during emulation.
+ */
+BESTATUS
+be_chip_insert_function_object(IN PBE_CHIP_OBJECT chip_object,
+			       IN PBE_FUNCTION_OBJECT function_object);
+
+/*
+ * Cleans up the chip object.
+ * This function is called as part of be_function_cleanup.
+ */
+void be_chip_destroy(PBE_CHIP_OBJECT chip);
+
+/*
+ * Destroys the function object.  This assumes that all resources for
+ * this function have already been destroy, and it asserts if that
+ * is not true.
+ * This function is called as part of be_function_cleanup.
+ */
+BESTATUS be_function_destroy(PBE_FUNCTION_OBJECT function_object);
+
+/*
+ * Removes the function object from the chip.
+ * This function is called as part of be_function_cleanup.
+ */
+void
+be_chip_remove_function_object(IN PBE_CHIP_OBJECT chip_object,
+			       IN PBE_FUNCTION_OBJECT function_object);
+
+void _be_function_lock(PBE_FUNCTION_OBJECT fo); void 
+_be_function_unlock(PBE_FUNCTION_OBJECT fo);
+
+void _be_function_add_eq(PBE_FUNCTION_OBJECT fo, PBE_EQ_OBJECT 
+eq_object); void _be_function_remove_eq(PBE_FUNCTION_OBJECT fo,
+			    PBE_EQ_OBJECT eq_object);
+
+void _be_function_add_cq(PBE_FUNCTION_OBJECT fo, PBE_CQ_OBJECT 
+cq_object); void _be_function_remove_cq(PBE_FUNCTION_OBJECT fo,
+			    PBE_CQ_OBJECT cq_object);
+
+void _be_function_add_eth_sq(PBE_FUNCTION_OBJECT fo,
+			     PBE_ETHSQ_OBJECT eth_sq);
+void _be_function_remove_eth_sq(PBE_FUNCTION_OBJECT fo,
+				PBE_ETHSQ_OBJECT eth_sq);
+
+void _be_function_add_eth_rq(PBE_FUNCTION_OBJECT fo,
+			     PBE_ETHRQ_OBJECT eth_rq);
+void _be_function_remove_eth_rq(PBE_FUNCTION_OBJECT fo,
+				PBE_ETHRQ_OBJECT eth_rq);
+
+void _be_function_add_mcc(PBE_FUNCTION_OBJECT fo, PBE_MCC_OBJECT mcc); 
+void _be_function_remove_mcc(PBE_FUNCTION_OBJECT fo, PBE_MCC_OBJECT 
+mcc);
+
+void _be_function_add_iscsi_connection(PBE_FUNCTION_OBJECT fo,
+				       PBE_ISCSI_CONNECTION_OBJECT
+				       connection_object);
+void _be_function_remove_iscsi_connection(PBE_FUNCTION_OBJECT fo,
+					  PBE_ISCSI_CONNECTION_OBJECT
+					  connection_object);
+PBE_ISCSI_CONNECTION_OBJECT
+_be_function_find_iscsi_connection(PBE_FUNCTION_OBJECT fo, u32 cid);
+
+void _be_function_add_wrbq(PBE_FUNCTION_OBJECT funcobj,
+			   PBE_ISCSI_WRB_QUEUE_OBJECT wrbq); void 
+_be_function_remove_wrbq(PBE_FUNCTION_OBJECT funcobj,
+			      PBE_ISCSI_WRB_QUEUE_OBJECT wrbq);
+
+void _be_function_add_default_pdu_queue(PBE_FUNCTION_OBJECT func_obj,
+					PBE_DEFAULT_PDU_QUEUE_OBJECT defq); void 
+_be_function_remove_default_pdu_queue(PBE_FUNCTION_OBJECT func_obj,
+					   PBE_DEFAULT_PDU_QUEUE_OBJECT
+					   defq);
+
+u32 _be_function_reference(PBE_FUNCTION_OBJECT fo);
+u32 _be_function_dereference(PBE_FUNCTION_OBJECT fo);
+
+BESTATUS
+be_function_ring_destroy(PBE_FUNCTION_OBJECT function_object,
+			 u32 id, u32 ring_type);
+
+BESTATUS
+be_function_ring_destroy_async(PBE_FUNCTION_OBJECT function_object,
+			       u32 id,
+			       u32 ring_type,
+			       MCC_WRB_CQE_CALLBACK callback,
+			       PVOID callback_context,
+			       MCC_WRB_CQE_CALLBACK internal_callback,
+			       PVOID internal_callback_context);
+
+#define BE_CREATE_MCC_RESPONSE_COPY(_ioctl_type_, _field_, _va_)           \
+	be_create_mcc_response_copy(SA_FIELD_OFFSET(_ioctl_type_, _field_),  \
+		SA_SIZEOF_FIELD(_ioctl_type_, _field_),  \
+			(_va_))                                   \
+
+STATIC INLINE
+    BE_MCC_WRB_RESPONSE_COPY
+be_create_mcc_response_copy(u16 offset, u16 length, PVOID va) {
+	BE_MCC_WRB_RESPONSE_COPY rc;
+	rc.length = length;
+	rc.ioctl_offset = offset;
+	rc.va = va;
+	return rc;
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_queue_context(IN PBE_FUNCTION_OBJECT
+					    function_object,
+					    IN PMCC_WRB wrb,
+					    IN PBE_GENERIC_QUEUE_CONTEXT
+					    queue_context,
+					    IN MCC_WRB_CQE_CALLBACK
+					    callback,
+					    IN PVOID callback_context,
+					    IN PVOID optional_ioctl_va);
+
+BESTATUS
+be_function_post_mcc_wrb_with_copy(IN PBE_FUNCTION_OBJECT function_object,
+				   IN PMCC_WRB wrb,
+				   IN PBE_GENERIC_QUEUE_CONTEXT
+				   queue_context,
+				   IN MCC_WRB_CQE_CALLBACK callback,
+				   IN PVOID callback_context,
+				   IN PVOID optional_ioctl_va,
+				   IN BE_MCC_WRB_RESPONSE_COPY
+				   response_copy);
+
+BESTATUS
+be_function_post_mcc_wrb_with_internal_callback(IN PBE_FUNCTION_OBJECT
+						function_object,
+						IN PMCC_WRB wrb,
+						IN
+						PBE_GENERIC_QUEUE_CONTEXT
+						queue_context,
+						IN MCC_WRB_CQE_CALLBACK
+						callback,
+						IN PVOID callback_context,
+						IN MCC_WRB_CQE_CALLBACK
+						internal_callback,
+						IN PVOID
+						internal_callback_context,
+						IN PVOID
+						optional_ioctl_va);
+
+BESTATUS
+be_function_post_mcc_wrb_complete(IN PBE_FUNCTION_OBJECT function_object,
+				  IN PMCC_WRB wrb,
+				  IN PBE_GENERIC_QUEUE_CONTEXT
+				  queue_context,
+				  IN MCC_WRB_CQE_CALLBACK callback,
+				  IN PVOID callback_context,
+				  IN MCC_WRB_CQE_CALLBACK
+				  internal_callback,
+				  IN PVOID internal_callback_context,
+				  IN PVOID optional_ioctl_va,
+				  IN BE_MCC_WRB_RESPONSE_COPY
+				  response_copy);
+
+/* Returns the protection domain number. 0 is host. */
+u32 be_function_get_pd_number(PBE_FUNCTION_OBJECT function_object);
+
+boolean be_function_is_vm(PBE_FUNCTION_OBJECT function_object);
+
+BESTATUS
+be_function_queue_mcc_wrb(PBE_FUNCTION_OBJECT function_object,
+			  PBE_GENERIC_QUEUE_CONTEXT queue_context);
+
+BESTATUS
+be_function_internal_query_firmware_config(IN PBE_FUNCTION_OBJECT
+					   function_object,
+					   OUT BE_FIRMWARE_CONFIG *
+					   config);
+
+/*
+ * ------------------------------------------------------
+ *  Event Queue
+ * ------------------------------------------------------
+ */
+
+void _be_eq_add_cq(PBE_EQ_OBJECT eq_object, PBE_CQ_OBJECT cq_object); 
+void _be_eq_remove_cq(PBE_EQ_OBJECT eq_object, PBE_CQ_OBJECT 
+cq_object);
+
+u32 be_eq_reference(PBE_EQ_OBJECT cq_object);
+u32 be_eq_dereference(PBE_EQ_OBJECT cq_object);
+
+/* Deprecate.... */
+EQ_CALLBACK
+be_eq_set_callback(IN PBE_EQ_OBJECT eq_object,
+		   IN EQ_CALLBACK callback, IN PVOID context);
+
+/* Deprecate... */
+void
+be_eq_delegate_processing(IN PBE_FUNCTION_OBJECT function_object,
+			  IN u32 eq_id);
+
+/*
+ * ------------------------------------------------------
+ *  Completion Queue Object
+ * ------------------------------------------------------
+ */
+
+u32 be_cq_object_reference(PBE_CQ_OBJECT cq_object);
+
+u32 be_cq_object_dereference(PBE_CQ_OBJECT cq_object);
+
+/* Deprecate.... */
+CQ_CALLBACK
+be_cq_object_set_callback(IN PBE_CQ_OBJECT cq_object,
+			  IN CQ_CALLBACK callback, IN PVOID context);
+
+/* Deprecate.... */
+void
+be_cq_object_delegate_processing(PBE_FUNCTION_OBJECT function_object,
+				 u32 cq_id);
+
+/*
+ * ------------------------------------------------------
+ *  MCC QUEUE
+ * ------------------------------------------------------
+ */
+
+BESTATUS
+be_mpu_init_mailbox(IN PBE_FUNCTION_OBJECT function_object,
+		    IN PSA_SGL mailbox);
+
+BESTATUS be_mpu_uninit_mailbox(IN PBE_FUNCTION_OBJECT function_object);
+
+PMCC_WRB
+_be_mpu_peek_ring_wrb(IN PBE_MCC_OBJECT mcc, IN boolean driving_queue);
+
+PBE_MCC_WRB_CONTEXT
+_be_mcc_allocate_wrb_context(PBE_FUNCTION_OBJECT function_object);
+
+void
+_be_mcc_free_wrb_context(PBE_FUNCTION_OBJECT function_object,
+			 PBE_MCC_WRB_CONTEXT context);
+
+BESTATUS
+_be_mpu_post_wrb_mailbox(IN PBE_FUNCTION_OBJECT function_object,
+			 IN PMCC_WRB wrb,
+			 IN PBE_MCC_WRB_CONTEXT wrb_context);
+
+BESTATUS
+_be_mpu_post_wrb_ring(IN PBE_MCC_OBJECT mcc,
+		      IN PMCC_WRB wrb, IN PBE_MCC_WRB_CONTEXT wrb_context);
+
+void
+be_mcc_process_cqe(IN PBE_FUNCTION_OBJECT function_object,
+		   IN PMCC_CQ_ENTRY cqe);
+
+u32 be_mcc_get_id(PBE_MCC_OBJECT mcc);
+
+void be_drive_mcc_wrb_queue(IN PBE_MCC_OBJECT mcc);
+
+/*
+ * ------------------------------------------------------
+ *  iSCSI connection
+ * ------------------------------------------------------
+ */
+
+BESTATUS
+be_iscsi_cxn_create(PBE_FUNCTION_OBJECT function_object,
+		    IN PBE_ISCSI_WRB_QUEUE_OBJECT wrbq,
+		    IN PBE_DEFAULT_PDU_QUEUE_OBJECT defq,
+		    IN PBE_CQ_OBJECT cq,
+		    OUT PBE_ISCSI_CONNECTION_OBJECT cxn);
+
+void be_iscsi_cxn_destroy(PBE_ISCSI_CONNECTION_OBJECT cxn);
+
+/*
+ * ------------------------------------------------------
+ *  Ring Sizes
+ * ------------------------------------------------------
+ */
+STATIC INLINE u32 be_ring_encoding_to_length(u32 encoding, u32 
+object_size) {
+
+	ASSERT(encoding != 1);	/* 1 is rsvd */
+	ASSERT(encoding < 16);
+	ASSERT(object_size > 0);
+
+	if (encoding == 0)	/* 32k deep */
+		encoding = 16;
+
+	return (1 << (encoding - 1)) * object_size; }
+
+STATIC INLINE
+    u32 be_ring_length_to_encoding(u32 length_in_bytes, u32 
+object_size) {
+
+	u32 count, encoding;
+
+	ASSERT(object_size > 0);
+	ASSERT(length_in_bytes % object_size == 0);
+
+	count = length_in_bytes / object_size;
+
+	ASSERT(count > 1);
+	ASSERT(count <= 32 * 1024);
+	ASSERT(length_in_bytes <= 8 * SA_PAGE_SIZE); /* max ring size in UT */
+
+	encoding = sa_log2(count) + 1;
+
+	if (encoding == 16)
+		encoding = 0;	/* 32k deep */
+
+	return encoding;
+}
+
+/*
+ * ------------------------------------------------------
+ *  Locking
+ * ------------------------------------------------------
+ */
+
+/* Init, acquire, or release a lock at any IRQL */ STATIC INLINE void 
+be_lock_init(BE_LOCK *lock) {
+	sa_init_spinlock(&lock->lock);
+}
+
+STATIC INLINE void be_lock_acquire(IN BE_LOCK *lock) {
+	sa_acquire_spinlock(&lock->lock, &lock->irql); }
+
+STATIC INLINE void be_lock_release(IN BE_LOCK *lock) {
+	sa_release_spinlock(&lock->lock, &lock->irql); }
+
+/*
+ * Init, acquire, or release a blocking lock at IRQL<DISPATH_LEVEL.
+ * TODO - These may need to be implemented with spinlocks on some 
+platforms,
+ * hence this extra layer of abstraction.
+ */
+STATIC INLINE void be_blocking_lock_init(IN BE_BLOCKING_LOCK *lock) {
+	sa_initialize_fast_mutex(lock);
+}
+
+STATIC INLINE void be_blocking_lock_acquire(IN BE_BLOCKING_LOCK *lock) 
+{
+	SA_NOT_USED(lock);
+}
+
+STATIC INLINE void be_blocking_lock_release(IN BE_BLOCKING_LOCK *lock) 
+{
+	SA_NOT_USED(lock);
+	/*sa_release_fast_mutex(lock); */
+}
+
+STATIC INLINE void be_lock_wrb_post(PBE_FUNCTION_OBJECT 
+function_object) {
+	FUNCTION_ASSERT(function_object);
+	sa_acquire_spinlock(&function_object->post_lock,
+			    &function_object->post_irq);
+}
+
+STATIC INLINE void be_unlock_wrb_post(PBE_FUNCTION_OBJECT 
+function_object) {
+	FUNCTION_ASSERT(function_object);
+	sa_release_spinlock(&function_object->post_lock,
+			    &function_object->post_irq);
+
+	if (function_object->pend_queue_driving
+	    && function_object->links.mcc) {
+		function_object->pend_queue_driving = 0;
+		function_object->stats.pended_queue_driving++;
+		be_drive_mcc_wrb_queue(function_object->links.mcc);
+	}
+}
+
+STATIC INLINE void be_lock_cq_process(PBE_FUNCTION_OBJECT 
+function_object) {
+	FUNCTION_ASSERT(function_object);
+	sa_acquire_spinlock(&function_object->cq_lock,
+			    &function_object->cq_irq);
+}
+
+STATIC INLINE void be_unlock_cq_process(PBE_FUNCTION_OBJECT
+					function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	sa_release_spinlock(&function_object->cq_lock,
+			    &function_object->cq_irq);
+}
+
+void be_sgl_to_pa_list(PSA_SGL sgl, PHYS_ADDR *pa_list, u32 max_num);
+
+#endif /* __beclib_private_h__ */
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/beclib_stats.h benet/linux-2.6.24.2/drivers/message/beclib/beclib_stats.h
--- orig/linux-2.6.24.2/drivers/message/beclib/beclib_stats.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/beclib_stats.h	2008-02-14 15:23:07.799207104 +0530
@@ -0,0 +1,73 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#ifndef __beclib_stats_h__
+#define __beclib_stats_h__
+
+typedef struct _BECLIB_FUNCTION_STATS {
+
+	union {
+
+		u32 dw[32];	/* Reserve space for a fixed number of stats. */
+
+		struct {
+			u32 mailbox_wrbs;
+			u32 emulated_wrbs;
+
+			/* Pertain to WRBs posted to ring only */
+			u32 synchronous_wrbs;
+			u32 posted_wrbs;
+			u32 consumed_wrbs;
+			u32 completed_wrbs;
+
+			/* SW queueing */
+			u32 queued_wrbs;
+			u32 queue_length;
+			u32 max_queue_length;
+			u32 pended_queue_driving;
+
+			/* MCC CQ */
+			u32 processed_cq;
+			u32 cq_entries;
+			u32 async_events;
+			u32 ignored_async_events;
+
+			/* Locks */
+			u32 post_lock_acquires;
+			u32 cq_lock_acquires;
+			u64 post_lock_ticks;
+			u64 cq_lock_ticks;
+		};
+	};
+
+} BECLIB_FUNCTION_STATS, *PBECLIB_FUNCTION_STATS;
+
+#endif /* __beclib_stats_h__ */
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/beclib_ll_enum_nic.h benet/linux-2.6.24.2/drivers/message/beclib/beclib_ll_enum_nic.h
--- orig/linux-2.6.24.2/drivers/message/beclib/beclib_ll_enum_nic.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/beclib_ll_enum_nic.h	2008-02-14 15:23:07.799207104 +0530
@@ -0,0 +1,68 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+/*
+ * Autogenerated by srcgen version: 0127  */ #ifndef 
+__beclib_ll_enum_h__ #define __beclib_ll_enum_h__ #include "setypes.h"
+
+#ifndef SG_STATIC_INLINE
+#define SG_STATIC_INLINE static inline
+#endif
+
+/* --- BE_FUNCTION_ENUM --- */
+#define BE_FUNCTION_TYPE_ISCSI          (0)
+#define BE_FUNCTION_TYPE_NETWORK        (1)
+#define BE_FUNCTION_TYPE_ARM            (2)
+
+typedef enum {
+	ENUM_BE_FUNCTION_TYPE_ISCSI = 0x0UL,
+	ENUM_BE_FUNCTION_TYPE_NETWORK = 0x1UL,
+	ENUM_BE_FUNCTION_TYPE_ARM = 0x2UL
+} BE_FUNCTION_ENUM;
+
+/* --- BE_ETH_TX_RING_TYPE_ENUM --- */
+#define BE_ETH_TX_RING_TYPE_FORWARDING  (1) 	/* Ether ring for forwarding */
+#define BE_ETH_TX_RING_TYPE_STANDARD    (2)	/* Ether ring for sending */
+						/* network packets. */
+#define BE_ETH_TX_RING_TYPE_BOUND       (3)	/* Ethernet ring for sending */
+						/* network packets, bound */
+						/* to a physical port. */
+
+typedef enum {
+	ENUM_BE_ETH_TX_RING_TYPE_FORWARDING = 0x1UL,
+	ENUM_BE_ETH_TX_RING_TYPE_STANDARD = 0x2UL,
+	ENUM_BE_ETH_TX_RING_TYPE_BOUND = 0x3UL } BE_ETH_TX_RING_TYPE_ENUM;
+
+#endif /* __beclib_ll_enum_h__ */

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

