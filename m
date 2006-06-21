From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 4/6] ehea: main header files
Date: Wed, 21 Jun 2006 14:41:20 +0200
Message-ID: <44993E70.2010000@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:49891 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751215AbWFUMlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:41:22 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5LCfL07084308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 12:41:21 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LCge6D141296
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:42:40 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LCfKHb030887
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:41:21 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/ehea/ehea.h    |  434 +++++++++++++++++++++++++++++++++++++++++++++
  drivers/net/ehea/ehea_hw.h |  319 +++++++++++++++++++++++++++++++++
  2 files changed, 753 insertions(+)



--- linux-2.6.17.1-orig/drivers/net/ehea/ehea.h	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/ehea.h	2006-06-21 04:44:50.917370152 -0700
@@ -0,0 +1,434 @@
+/*
+ *  linux/drivers/net/ehea/ehea.h
+ *
+ *  eHEA ethernet device driver for IBM eServer System p
+ *
+ *  (C) Copyright IBM Corp. 2006
+ *
+ *  Authors:
+ *       Christoph Raisch <raisch@de.ibm.com>
+ *       Jan-Bernd Themann <themann@de.ibm.com>
+ *       Heiko-Joerg Schick <schickhj@de.ibm.com>
+ *       Thomas Klein <tklein@de.ibm.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef __EHEA_H__
+#define __EHEA_H__
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/kernel.h>
+#include <linux/vmalloc.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/err.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/kthread.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <asm/ibmebus.h>
+#include <asm/of_device.h>
+#include <asm/abs_addr.h>
+#include <asm/semaphore.h>
+#include <asm/current.h>
+#include <asm/io.h>
+
+
+#define EHEA_DRIVER_NAME	"IBM eHEA"
+#define EHEA_DRIVER_VERSION	"EHEA_0007"
+
+/* #define EHEA_CQE_TIMER */
+ #define EHEA_ADDITIONAL_STATISTICS
+
+#ifdef EHEA_SMALL_QUEUES
+#define EHEA_MAX_CQE_COUNT     1020
+#define EHEA_MAX_ENTRIES_SQ    1020
+#define EHEA_MAX_ENTRIES_RQ1   4080
+#define EHEA_MAX_ENTRIES_RQ2   1020
+#define EHEA_MAX_ENTRIES_RQ3   1020
+#define EHEA_SWQE_REFILL_TH     100
+#else
+#define EHEA_MAX_CQE_COUNT    32000
+#define EHEA_MAX_ENTRIES_SQ   16000
+#define EHEA_MAX_ENTRIES_RQ1  32080
+#define EHEA_MAX_ENTRIES_RQ2   4020
+#define EHEA_MAX_ENTRIES_RQ3   4020
+#define EHEA_SWQE_REFILL_TH    1000
+#endif
+
+#define EHEA_MAX_ENTRIES_EQ       20
+
+#define EHEA_SG_SQ  2
+#define EHEA_SG_RQ1 1
+#define EHEA_SG_RQ2 0
+#define EHEA_SG_RQ3 0
+
+#define EHEA_MAX_PACKET_SIZE    9022	/* for jumbo frame */
+#define EHEA_LL_PKT_SIZE         256
+
+/* Send completion signaling */
+#define EHEA_SIG_IV 1000
+#define EHEA_SIG_IV_LONG 4
+#define EHEA_SQ_HL_TRIGGER 5000
+
+/* Protection Domain Identifier */
+#define EHEA_PD_ID        0xaabcdeff
+
+#define EHEA_RQ2_THRESHOLD         1
+#define EHEA_RQ3_THRESHOLD         5
+
+#define EHEA_SPEED_10G         10000
+#define EHEA_SPEED_1G           1000
+#define EHEA_SPEED_100M          100
+#define EHEA_SPEED_10M            10
+
+/* Broadcast/Multicast registration types */
+#define EHEA_BCMC_SCOPE_ALL	0x08
+#define EHEA_BCMC_SCOPE_SINGLE	0x00
+#define EHEA_BCMC_MULTICAST	0x04
+#define EHEA_BCMC_BROADCAST	0x00
+#define EHEA_BCMC_UNTAGGED	0x02
+#define EHEA_BCMC_TAGGED	0x00
+#define EHEA_BCMC_VLANID_ALL	0x01
+#define EHEA_BCMC_VLANID_SINGLE	0x00
+
+/* Use this define to kmallocate PHYP control blocks */
+#define H_CB_ALIGNMENT		4096
+
+#define EHEA_PAGESHIFT  12
+#define EHEA_PAGESIZE   4096UL
+#define EHEA_PT_ENTRIES 512UL
+#define EHEA_CACHE_LINE 128
+
+#define EHEA_ENABLE	1
+#define EHEA_DISABLE	0
+
+void ehea_set_ethtool_ops(struct net_device *netdev);
+
+#ifndef KEEP_EDEBS_BELOW
+#define KEEP_EDEBS_BELOW 8
+#endif
+
+extern int ehea_trace_level;
+extern struct ehea_adapter *adapter_global;
+
+#ifdef EHEA_NO_EDEB
+#define EDEB_P_GENERIC(level, idstring, format, args...) \
+	while (0 == 1) { \
+	    if(unlikely (level <= ehea_trace_level)) { \
+			printk("%s " idstring " "format "\n", \
+				__func__, ##args); \
+	  } \
+	} \
+
+#else
+
+#define EDEB_P_GENERIC(level,idstring,format,args...) \
+if (level < KEEP_EDEBS_BELOW) { \
+	do { \
+	    if(unlikely (level <= ehea_trace_level)) { \
+			printk("%s " idstring " "format "\n", \
+				__func__, ##args); \
+	  } \
+	} while (1 == 0); \
+}
+#endif
+
+#define EDEB(level, format, args...) \
+        EDEB_P_GENERIC(level, "", format, ##args)
+
+#define EDEB_ERR(level, format, args...) \
+        EDEB_P_GENERIC(level, "EHEA_ERROR", format, ##args)
+
+#define EDEB_EN(level, format, args...) \
+        EDEB_P_GENERIC(level, ">>>", format, ##args)
+
+#define EDEB_EX(level, format, args...) \
+        EDEB_P_GENERIC(level, "<<<", format, ##args)
+
+#define EHEA_BMASK(pos, length) (((pos) << 16) + (length))
+#define EHEA_BMASK_IBM(from, to) (((63 - to) << 16) + ((to) - (from) + 1))
+#define EHEA_BMASK_SHIFTPOS(mask) (((mask) >> 16) & 0xffff)
+#define EHEA_BMASK_MASK(mask) (0xffffffffffffffffULL >> ((64 - (mask)) & 0xffff))
+#define EHEA_BMASK_SET(mask, value) \
+        ((EHEA_BMASK_MASK(mask) & ((u64)(value))) << EHEA_BMASK_SHIFTPOS(mask))
+#define EHEA_BMASK_GET(mask, value) \
+        (EHEA_BMASK_MASK(mask) & (((u64)(value)) >> EHEA_BMASK_SHIFTPOS(mask)))
+
+extern void exit(int);
+
+#define EDEB_DMP(level, adr, len, format, args...) \
+if (level < KEEP_EDEBS_BELOW) { \
+     if(unlikely (level <= ehea_trace_level)) {  \
+        do { \
+                unsigned int x; \
+		unsigned int l = (unsigned int)(len); \
+                unsigned char *deb = (unsigned char*)(adr); \
+		for (x = 0; x < l; x += 16) { \
+		        EDEB(level, format " adr=%p ofs=%04x %016lx %016lx", \
+			     ##args, deb, x, *((u64 *)&deb[0]), \
+			     *((u64 *)&deb[8])); \
+			deb += 16; \
+		} \
+        } while (0); \
+     } \
+}
+
+
+/*
+ * struct generic ehea page
+ */
+struct ipz_page {
+	u8 entries[PAGE_SIZE];
+};
+
+/*
+ * struct generic queue in linux kernel virtual memory
+ */
+struct ipz_queue {
+	u64 current_q_offset;	/* current queue entry */
+	struct ipz_page **queue_pages;	/* array of pages belonging to queue */
+	u32 qe_size;		/* queue entry size */
+	u32 act_nr_of_sg;
+	u32 queue_length;	/* queue length allocated in bytes */
+	u32 pagesize;
+	u32 toggle_state;	/* toggle flag - per page */
+	u32 reserved;		/* 64 bit alignment */
+};
+
+
+/*
+ *  h_galpa:
+ *  for pSeries this is a 64bit memory address where
+ *  I/O memory is mapped into CPU address space
+ */
+
+struct h_galpa {
+	u64 fw_handle;
+};
+
+struct h_galpas {
+	struct h_galpa kernel;	/* kernel space accessible resource,
+				   set to 0 if unused */
+	struct h_galpa user;	/* user space accessible resource
+				   set to 0 if unused */
+	u32 pid;		/* PID of userspace galpa checking */
+};
+
+struct ehea_qp;
+struct ehea_cq;
+struct ehea_eq;
+struct ehea_port;
+struct ehea_av;
+
+struct ehea_qp_init_attr {
+        /* input parameter */
+	u32 qp_token;
+	u8 low_lat_rq1;
+	u8 signalingtype;
+	u8 rq_count;
+	u8 eqe_gen;
+	u16 max_nr_send_wqes;
+	u16 max_nr_rwqes_rq1;
+	u16 max_nr_rwqes_rq2;
+	u16 max_nr_rwqes_rq3;
+	u8 wqe_size_enc_sq;
+	u8 wqe_size_enc_rq1;
+	u8 wqe_size_enc_rq2;
+	u8 wqe_size_enc_rq3;
+	u8 swqe_imm_data_len;
+	u16 port_nr;
+	u16 rq2_threshold;
+	u16 rq3_threshold;
+	u64 send_cq_handle;
+	u64 recv_cq_handle;
+	u64 aff_eq_handle;
+
+        /* output parameter */
+	u32 qp_nr;
+	u16 act_nr_send_wqes;
+	u16 act_nr_rwqes_rq1;
+	u16 act_nr_rwqes_rq2;
+	u16 act_nr_rwqes_rq3;
+	u8 act_wqe_size_enc_sq;
+	u8 act_wqe_size_enc_rq1;
+	u8 act_wqe_size_enc_rq2;
+	u8 act_wqe_size_enc_rq3;
+	u32 nr_sq_pages;
+	u32 nr_rq1_pages;
+	u32 nr_rq2_pages;
+	u32 nr_rq3_pages;
+	u32 liobn_sq;
+	u32 liobn_rq1;
+	u32 liobn_rq2;
+	u32 liobn_rq3;
+};
+
+struct ehea_eq_attr {
+	u32 type;
+	u32 max_nr_of_eqes;
+	u8 eqe_gen;
+	u64 eq_handle;
+	u32 act_nr_of_eqes;
+	u32 nr_pages;
+	u32 ist1;
+	u32 ist2;
+	u32 ist3;
+	u32 ist4;
+};
+
+struct ehea_eq {
+	struct ipz_queue ipz_queue;
+	u64 ipz_eq_handle;
+	struct h_galpas galpas;
+	spinlock_t spinlock;
+	struct ehea_eq_attr attr;
+};
+
+struct ehea_qp {
+	struct ehea_adapter *adapter;
+	u64 ipz_qp_handle;	/* QP handle for h-calls */
+	struct ipz_queue ipz_squeue;
+	struct ipz_queue ipz_rqueue1;
+	struct ipz_queue ipz_rqueue2;
+	struct ipz_queue ipz_rqueue3;
+	struct h_galpas galpas;
+	struct ehea_qp_init_attr init_attr;
+};
+
+struct ehea_cq_attr {
+        /* input parameter */
+	u32 max_nr_of_cqes;
+	u32 cq_token;
+	u64 eq_handle;
+
+        /* output parameter */
+	u32 act_nr_of_cqes;
+	u32 nr_pages;
+};
+
+struct ehea_cq {
+	struct ehea_adapter *adapter;
+	u64 ipz_cq_handle;
+	struct ipz_queue ipz_queue;
+	struct h_galpas galpas;
+	struct ehea_cq_attr attr;
+};
+
+struct ehea_port_res {
+	spinlock_t xmit_lock;
+	struct ehea_port *port;
+	struct ehea_qp *qp;
+	struct ehea_cq *send_cq;
+	struct ehea_cq *recv_cq;
+	struct ehea_eq *send_eq;
+	struct ehea_eq *recv_eq;
+	struct ehea_eq *qp_eq;
+	spinlock_t send_lock;
+	struct sk_buff **skb_arr_rq1;
+	struct sk_buff **skb_arr_rq2;
+	struct sk_buff **skb_arr_rq3;
+	struct sk_buff **skb_arr_sq;
+	int skb_arr_rq1_len;
+	int skb_arr_rq2_len;
+	int skb_arr_rq3_len;
+	int skb_arr_sq_len;
+	int skb_rq2_index;
+	int skb_rq3_index;
+	int skb_sq_index;
+	spinlock_t netif_queue;
+	atomic_t swqe_avail;
+	int swqe_ll_count;
+	int swqe_count;
+	struct tasklet_struct send_comp_task;
+	spinlock_t recv_lock;
+	u32 swqe_id_counter;
+	struct timer_list timer;	/* polling mode, no interrupts */
+	struct timer_list skb_timer;	/* skb cleanup timer */
+};
+
+
+struct ehea_adapter {
+
+	u64 handle;
+	u8 num_ports;
+	struct ehea_port *port[16];
+	struct ehea_eq *neq;
+	struct tasklet_struct neq_tasklet;
+	u32 lkey;
+	u32 pd;
+	u64 mr_handle;
+	u64 max_mc_mac;
+
+};
+
+inline static u32 ehea_get_lkey(struct ehea_adapter *adapter, void *addr)
+{
+	EDEB(8, "ehea_adapter=%p, addr=%p", adapter, addr);
+	EDEB(8, "Lkey returned: %X", adapter->lkey);
+	return adapter->lkey;
+}
+
+struct ehea_mc_list {
+	struct list_head list;
+	u64 macaddr;
+};
+
+struct port_state {
+	int poll_max_processed;
+	int poll_receive_errors;
+	int ehea_poll;
+	int queue_stopped;
+	int min_swqe_avail;
+	u64 sqc_stop_sum;
+	int pkt_send;
+	int pkt_xmit;
+	int send_tasklet;
+	int nwqe;
+};
+
+struct ehea_port {
+	struct ehea_adapter *adapter;	 /* adapter that owns this port */
+	struct net_device *netdev;
+	struct net_device_stats stats;
+	struct port_state p_state;
+	struct ehea_port_res port_res[1];
+	struct device_node *of_dev_node; /* Open Firmware Device Node */
+	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
+	struct vlan_group * vgrp;
+	int allmulti;			 /* Indicates IFF_ALLMULTI state */
+	int promisc;		 	 /* Indicates IFF_PROMISC state */
+
+	char int_recv_name[20];
+	char int_send_name[20];
+	char int_aff_name[20];
+
+	int kernel_l_key;
+	u64 mac_addr;
+	u32 logical_port_id;
+	u32 port_speed;
+	u8 full_duplex;
+	u8 num_def_qps;
+};
+
+
+#endif	/* __EHEA_H__ */
--- linux-2.6.17.1-orig/drivers/net/ehea/ehea_hw.h	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/ehea_hw.h	2006-06-21 04:44:50.135489016 -0700
@@ -0,0 +1,319 @@
+/*
+ *  linux/drivers/net/ehea/ehea_hw.h
+ *
+ *  eHEA ethernet device driver for IBM eServer System p
+ *
+ *  (C) Copyright IBM Corp. 2006
+ *
+ *  Authors:
+ *       Christoph Raisch <raisch@de.ibm.com>
+ *       Jan-Bernd Themann <themann@de.ibm.com>
+ *       Heiko-Joerg Schick <schickhj@de.ibm.com>
+ *       Thomas Klein <tklein@de.ibm.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef __EHEA_HW_H__
+#define __EHEA_HW_H__
+
+#define QPX_SQA_VALUE   EHEA_BMASK_IBM(48,63)
+#define QPX_RQ1A_VALUE  EHEA_BMASK_IBM(48,63)
+#define QPX_RQ2A_VALUE  EHEA_BMASK_IBM(48,63)
+#define QPX_RQ3A_VALUE  EHEA_BMASK_IBM(48,63)
+
+#define QPTEMM_OFFSET(x) offsetof(struct ehea_qptemm, x)
+
+struct ehea_qptemm {
+	u64 qpx_hcr;
+	u64 qpx_c;
+	u64 qpx_herr;
+	u64 qpx_aer;
+	u64 qpx_sqa;
+	u64 qpx_sqc;
+	u64 qpx_rq1a;
+	u64 qpx_rq1c;
+	u64 qpx_st;
+	u64 qpx_aerr;
+	u64 qpx_tenure;
+	u64 qpx_reserved1[(0x098 - 0x058) / 8];
+	u64 qpx_portp;
+	u64 qpx_reserved2[(0x100 - 0x0A0) / 8];
+	u64 qpx_t;
+	u64 qpx_sqhp;
+	u64 qpx_sqptp;
+	u64 qpx_reserved3[(0x140 - 0x118) / 8];
+	u64 qpx_sqwsize;
+	u64 qpx_reserved4[(0x170 - 0x148) / 8];
+	u64 qpx_sqsize;
+	u64 qpx_reserved5[(0x1B0 - 0x178) / 8];
+	u64 qpx_sigt;
+	u64 qpx_wqecnt;
+	u64 qpx_rq1hp;
+	u64 qpx_rq1ptp;
+	u64 qpx_rq1size;
+	u64 qpx_reserved6[(0x220 - 0x1D8) / 8];
+	u64 qpx_rq1wsize;
+	u64 qpx_reserved7[(0x240 - 0x228) / 8];
+	u64 qpx_pd;
+	u64 qpx_scqn;
+	u64 qpx_rcqn;
+	u64 qpx_aeqn;
+	u64 reserved49;
+	u64 qpx_ram;
+	u64 qpx_reserved8[(0x300 - 0x270) / 8];
+	u64 qpx_rq2a;
+	u64 qpx_rq2c;
+	u64 qpx_rq2hp;
+	u64 qpx_rq2ptp;
+	u64 qpx_rq2size;
+	u64 qpx_rq2wsize;
+	u64 qpx_rq2th;
+	u64 qpx_rq3a;
+	u64 qpx_rq3c;
+	u64 qpx_rq3hp;
+	u64 qpx_rq3ptp;
+	u64 qpx_rq3size;
+	u64 qpx_rq3wsize;
+	u64 qpx_rq3th;
+	u64 qpx_lpn;
+	u64 qpx_reserved9[(0x400 - 0x378) / 8];
+	u64 reserved_ext[(0x500 - 0x400) / 8];
+	u64 reserved2[(0x1000 - 0x500) / 8];
+};
+
+#define MRx_HCR_LPARID_VALID EHEA_BMASK_IBM(0, 0)
+
+#define MRMWMM_OFFSET(x) offsetof(struct ehea_mrmwmm, x)
+
+struct ehea_mrmwmm {
+	u64 mrx_hcr;
+	u64 mrx_c;
+	u64 mrx_herr;
+	u64 mrx_aer;
+	u64 mrx_pp;
+	u64 reserved1;
+	u64 reserved2;
+	u64 reserved3;
+	u64 reserved4[(0x200 - 0x40) / 8];
+	u64 mrx_ctl[64];
+};
+
+#define QPEDMM_OFFSET(x) offsetof(struct ehea_qpedmm, x)
+
+struct ehea_qpedmm {
+
+	u64 reserved0[(0x400) / 8];
+	u64 qpedx_phh;
+	u64 qpedx_ppsgp;
+	u64 qpedx_ppsgu;
+	u64 qpedx_ppdgp;
+	u64 qpedx_ppdgu;
+	u64 qpedx_aph;
+	u64 qpedx_apsgp;
+	u64 qpedx_apsgu;
+	u64 qpedx_apdgp;
+	u64 qpedx_apdgu;
+	u64 qpedx_apav;
+	u64 qpedx_apsav;
+	u64 qpedx_hcr;
+	u64 reserved1[4];
+	u64 qpedx_rrl0;
+	u64 qpedx_rrrkey0;
+	u64 qpedx_rrva0;
+	u64 reserved2;
+	u64 qpedx_rrl1;
+	u64 qpedx_rrrkey1;
+	u64 qpedx_rrva1;
+	u64 reserved3;
+	u64 qpedx_rrl2;
+	u64 qpedx_rrrkey2;
+	u64 qpedx_rrva2;
+	u64 reserved4;
+	u64 qpedx_rrl3;
+	u64 qpedx_rrrkey3;
+	u64 qpedx_rrva3;
+};
+
+#define CQX_FECADDER EHEA_BMASK_IBM(32, 63)
+#define CQX_FEC_CQE_CNT EHEA_BMASK_IBM(32, 63)
+#define CQX_N1_GENERATE_COMP_EVENT EHEA_BMASK_IBM(0, 0)
+#define CQX_EP_EVENT_PENDING EHEA_BMASK_IBM(0, 0)
+
+#define CQTEMM_OFFSET(x) offsetof(struct ehea_cqtemm, x)
+
+struct ehea_cqtemm {
+	u64 cqx_hcr;
+	u64 cqx_c;
+	u64 cqx_herr;
+	u64 cqx_aer;
+	u64 cqx_ptp;
+	u64 cqx_tp;
+	u64 cqx_fec;
+	u64 cqx_feca;
+	u64 cqx_ep;
+	u64 cqx_eq;
+	u64 reserved1;
+	u64 cqx_n0;
+	u64 cqx_n1;
+	u64 reserved2[(0x1000 - 0x60) / 8];
+};
+
+#define EQTEMM_OFFSET(x) offsetof(struct ehea_eqtemm, x)
+
+struct ehea_eqtemm {
+	u64 EQx_HCR;
+	u64 EQx_C;
+	u64 EQx_HERR;
+	u64 EQx_AER;
+	u64 EQx_PTP;
+	u64 EQx_TP;
+	u64 EQx_SSBA;
+	u64 EQx_PSBA;
+	u64 EQx_CEC;
+	u64 EQx_MEQL;
+	u64 EQx_XISBI;
+	u64 EQx_XISC;
+	u64 EQx_IT;
+};
+
+static inline u64 hipz_galpa_load(struct h_galpa galpa, u32 offset)
+{
+	u64 addr = galpa.fw_handle + offset;
+	u64 out;
+	EDEB_EN(7, "addr=%lx offset=%x ", addr, offset);
+	out = *(volatile u64 *)addr;
+	EDEB_EX(7, "addr=%lx value=%lx", addr, out);
+	return out;
+};
+
+static inline void hipz_galpa_store(struct h_galpa galpa, u32 offset, u64 value)
+{
+	u64 addr = galpa.fw_handle + offset;
+	EDEB_EN(7, "addr=%lx offset=%x value=%lx", addr, offset,
+		value);
+	*(u64 *) addr = value;
+	hipz_galpa_load(galpa, offset);	/* synchronize explicitly to ehea */
+	EDEB_EX(7, "");
+};
+
+static inline void hipz_galpa_store_acc(struct h_galpa galpa, u32 offset,
+					u64 value)
+{
+	u64 addr = galpa.fw_handle + offset;
+	EDEB(7, "Accelerated store: addr=%lx offset=%x value=%lx",
+	     addr, offset, value);
+	*(u64 *) addr = value;
+};
+
+#define hipz_galpa_store_eq(gal, offset, value)\
+        hipz_galpa_store(gal, EQTEMM_OFFSET(offset), value)
+#define hipz_galpa_load_eq(gal, offset)\
+        hipz_galpa_load(gal, EQTEMM_OFFSET(offset))
+
+#define hipz_galpa_store_cq(gal, offset, value)\
+        hipz_galpa_store(gal, CQTEMM_OFFSET(offset), value)
+#define hipz_galpa_load_cq(gal, offset)\
+        hipz_galpa_load(gal, CQTEMM_OFFSET(offset))
+
+#define hipz_galpa_store_qp(gal, offset, value)\
+        hipz_galpa_store(gal, QPTEMM_OFFSET(offset), value)
+#define hipz_galpa_load_qp(gal, offset)\
+        hipz_galpa_load(gal, QPTEMM_OFFSET(offset))
+
+#define hipz_galpa_store_qped(gal, offset, value)\
+        hipz_galpa_store(gal, QPEDMM_OFFSET(offset), value)
+#define hipz_galpa_load_qped(gal, offset)\
+        hipz_galpa_load(gal, QPEDMM_OFFSET(offset))
+
+#define hipz_galpa_store_mrmw(gal, offset, value)\
+        hipz_galpa_store(gal, MRMWMM_OFFSET(offset), value)
+#define hipz_galpa_load_mrmw(gal, offset)\
+        hipz_galpa_load(gal, MRMWMM_OFFSET(offset))
+
+#define hipz_galpa_store_base(gal, offset, value)\
+        hipz_galpa_store(gal, HCAGR_OFFSET(offset), value)
+#define hipz_galpa_load_base(gal, offset)\
+        hipz_galpa_load(gal, HCAGR_OFFSET(offset))
+
+static inline void ehea_update_sqa(struct ehea_qp *qp, u16 nr_wqes)
+{
+	struct h_galpa gal = qp->galpas.kernel;
+	EDEB_EN(7, "qp=%p, nr_wqes=%d", qp, nr_wqes);
+
+	hipz_galpa_store_acc(gal, QPTEMM_OFFSET(qpx_sqa),
+			     EHEA_BMASK_SET(QPX_SQA_VALUE, nr_wqes));
+	EDEB_EX(7, "qpx_sqa = %i", nr_wqes);
+}
+
+static inline void ehea_update_rq3a(struct ehea_qp *qp, u16 nr_wqes)
+{
+	struct h_galpa gal = qp->galpas.kernel;
+	EDEB_EN(7, "ehea_qp=%p, nr_wqes=%d", qp, nr_wqes);
+	hipz_galpa_store_acc(gal, QPTEMM_OFFSET(qpx_rq3a),
+			     EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
+	EDEB_EX(7, "QPx_RQA = %i", nr_wqes);
+}
+
+static inline void ehea_update_rq2a(struct ehea_qp *qp, u16 nr_wqes)
+{
+	struct h_galpa gal = qp->galpas.kernel;
+	EDEB_EN(7, "ehea_qp=%p, nr_wqes=%d", qp, nr_wqes);
+	hipz_galpa_store_acc(gal, QPTEMM_OFFSET(qpx_rq2a),
+			     EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
+	EDEB_EX(7, "QPx_RQA = %i", nr_wqes);
+}
+
+static inline void ehea_update_rq1a(struct ehea_qp *qp, u16 nr_wqes)
+{
+	struct h_galpa gal = qp->galpas.kernel;
+	EDEB_EN(7, "ehea_qp=%p, nr_wqes=%d", qp, nr_wqes);
+	hipz_galpa_store_acc(gal, QPTEMM_OFFSET(qpx_rq1a),
+			     EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
+	EDEB_EX(7, "QPx_RQA = %i", nr_wqes);
+}
+
+static inline void ehea_update_feca(struct ehea_cq *cq, u32 nr_cqes)
+{
+	struct h_galpa gal = cq->galpas.kernel;
+	EDEB_EN(7, "");
+	hipz_galpa_store_acc(gal, CQTEMM_OFFSET(cqx_feca),
+			     EHEA_BMASK_SET(CQX_FECADDER, nr_cqes));
+	EDEB_EX(7, "cqx_feca = %i", nr_cqes);
+}
+
+static inline void ehea_reset_cq_n1(struct ehea_cq *cq)
+{
+	struct h_galpa gal = cq->galpas.kernel;
+	EDEB_EN(7, "");
+	hipz_galpa_store_cq(gal,
+			    cqx_n1,
+			    EHEA_BMASK_SET(CQX_N1_GENERATE_COMP_EVENT, 1));
+	EDEB_EX(7, "");
+}
+
+static inline void ehea_reset_cq_ep(struct ehea_cq *my_cq)
+{
+	struct h_galpa gal = my_cq->galpas.kernel;
+	EDEB_EN(7, "");
+	hipz_galpa_store_acc(gal,
+			     CQTEMM_OFFSET(cqx_ep),
+			     EHEA_BMASK_SET(CQX_EP_EVENT_PENDING, 0));
+	EDEB_EX(7, "");
+}
+
+
+#endif	/* __EHEA_HW_H__ */

