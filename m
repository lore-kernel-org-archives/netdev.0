From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 5/15] BE NIC driver - beclib headers
Date: Thu, 15 May 2008 02:15:53 -0700
Message-ID: <20080515091553.7d2df2a1@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:41138 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbYEOJLN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:11:13 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Thu, 15 May 2008 02:15:53 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/beclib_private_ll.h |  395 ++++++++++++++++++++++++++++
 drivers/message/beclib/beclib_stats.h      |   69 +++++
 drivers/message/beclib/beregister.h        |  361 +++++++++++++++++++++++++
 drivers/message/beclib/bestatus.h          |  129 +++++++++
 drivers/message/beclib/pch.h               |   58 ++++
 5 files changed, 1012 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/beclib_private_ll.h
 create mode 100644 drivers/message/beclib/beclib_stats.h
 create mode 100644 drivers/message/beclib/beregister.h
 create mode 100644 drivers/message/beclib/bestatus.h
 create mode 100644 drivers/message/beclib/pch.h

diff --git a/drivers/message/beclib/beclib_private_ll.h b/drivers/message/beclib/beclib_private_ll.h
new file mode 100644
index 0000000..0718c99
--- /dev/null
+++ b/drivers/message/beclib/beclib_private_ll.h
@@ -0,0 +1,395 @@
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
+void be_chip_lock(struct BE_CHIP_OBJECT *chip_object);
+void be_chip_unlock(struct BE_CHIP_OBJECT *chip_object);
+
+/*
+ * ------------------------------------------------------
+ *  Function Object
+ * ------------------------------------------------------
+ */
+
+/* Init function object. */
+BESTATUS be_function_create(struct SA_DEV *sa_dev,
+			u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+			struct SA_SGL *mailbox_sgl,
+			struct BE_FUNCTION_OBJECT *pfob);
+
+/* Creates one chip object. */
+BESTATUS be_chip_create(struct BE_CHIP_OBJECT *chip);
+
+/*
+ * Inserts the function object into the chip object.  Both must be previously
+ * created.  This function will initialize the chip during emulation.
+ */
+BESTATUS
+be_chip_insert_function_object(struct BE_CHIP_OBJECT *chip_object,
+			       struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ * Cleans up the chip object.
+ * This function is called as part of be_function_cleanup.
+ */
+void be_chip_destroy(struct BE_CHIP_OBJECT *chip);
+
+/*
+ * Destroys the function object.  This assumes that all resources for
+ * this function have already been destroy, and it asserts if that
+ * is not true.
+ * This function is called as part of be_function_cleanup.
+ */
+BESTATUS be_function_destroy(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ * Removes the function object from the chip.
+ * This function is called as part of be_function_cleanup.
+ */
+void
+be_chip_remove_function_object(struct BE_CHIP_OBJECT *chip_object,
+			       struct BE_FUNCTION_OBJECT *pfob);
+
+void _be_function_lock(struct BE_FUNCTION_OBJECT *fo);
+void _be_function_unlock(struct BE_FUNCTION_OBJECT *fo);
+
+void _be_function_add_eq(struct BE_FUNCTION_OBJECT *fo,
+				struct BE_EQ_OBJECT *eq_object);
+void _be_function_remove_eq(struct BE_FUNCTION_OBJECT *fo,
+			    struct BE_EQ_OBJECT *eq_object);
+
+void _be_function_add_cq(struct BE_FUNCTION_OBJECT *fo,
+					struct BE_CQ_OBJECT *cq_object);
+void _be_function_remove_cq(struct BE_FUNCTION_OBJECT *fo,
+			    struct BE_CQ_OBJECT *cq_object);
+
+void _be_function_add_eth_sq(struct BE_FUNCTION_OBJECT *fo,
+			     struct BE_ETHSQ_OBJECT *eth_sq);
+void _be_function_remove_eth_sq(struct BE_FUNCTION_OBJECT *fo,
+				struct BE_ETHSQ_OBJECT *eth_sq);
+
+void _be_function_add_eth_rq(struct BE_FUNCTION_OBJECT *fo,
+			     struct BE_ETHRQ_OBJECT *eth_rq);
+void _be_function_remove_eth_rq(struct BE_FUNCTION_OBJECT *fo,
+				struct BE_ETHRQ_OBJECT *eth_rq);
+
+void _be_function_add_mcc(struct BE_FUNCTION_OBJECT *fo,
+					struct BE_MCC_OBJECT *mcc);
+void _be_function_remove_mcc(struct BE_FUNCTION_OBJECT *fo,
+					struct BE_MCC_OBJECT *mcc);
+
+void _be_function_add_iscsi_connection(struct BE_FUNCTION_OBJECT *fo,
+		       struct BE_ISCSI_CONNECTION_OBJECT *connection_object);
+void _be_function_remove_iscsi_connection(struct BE_FUNCTION_OBJECT *fo,
+			  struct BE_ISCSI_CONNECTION_OBJECT *connection_object);
+struct BE_ISCSI_CONNECTION_OBJECT *
+_be_function_find_iscsi_connection(struct BE_FUNCTION_OBJECT *fo, u32 cid);
+
+void _be_function_add_wrbq(struct BE_FUNCTION_OBJECT *funcobj,
+			   struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq);
+void _be_function_remove_wrbq(struct BE_FUNCTION_OBJECT *funcobj,
+			      struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq);
+
+void _be_function_add_default_pdu_queue(struct BE_FUNCTION_OBJECT *func_obj,
+			struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq);
+void _be_function_remove_default_pdu_queue(struct BE_FUNCTION_OBJECT *func_obj,
+			   struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq);
+
+u32 _be_function_reference(struct BE_FUNCTION_OBJECT *fo);
+u32 _be_function_dereference(struct BE_FUNCTION_OBJECT *fo);
+
+BESTATUS
+be_function_ring_destroy(struct BE_FUNCTION_OBJECT *pfob,
+			 u32 id, u32 ring_type);
+
+BESTATUS
+be_function_ring_destroy_async(struct BE_FUNCTION_OBJECT *pfob,
+			       u32 id,
+			       u32 ring_type,
+			       MCC_WRB_CQE_CALLBACK callback,
+			       void *callback_context,
+			       MCC_WRB_CQE_CALLBACK internal_callback,
+			       void *internal_callback_context);
+
+#define BE_CREATE_MCC_RESPONSE_COPY(_ioctl_type_, _field_, _va_)           \
+	be_create_mcc_response_copy(SA_FIELD_OFFSET(_ioctl_type_, _field_),  \
+		SA_SIZEOF_FIELD(_ioctl_type_, _field_),  (_va_))	\
+
+static INLINE
+struct BE_MCC_WRB_RESPONSE_COPY
+be_create_mcc_response_copy(u16 offset, u16 length, void *va)
+{
+	struct BE_MCC_WRB_RESPONSE_COPY rc;
+	rc.length = length;
+	rc.ioctl_offset = offset;
+	rc.va = va;
+	return rc;
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_queue_context(struct BE_FUNCTION_OBJECT
+		*pfob, struct MCC_WRB_AMAP *wrb,
+		struct BE_GENERIC_QUEUE_CONTEXT *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		void *optional_ioctl_va);
+
+BESTATUS
+be_function_post_mcc_wrb_with_copy(struct BE_FUNCTION_OBJECT *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct BE_GENERIC_QUEUE_CONTEXT *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		void *optional_ioctl_va,
+		struct BE_MCC_WRB_RESPONSE_COPY response_copy);
+
+BESTATUS
+be_function_post_mcc_wrb_with_internal_callback(
+		struct BE_FUNCTION_OBJECT *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct BE_GENERIC_QUEUE_CONTEXT *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context,
+		void *optional_ioctl_va);
+
+BESTATUS
+be_function_post_mcc_wrb_complete(struct BE_FUNCTION_OBJECT *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct BE_GENERIC_QUEUE_CONTEXT *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context, void *optional_ioctl_va,
+		struct BE_MCC_WRB_RESPONSE_COPY response_copy);
+
+/* Returns the protection domain number. 0 is host. */
+u32 be_function_get_pd_number(struct BE_FUNCTION_OBJECT *pfob);
+
+bool be_function_is_vm(struct BE_FUNCTION_OBJECT *pfob);
+
+BESTATUS
+be_function_queue_mcc_wrb(struct BE_FUNCTION_OBJECT *pfob,
+			  struct BE_GENERIC_QUEUE_CONTEXT *queue_context);
+
+BESTATUS
+be_function_internal_query_firmware_config(struct BE_FUNCTION_OBJECT *pfob,
+			struct BE_FIRMWARE_CONFIG *config);
+
+/*
+ * ------------------------------------------------------
+ *  Event Queue
+ * ------------------------------------------------------
+ */
+
+void _be_eq_add_cq(struct BE_EQ_OBJECT *eq_object,
+				struct BE_CQ_OBJECT *cq_object);
+void _be_eq_remove_cq(struct BE_EQ_OBJECT *eq_object,
+				struct BE_CQ_OBJECT *cq_object);
+
+u32 be_eq_reference(struct BE_EQ_OBJECT *cq_object);
+u32 be_eq_dereference(struct BE_EQ_OBJECT *cq_object);
+
+/* Deprecate.... */
+EQ_CALLBACK
+be_eq_set_callback(struct BE_EQ_OBJECT *eq_object,
+		   EQ_CALLBACK callback, void *context);
+
+/* Deprecate... */
+void be_eq_delegate_processing(struct BE_FUNCTION_OBJECT *pfob,
+			  u32 eq_id);
+
+/*
+ * ------------------------------------------------------
+ *  Completion Queue Object
+ * ------------------------------------------------------
+ */
+
+u32 be_cq_object_reference(struct BE_CQ_OBJECT *cq_object);
+
+u32 be_cq_object_dereference(struct BE_CQ_OBJECT *cq_object);
+
+/*
+ * ------------------------------------------------------
+ *  MCC QUEUE
+ * ------------------------------------------------------
+ */
+
+BESTATUS
+be_mpu_init_mailbox(struct BE_FUNCTION_OBJECT *pfob,
+		    struct SA_SGL *mailbox);
+
+BESTATUS be_mpu_uninit_mailbox(struct BE_FUNCTION_OBJECT *pfob);
+
+struct MCC_WRB_AMAP *
+_be_mpu_peek_ring_wrb(struct BE_MCC_OBJECT *mcc, bool driving_queue);
+
+struct BE_MCC_WRB_CONTEXT *
+_be_mcc_allocate_wrb_context(struct BE_FUNCTION_OBJECT *pfob);
+
+void
+_be_mcc_free_wrb_context(struct BE_FUNCTION_OBJECT *pfob,
+			 struct BE_MCC_WRB_CONTEXT *context);
+
+BESTATUS
+_be_mpu_post_wrb_mailbox(struct BE_FUNCTION_OBJECT *pfob,
+			 struct MCC_WRB_AMAP *wrb,
+			 struct BE_MCC_WRB_CONTEXT *wrb_context);
+
+BESTATUS
+_be_mpu_post_wrb_ring(struct BE_MCC_OBJECT *mcc,
+	struct MCC_WRB_AMAP *wrb, struct BE_MCC_WRB_CONTEXT *wrb_context);
+
+void
+be_mcc_process_cqe(struct BE_FUNCTION_OBJECT *pfob,
+		   struct MCC_CQ_ENTRY_AMAP *cqe);
+
+u32 be_mcc_get_id(struct BE_MCC_OBJECT *mcc);
+
+void be_drive_mcc_wrb_queue(struct BE_MCC_OBJECT *mcc);
+
+/*
+ * ------------------------------------------------------
+ *  iSCSI connection
+ * ------------------------------------------------------
+ */
+
+BESTATUS
+be_iscsi_cxn_create(struct BE_FUNCTION_OBJECT *pfob,
+		    struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq,
+		    struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq,
+		    struct BE_CQ_OBJECT *cq,
+		    struct BE_ISCSI_CONNECTION_OBJECT *cxn);
+
+void be_iscsi_cxn_destroy(struct BE_ISCSI_CONNECTION_OBJECT *cxn);
+
+/*
+ * ------------------------------------------------------
+ *  Ring Sizes
+ * ------------------------------------------------------
+ */
+static INLINE u32 be_ring_encoding_to_length(u32 encoding, u32 object_size)
+{
+
+	ASSERT(encoding != 1);	/* 1 is rsvd */
+	ASSERT(encoding < 16);
+	ASSERT(object_size > 0);
+
+	if (encoding == 0)	/* 32k deep */
+		encoding = 16;
+
+	return (1 << (encoding - 1)) * object_size;
+}
+
+static INLINE
+u32 be_ring_length_to_encoding(u32 length_in_bytes, u32 object_size)
+{
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
+/* Init, acquire, or release a lock at any IRQL */
+static INLINE void be_lock_init(struct BE_LOCK *lock)
+{
+	sa_init_spinlock(&lock->lock);
+}
+
+static INLINE void be_lock_acquire(struct BE_LOCK *lock)
+{
+	sa_acquire_spinlock(&lock->lock, &lock->irql);
+}
+
+static INLINE void be_lock_release(struct BE_LOCK *lock)
+{
+	sa_release_spinlock(&lock->lock, &lock->irql);
+}
+
+static INLINE void be_lock_wrb_post(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	sa_acquire_spinlock(&pfob->post_lock, &pfob->post_irq);
+}
+
+static INLINE void be_unlock_wrb_post(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	sa_release_spinlock(&pfob->post_lock, &pfob->post_irq);
+
+	if (pfob->pend_queue_driving && pfob->links.mcc) {
+		pfob->pend_queue_driving = 0;
+		pfob->stats.pended_queue_driving++;
+		be_drive_mcc_wrb_queue(pfob->links.mcc);
+	}
+}
+
+static INLINE void be_lock_cq_process(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	sa_acquire_spinlock(&pfob->cq_lock, &pfob->cq_irq);
+}
+
+static INLINE void be_unlock_cq_process(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	sa_release_spinlock(&pfob->cq_lock, &pfob->cq_irq);
+}
+
+void be_sgl_to_pa_list(struct SA_SGL *sgl, struct PHYS_ADDR *pa_list,
+						u32 max_num);
+
+#endif /* __beclib_private_h__ */
diff --git a/drivers/message/beclib/beclib_stats.h b/drivers/message/beclib/beclib_stats.h
new file mode 100644
index 0000000..6785a02
--- /dev/null
+++ b/drivers/message/beclib/beclib_stats.h
@@ -0,0 +1,69 @@
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
+struct BECLIB_FUNCTION_STATS {
+	union {
+		u32 dw[32];	/* Reserve space for a fixed number of stats. */
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
+} ;
+
+#endif /* __beclib_stats_h__ */
diff --git a/drivers/message/beclib/beregister.h b/drivers/message/beclib/beregister.h
new file mode 100644
index 0000000..6d8f8d2
--- /dev/null
+++ b/drivers/message/beclib/beregister.h
@@ -0,0 +1,361 @@
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
+#ifndef __BEREGISTER_H__
+#define __BEREGISTER_H__
+
+/*!
+
+@brief
+    This macro zeros out a data structure whose contents happen to be
+    exactly 32-bits. Many controller registers have bit map structures
+    defined to represent them and this routine allows for easy and correct
+    initialization of the register to 0.
+
+@param
+    reg         - Pointer to the 32-bit structure to zero out.
+
+@return
+
+@note
+    IRQL: any
+
+*/
+
+/*
+ *
+ * Macros for reading/writing a protection domain or CSR registers
+ * in BladeEngine.
+ */
+#define PD_READ(_fo_, _field_)     				\
+	BePdRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	SA_DBG_CSTR(#_field_))
+
+#define PD_WRITE(_fo_, _field_, _value_)			\
+	BePdWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	(_value_).dw[0], SA_DBG_CSTR(#_field_))
+
+#define PD_WRITE_CONST(_fo_, _field_, _value_)			\
+	BePdWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define CSR_READ(_fo_, _field_)				\
+	BeCsrRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	SA_DBG_CSTR(#_field_))				\
+
+#define CSR_WRITE(_fo_, _field_, _value_)			\
+	BeCsrWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	(_value_).dw, SA_DBG_CSTR(#_field_))
+
+#define CSR_WRITE_CONST(_fo_, _field_, _value_)		\
+	BeCsrWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	 (_value_), SA_DBG_CSTR(#_field_))
+/*
+ *
+ * Macros for reading/writing a protection domain or
+ * CSR registers in BladeEngine.
+ */
+#define PCICFG0_READ(_fo_, _field_)				\
+	BePciCfgRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),		\
+	SA_DBG_CSTR(#_field_))
+
+
+#define PCICFG0_WRITE(_fo_, _field_, _value_)                  \
+	BePciCfgWrite((_fo_)->sa_dev,                           \
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),             \
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG0_WRITE_CONST(_fo_, _field_, _value_)		\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_READ(_fo_, _field_)				\
+	BePciCfgRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_WRITE_CONST(_fo_, _field_, _value_)		\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_WRITE(_fo_, _field_, _value_)			\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define RXULP_PD_WRITE(_function_object_, _ulp_number_, _value_)	\
+	switch (_ulp_number_) {						\
+	case 0:								\
+		PD_WRITE((_function_object_), iscsi_default_pdu_db,	\
+			(_value_));					\
+		break;							\
+	case 1:								\
+		PD_WRITE((_function_object_), rdma_rq_db, (_value_));	\
+		break;							\
+	case 2:								\
+		PD_WRITE((_function_object_), tpm_rq_db, (_value_));	\
+		break;							\
+	default:							\
+		BREAKPOINT();						\
+    }									\
+
+
+#define TXULP_PD_WRITE(_function_object_, _ulp_number_, _value_)	\
+	switch (_ulp_number_) {						\
+	case 0:								\
+		PD_WRITE((_function_object_), iscsi_wrb_post_db, (_value_)); \
+		break;							\
+	case 1:								\
+		PD_WRITE((_function_object_), rdma_sq_db, (_value_));	\
+		break;							\
+	case 2:								\
+		PD_WRITE((_function_object_), etx_sq_db, (_value_));	\
+		break;							\
+	default:							\
+		BREAKPOINT();						\
+	    }								\
+
+/*!
+
+@brief
+    This routine reads from a register located within the protection domain
+    doorbell space for a given function object.
+
+@param
+    FuncObj     - Pointer to the function object to read from.
+
+@param
+    Offset      - The Offset(in bytes) to read from within the
+			function's PD space.
+
+@return
+    The value read.
+
+@note
+    IRQL: any
+
+*/
+static INLINE u32
+BePdRead(struct SA_DEV *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 v;
+	ASSERT(offset < sizeof(struct PROTECTION_DOMAIN_DBMAP_AMAP));
+	v = sa_dev_read_u32(sa_dev, sa_get_pd_bar(sa_dev), offset);
+	TRACE(DL_HW, "PD Read.  offset:0x%04x value:0x%08x (%s)", offset,
+	      v, dbg_name);
+	return v;
+}
+
+/*!
+
+@brief
+    This routine writes to a register located within the protection domain
+    doorbell space for a given function object.
+
+@param
+    FuncObj     - Pointer to the function object to read from.
+
+@param
+    Offset      - The Offset (in bytes) to write to within the
+			function's PD space.
+
+@param
+    Value       - The value to write to the register.
+
+@return
+
+@note
+    IRQL: any
+
+*/
+static INLINE void
+BePdWrite(struct SA_DEV *sa_dev,
+	  u32 offset, u32 value, const char *dbg_name)
+{
+	ASSERT(offset < sizeof(struct PROTECTION_DOMAIN_DBMAP_AMAP));
+
+	TRACE(DL_HW, "PD Write. offset:0x%04x value:0x%08x (%s)", offset,
+	      value, dbg_name);
+	sa_dev_write_u32(sa_dev, sa_get_pd_bar(sa_dev), offset, value);
+}
+
+/*!
+
+@brief
+    This routine reads from a register located within the CSR space for a
+    given function object.
+
+@param
+    sa_dev - Context for this set of register space
+
+@param
+    Offset          - The Offset (in bytes) to read from within
+			the function's CSR space.
+
+@return
+    The value read.
+
+@note
+    IRQL: any
+
+*/
+static INLINE u32
+BeCsrRead(struct SA_DEV *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 value;
+	u32 bar;
+
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	bar = sa_get_csr_bar(sa_dev);
+	value = sa_dev_read_u32(sa_dev, bar, offset);
+
+	TRACE(DL_HW, "CSR Read.  offset:0x%04x value:0x%08x (%s)", offset,
+	      value, dbg_name);
+
+	return value;
+}
+
+/*!
+
+@brief
+    This routine writes to a register located within the CSR
+    space for a given function object.
+
+@param
+    sa_dev - Context for this set of register space
+
+@param
+    Offset          - The Offset (in bytes) to write to within
+			the function's CSR space.
+
+@param
+    Value           - The value to write to the register.
+
+@return
+
+@note
+    IRQL: any
+
+*/
+static INLINE void
+BeCsrWrite(struct SA_DEV *sa_dev,
+	   u32 offset, u32 value, const char *dbg_name)
+{
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	TRACE(DL_HW, "CSR Write. offset:0x%04x value:0x%08x (%s)", offset,
+	      value, dbg_name);
+
+	sa_dev_write_u32(sa_dev, sa_get_csr_bar(sa_dev), offset, value);
+}
+
+/*!
+
+@brief
+    This routine reads from a register located within the pci cfg
+    space for a given function object.
+
+@param
+    sa_dev - Context for this set of register space
+
+@param
+    Offset          - The Offset (in bytes) to read from within
+			the function's pci cfg space.
+
+@return
+    The value read.
+
+@note
+    IRQL: any
+
+*/
+static INLINE u32
+BePciCfgRead(struct SA_DEV *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 value;
+
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	value = sa_dev_read_u32(sa_dev, sa_get_pci_bar(sa_dev), offset);
+
+	TRACE(DL_HW, "PCICFG Read.  offset:0x%04x value:0x%08x (%s)",
+	      offset, value, dbg_name);
+
+	return value;
+}
+
+/*!
+
+@brief
+    This routine writes to a register located within the pci cfg
+    space for a given function object.
+
+@param
+    sa_dev - Context for this set of register space
+
+@param
+    Offset          - The Offset (in bytes) to write to within
+		the function's pci cfg space.
+
+@param
+    Value           - The value to write to the register.
+
+@return
+
+@note
+    IRQL: any
+
+*/
+static INLINE void
+BePciCfgWrite(struct SA_DEV *sa_dev,
+	      u32 offset, u32 value, const char *dbg_name)
+{
+
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	TRACE(DL_HW, "PCICFG Write. offset:0x%04x value:0x%08x (%s)",
+	      offset, value, dbg_name);
+
+	sa_dev_write_u32(sa_dev, sa_get_pci_bar(sa_dev), offset, value);
+
+}
+
+#endif /* __BEREGISTER_H__ */
diff --git a/drivers/message/beclib/bestatus.h b/drivers/message/beclib/bestatus.h
new file mode 100644
index 0000000..b2826ac
--- /dev/null
+++ b/drivers/message/beclib/bestatus.h
@@ -0,0 +1,129 @@
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
+#ifndef _BESTATUS_H_
+#define _BESTATUS_H_
+
+#define BE_SUCCESS                      ((SA_STATUS)0x00000000L)
+
+/*
+ * MessageId: BE_PENDING
+ *  The BladeEngine Driver call succeeded, and pended operation.
+ */
+#define BE_PENDING                       ((SA_STATUS)0x20070001L)
+#define BE_STATUS_PENDING                (BE_PENDING)
+
+/*
+ * MessageId: BE_NOT_OK
+ *  An error occurred.
+ */
+#define BE_NOT_OK                        ((SA_STATUS)0xE0070002L)
+
+/*
+ * MessageId: BE_STATUS_SYSTEM_RESOURCES
+ *  Insufficient host system resources exist to complete the API.
+ */
+#define BE_STATUS_SYSTEM_RESOURCES       ((SA_STATUS)0xE0070003L)
+
+/*
+ * MessageId: BE_STATUS_CHIP_RESOURCES
+ *  Insufficient chip resources exist to complete the API.
+ */
+#define BE_STATUS_CHIP_RESOURCES         ((SA_STATUS)0xE0070004L)
+
+/*
+ * MessageId: BE_STATUS_NO_RESOURCE
+ *  Insufficient resources to complete request.
+ */
+#define BE_STATUS_NO_RESOURCE            ((SA_STATUS)0xE0070005L)
+
+/*
+ * MessageId: BE_STATUS_BUSY
+ *  Resource is currently busy.
+ */
+#define BE_STATUS_BUSY                   ((SA_STATUS)0xE0070006L)
+
+/*
+ * MessageId: BE_STATUS_INVALID_PARAMETER
+ *  Invalid Parameter in request.
+ */
+#define BE_STATUS_INVALID_PARAMETER      ((SA_STATUS)0xE0000007L)
+
+/*
+ * MessageId: BE_STATUS_NOT_SUPPORTED
+ *  Requested operation is not supported.
+ */
+#define BE_STATUS_NOT_SUPPORTED          ((SA_STATUS)0xE000000DL)
+
+/*
+ * ***************************************************************************
+ *                     E T H E R N E T   S T A T U S
+ * ***************************************************************************
+ */
+
+/*
+ * MessageId: BE_ETH_TX_ERROR
+ *  The Ethernet device driver failed to transmit a packet.
+ */
+#define BE_ETH_TX_ERROR                  ((SA_STATUS)0xE0070101L)
+
+/*
+ * ***************************************************************************
+ *                     S H A R E D   S T A T U S
+ * ***************************************************************************
+ */
+
+/*
+ * MessageId: BE_STATUS_VBD_INVALID_VERSION
+ *  The device driver is not compatible with this version of the VBD.
+ */
+#define BE_STATUS_INVALID_VERSION    ((SA_STATUS)0xE0070402L)
+
+/*
+ * MessageId: BE_STATUS_DOMAIN_DENIED
+ *  The operation failed to complete due to insufficient access
+ *  rights for the requesting domain.
+ */
+#define BE_STATUS_DOMAIN_DENIED          ((SA_STATUS)0xE0070403L)
+
+/*
+ * MessageId: BE_STATUS_TCP_NOT_STARTED
+ *  The embedded TCP/IP stack has not been started.
+ */
+#define BE_STATUS_TCP_NOT_STARTED        ((SA_STATUS)0xE0070409L)
+
+/*
+ * MessageId: BE_STATUS_NO_MCC_WRB
+ *  No free MCC WRB are available for posting the request.
+ */
+#define BE_STATUS_NO_MCC_WRB                 ((SA_STATUS)0xE0070414L)
+
+#endif /* _BESTATUS_ */
diff --git a/drivers/message/beclib/pch.h b/drivers/message/beclib/pch.h
new file mode 100644
index 0000000..d9288ca
--- /dev/null
+++ b/drivers/message/beclib/pch.h
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
+ * -----------------------------------------------------------------------
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
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

