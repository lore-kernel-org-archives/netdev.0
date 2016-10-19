From: Hannes Reinecke <hare@suse.de>
Subject: Re: [RFC 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Wed, 19 Oct 2016 09:45:07 +0200
Message-ID: <50c821e3-28dc-78b1-8fa4-527a138f1709@suse.de>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-4-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: martin.petersen@oracle.com, jejb@linux.vnet.ibm.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        Yuval.Mintz@cavium.com, QLogic-Storage-Upstream@cavium.com,
        Nilesh Javali <nilesh.javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        Chad Dupuis <chad.dupuis@cavium.com>,
        Saurav Kashyap <saurav.kashyap@cavium.com>,
        Arun Easi <arun.easi@cavium.com>
To: manish.rangankar@cavium.com, lduncan@suse.com, cleech@redhat.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1476853273-22960-4-git-send-email-manish.rangankar@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
> From: Manish Rangankar <manish.rangankar@cavium.com>
> 
> The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
> for 41000 Series Converged Network Adapters by QLogic.
> 
> This patch consists of following changes:
>   - MAINTAINERS Makefile and Kconfig changes for qedi,
>   - PCI driver registration,
>   - iSCSI host level initialization,
>   - Debugfs and log level infrastructure.
> 
> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> ---
>  MAINTAINERS                         |    6 +
>  drivers/net/ethernet/qlogic/Kconfig |   12 -
>  drivers/scsi/Kconfig                |    1 +
>  drivers/scsi/Makefile               |    1 +
>  drivers/scsi/qedi/Kconfig           |   10 +
>  drivers/scsi/qedi/Makefile          |    5 +
>  drivers/scsi/qedi/qedi.h            |  286 +++++++
>  drivers/scsi/qedi/qedi_dbg.c        |  143 ++++
>  drivers/scsi/qedi/qedi_dbg.h        |  144 ++++
>  drivers/scsi/qedi/qedi_debugfs.c    |  244 ++++++
>  drivers/scsi/qedi/qedi_hsi.h        |   52 ++
>  drivers/scsi/qedi/qedi_main.c       | 1550 +++++++++++++++++++++++++++++++++++
>  drivers/scsi/qedi/qedi_sysfs.c      |   52 ++
>  drivers/scsi/qedi/qedi_version.h    |   14 +
>  14 files changed, 2508 insertions(+), 12 deletions(-)
>  create mode 100644 drivers/scsi/qedi/Kconfig
>  create mode 100644 drivers/scsi/qedi/Makefile
>  create mode 100644 drivers/scsi/qedi/qedi.h
>  create mode 100644 drivers/scsi/qedi/qedi_dbg.c
>  create mode 100644 drivers/scsi/qedi/qedi_dbg.h
>  create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
>  create mode 100644 drivers/scsi/qedi/qedi_hsi.h
>  create mode 100644 drivers/scsi/qedi/qedi_main.c
>  create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
>  create mode 100644 drivers/scsi/qedi/qedi_version.h
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5e925a2..906d05f 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9909,6 +9909,12 @@ F:	drivers/net/ethernet/qlogic/qed/
>  F:	include/linux/qed/
>  F:	drivers/net/ethernet/qlogic/qede/
>  
> +QLOGIC QL41xxx ISCSI DRIVER
> +M:	QLogic-Storage-Upstream@cavium.com
> +L:	linux-scsi@vger.kernel.org
> +S:	Supported
> +F:	drivers/scsi/qedi/
> +
>  QNX4 FILESYSTEM
>  M:	Anders Larsen <al@alarsen.net>
>  W:	http://www.alarsen.net/linux/qnx4fs/
> diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
> index bad4fae..28b4366 100644
> --- a/drivers/net/ethernet/qlogic/Kconfig
> +++ b/drivers/net/ethernet/qlogic/Kconfig
> @@ -121,16 +121,4 @@ config INFINIBAND_QEDR
>  config QED_ISCSI
>  	bool
>  
> -config QEDI
> -	tristate "QLogic QED 25/40/100Gb iSCSI driver"
> -	depends on QED
> -	select QED_LL2
> -	select QED_ISCSI
> -	default n
> -	---help---
> -	  This provides a temporary node that allows the compilation
> -	  and logical testing of the hardware offload iSCSI support
> -	  for QLogic QED. This would be replaced by the 'real' option
> -	  once the QEDI driver is added [+relocated].
> -
>  endif # NET_VENDOR_QLOGIC
Huh? You just introduce this one in patch 1/6.
Please fold them together so that this can be omitted.

> diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
> index 3e2bdb9..5cf03db 100644
> --- a/drivers/scsi/Kconfig
> +++ b/drivers/scsi/Kconfig
> @@ -1254,6 +1254,7 @@ config SCSI_QLOGICPTI
>  
>  source "drivers/scsi/qla2xxx/Kconfig"
>  source "drivers/scsi/qla4xxx/Kconfig"
> +source "drivers/scsi/qedi/Kconfig"
>  
>  config SCSI_LPFC
>  	tristate "Emulex LightPulse Fibre Channel Support"
> diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
> index 38d938d..da9e312 100644
> --- a/drivers/scsi/Makefile
> +++ b/drivers/scsi/Makefile
> @@ -132,6 +132,7 @@ obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
>  obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgbi/
>  obj-$(CONFIG_SCSI_CXGB4_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgbi/
>  obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= libiscsi.o bnx2i/
> +obj-$(CONFIG_QEDI)          += libiscsi.o qedi/
>  obj-$(CONFIG_BE2ISCSI)		+= libiscsi.o be2iscsi/
>  obj-$(CONFIG_SCSI_ESAS2R)	+= esas2r/
>  obj-$(CONFIG_SCSI_PMCRAID)	+= pmcraid.o
> diff --git a/drivers/scsi/qedi/Kconfig b/drivers/scsi/qedi/Kconfig
> new file mode 100644
> index 0000000..23ca8a2
> --- /dev/null
> +++ b/drivers/scsi/qedi/Kconfig
> @@ -0,0 +1,10 @@
> +config QEDI
> +	tristate "QLogic QEDI 25/40/100Gb iSCSI Initiator Driver Support"
> +	depends on PCI && SCSI
> +	depends on QED
> +	select SCSI_ISCSI_ATTRS
> +	select QED_LL2
> +	select QED_ISCSI
> +	---help---
> +	This driver supports iSCSI offload for the QLogic FastLinQ
> +	41000 Series Converged Network Adapters.
> diff --git a/drivers/scsi/qedi/Makefile b/drivers/scsi/qedi/Makefile
> new file mode 100644
> index 0000000..2b3e16b
> --- /dev/null
> +++ b/drivers/scsi/qedi/Makefile
> @@ -0,0 +1,5 @@
> +obj-$(CONFIG_QEDI) := qedi.o
> +qedi-y := qedi_main.o qedi_iscsi.o qedi_fw.o qedi_sysfs.o \
> +	    qedi_dbg.o
> +
> +qedi-$(CONFIG_DEBUG_FS) += qedi_debugfs.o
> diff --git a/drivers/scsi/qedi/qedi.h b/drivers/scsi/qedi/qedi.h
> new file mode 100644
> index 0000000..0a5035e
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi.h
> @@ -0,0 +1,286 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +
> +#ifndef _QEDI_H_
> +#define _QEDI_H_
> +
> +#define __PREVENT_QED_HSI__
> +
> +#include <scsi/scsi_transport_iscsi.h>
> +#include <scsi/libiscsi.h>
> +#include <scsi/scsi_host.h>
> +#include <linux/uio_driver.h>
> +
> +#include "qedi_hsi.h"
> +#include <linux/qed/qed_if.h>
> +#include "qedi_dbg.h"
> +#include <linux/qed/qed_iscsi_if.h>
> +#include "qedi_version.h"
> +
> +#define QEDI_MODULE_NAME		"qedi"
> +
> +struct qedi_endpoint;
> +
> +/*
> + * PCI function probe defines
> + */
> +#define QEDI_MODE_NORMAL	0
> +#define QEDI_MODE_RECOVERY	1
> +
> +#define ISCSI_WQE_SET_PTU_INVALIDATE	1
> +#define QEDI_MAX_ISCSI_TASK		4096
> +#define QEDI_MAX_TASK_NUM		0x0FFF
> +#define QEDI_MAX_ISCSI_CONNS_PER_HBA	1024
> +#define QEDI_ISCSI_MAX_BDS_PER_CMD	256	/* Firmware max BDs is 256 */
> +#define MAX_OUSTANDING_TASKS_PER_CON	1024
> +
> +#define QEDI_MAX_BD_LEN		0xffff
> +#define QEDI_BD_SPLIT_SZ	0x1000
> +#define QEDI_PAGE_SIZE		4096
> +#define QEDI_FAST_SGE_COUNT	4
> +/* MAX Length for cached SGL */
> +#define MAX_SGLEN_FOR_CACHESGL	((1U << 16) - 1)
> +
> +#define MAX_NUM_MSIX_PF         8
> +#define MIN_NUM_CPUS_MSIX(x)	min(x->msix_count, num_online_cpus())
> +
> +#define QEDI_LOCAL_PORT_MIN     60000
> +#define QEDI_LOCAL_PORT_MAX     61024
> +#define QEDI_LOCAL_PORT_RANGE   (QEDI_LOCAL_PORT_MAX - QEDI_LOCAL_PORT_MIN)
> +#define QEDI_LOCAL_PORT_INVALID	0xffff
> +
> +/* Queue sizes in number of elements */
> +#define QEDI_SQ_SIZE		MAX_OUSTANDING_TASKS_PER_CON
> +#define QEDI_CQ_SIZE		2048
> +#define QEDI_CMDQ_SIZE		QEDI_MAX_ISCSI_TASK
> +#define QEDI_PROTO_CQ_PROD_IDX	0
> +
> +struct qedi_glbl_q_params {
> +	u64 hw_p_cq;	/* Completion queue PBL */
> +	u64 hw_p_rq;	/* Request queue PBL */
> +	u64 hw_p_cmdq;	/* Command queue PBL */
> +};
> +
> +struct global_queue {
> +	union iscsi_cqe *cq;
> +	dma_addr_t cq_dma;
> +	u32 cq_mem_size;
> +	u32 cq_cons_idx; /* Completion queue consumer index */
> +
> +	void *cq_pbl;
> +	dma_addr_t cq_pbl_dma;
> +	u32 cq_pbl_size;
> +
> +};
> +
> +struct qedi_fastpath {
> +	struct qed_sb_info	*sb_info;
> +	u16			sb_id;
> +#define QEDI_NAME_SIZE		16
> +	char			name[QEDI_NAME_SIZE];
> +	struct qedi_ctx         *qedi;
> +};
> +
> +/* Used to pass fastpath information needed to process CQEs */
> +struct qedi_io_work {
> +	struct list_head list;
> +	struct iscsi_cqe_solicited cqe;
> +	u16	que_idx;
> +};
> +
> +/**
> + * struct iscsi_cid_queue - Per adapter iscsi cid queue
> + *
> + * @cid_que_base:           queue base memory
> + * @cid_que:                queue memory pointer
> + * @cid_q_prod_idx:         produce index
> + * @cid_q_cons_idx:         consumer index
> + * @cid_q_max_idx:          max index. used to detect wrap around condition
> + * @cid_free_cnt:           queue size
> + * @conn_cid_tbl:           iscsi cid to conn structure mapping table
> + *
> + * Per adapter iSCSI CID Queue
> + */
> +struct iscsi_cid_queue {
> +	void *cid_que_base;
> +	u32 *cid_que;
> +	u32 cid_q_prod_idx;
> +	u32 cid_q_cons_idx;
> +	u32 cid_q_max_idx;
> +	u32 cid_free_cnt;
> +	struct qedi_conn **conn_cid_tbl;
> +};
> +
> +struct qedi_portid_tbl {
> +	spinlock_t      lock;	/* Port id lock */
> +	u16             start;
> +	u16             max;
> +	u16             next;
> +	unsigned long   *table;
> +};
> +
> +struct qedi_itt_map {
> +	__le32	itt;
> +};
> +
> +/* I/O tracing entry */
> +#define QEDI_IO_TRACE_SIZE             2048
> +struct qedi_io_log {
> +#define QEDI_IO_TRACE_REQ              0
> +#define QEDI_IO_TRACE_RSP              1
> +	u8 direction;
> +	u16 task_id;
> +	u32 cid;
> +	u32 port_id;	/* Remote port fabric ID */
> +	int lun;
> +	u8 op;		/* SCSI CDB */
> +	u8 lba[4];
> +	unsigned int bufflen;	/* SCSI buffer length */
> +	unsigned int sg_count;	/* Number of SG elements */
> +	u8 fast_sgs;		/* number of fast sgls */
> +	u8 slow_sgs;		/* number of slow sgls */
> +	u8 cached_sgs;		/* number of cached sgls */
> +	int result;		/* Result passed back to mid-layer */
> +	unsigned long jiffies;	/* Time stamp when I/O logged */
> +	int refcount;		/* Reference count for task id */
> +	unsigned int blk_req_cpu; /* CPU that the task is queued on by
> +				   * blk layer
> +				   */
> +	unsigned int req_cpu;	/* CPU that the task is queued on */
> +	unsigned int intr_cpu;	/* Interrupt CPU that the task is received on */
> +	unsigned int blk_rsp_cpu;/* CPU that task is actually processed and
> +				  * returned to blk layer
> +				  */
> +	bool cached_sge;
> +	bool slow_sge;
> +	bool fast_sge;
> +};
> +
> +/* Number of entries in BDQ */
> +#define QEDI_BDQ_NUM		256
> +#define QEDI_BDQ_BUF_SIZE	256
> +
> +/* DMA coherent buffers for BDQ */
> +struct qedi_bdq_buf {
> +	void *buf_addr;
> +	dma_addr_t buf_dma;
> +};
> +
> +/* Main port level struct */
> +struct qedi_ctx {
> +	struct qedi_dbg_ctx dbg_ctx;
> +	struct Scsi_Host *shost;
> +	struct pci_dev *pdev;
> +	struct qed_dev *cdev;
> +	struct qed_dev_iscsi_info dev_info;
> +	struct qed_int_info int_info;
> +	struct qedi_glbl_q_params *p_cpuq;
> +	struct global_queue **global_queues;
> +	/* uio declaration */
> +	struct qedi_uio_dev *udev;
> +	struct list_head ll2_skb_list;
> +	spinlock_t ll2_lock;	/* Light L2 lock */
> +	spinlock_t hba_lock;	/* per port lock */
> +	struct task_struct *ll2_recv_thread;
> +	unsigned long flags;
> +#define UIO_DEV_OPENED		1
> +#define QEDI_IOTHREAD_WAKE	2
> +#define QEDI_IN_RECOVERY	5
> +#define QEDI_IN_OFFLINE		6
> +
> +	u8 mac[ETH_ALEN];
> +	u32 src_ip[4];
> +	u8 ip_type;
> +
> +	/* Physical address of above array */
> +	u64 hw_p_cpuq;
> +
> +	struct qedi_bdq_buf bdq[QEDI_BDQ_NUM];
> +	void *bdq_pbl;
> +	dma_addr_t bdq_pbl_dma;
> +	size_t bdq_pbl_mem_size;
> +	void *bdq_pbl_list;
> +	dma_addr_t bdq_pbl_list_dma;
> +	u8 bdq_pbl_list_num_entries;
> +	void __iomem *bdq_primary_prod;
> +	void __iomem *bdq_secondary_prod;
> +	u16 bdq_prod_idx;
> +	u16 rq_num_entries;
> +
> +	u32 msix_count;
> +	u32 max_sqes;
> +	u8 num_queues;
> +	u32 max_active_conns;
> +
> +	struct iscsi_cid_queue cid_que;
> +	struct qedi_endpoint **ep_tbl;
> +	struct qedi_portid_tbl lcl_port_tbl;
> +
> +	/* Rx fast path intr context */
> +	struct qed_sb_info	*sb_array;
> +	struct qedi_fastpath	*fp_array;
> +	struct qed_iscsi_tid	tasks;
> +
> +#define QEDI_LINK_DOWN		0
> +#define QEDI_LINK_UP		1
> +	atomic_t link_state;
> +
> +#define QEDI_RESERVE_TASK_ID	0
> +#define MAX_ISCSI_TASK_ENTRIES	4096
> +#define QEDI_INVALID_TASK_ID	(MAX_ISCSI_TASK_ENTRIES + 1)
> +	unsigned long task_idx_map[MAX_ISCSI_TASK_ENTRIES / BITS_PER_LONG];
> +	struct qedi_itt_map *itt_map;
> +	u16 tid_reuse_count[QEDI_MAX_ISCSI_TASK];
> +	struct qed_pf_params pf_params;
> +
> +	struct workqueue_struct *tmf_thread;
> +	struct workqueue_struct *offload_thread;
> +
> +	u16 ll2_mtu;
> +
> +	struct workqueue_struct *dpc_wq;
> +
> +	spinlock_t task_idx_lock;	/* To protect gbl context */
> +	s32 last_tidx_alloc;
> +	s32 last_tidx_clear;
> +
> +	struct qedi_io_log io_trace_buf[QEDI_IO_TRACE_SIZE];
> +	spinlock_t io_trace_lock;	/* prtect trace Log buf */
> +	u16 io_trace_idx;
> +	unsigned int intr_cpu;
> +	u32 cached_sgls;
> +	bool use_cached_sge;
> +	u32 slow_sgls;
> +	bool use_slow_sge;
> +	u32 fast_sgls;
> +	bool use_fast_sge;
> +
> +	atomic_t num_offloads;
> +};
> +
> +struct qedi_work {
> +	struct list_head list;
> +	struct qedi_ctx *qedi;
> +	union iscsi_cqe cqe;
> +	u16     que_idx;
> +};
> +
> +struct qedi_percpu_s {
> +	struct task_struct *iothread;
> +	struct list_head work_list;
> +	spinlock_t p_work_lock;		/* Per cpu worker lock */
> +};
> +
> +static inline void *qedi_get_task_mem(struct qed_iscsi_tid *info, u32 tid)
> +{
> +	return (void *)(info->blocks[tid / info->num_tids_per_block] +
> +			(tid % info->num_tids_per_block) * info->size);
> +}
> +
> +#endif /* _QEDI_H_ */
> diff --git a/drivers/scsi/qedi/qedi_dbg.c b/drivers/scsi/qedi/qedi_dbg.c
> new file mode 100644
> index 0000000..2678a15
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi_dbg.c
> @@ -0,0 +1,143 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +
> +#include "qedi_dbg.h"
> +#include <linux/vmalloc.h>
> +
> +void
> +qedi_dbg_err(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
> +	     const char *fmt, ...)
> +{
> +	va_list va;
> +	struct va_format vaf;
> +	char nfunc[32];
> +
> +	memset(nfunc, 0, sizeof(nfunc));
> +	memcpy(nfunc, func, sizeof(nfunc) - 1);
> +
> +	va_start(va, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &va;
> +
> +	if (likely(qedi) && likely(qedi->pdev))
> +		pr_crit("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
> +			nfunc, line, qedi->host_no, &vaf);
> +	else
> +		pr_crit("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
> +
> +	va_end(va);
> +}
> +
> +void
> +qedi_dbg_warn(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
> +	      const char *fmt, ...)
> +{
> +	va_list va;
> +	struct va_format vaf;
> +	char nfunc[32];
> +
> +	memset(nfunc, 0, sizeof(nfunc));
> +	memcpy(nfunc, func, sizeof(nfunc) - 1);
> +
> +	va_start(va, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &va;
> +
> +	if (!(debug & QEDI_LOG_WARN))
> +		return;
> +
> +	if (likely(qedi) && likely(qedi->pdev))
> +		pr_warn("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
> +			nfunc, line, qedi->host_no, &vaf);
> +	else
> +		pr_warn("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
> +
> +	va_end(va);
> +}
> +
> +void
> +qedi_dbg_notice(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
> +		const char *fmt, ...)
> +{
> +	va_list va;
> +	struct va_format vaf;
> +	char nfunc[32];
> +
> +	memset(nfunc, 0, sizeof(nfunc));
> +	memcpy(nfunc, func, sizeof(nfunc) - 1);
> +
> +	va_start(va, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &va;
> +
> +	if (!(debug & QEDI_LOG_NOTICE))
> +		return;
> +
> +	if (likely(qedi) && likely(qedi->pdev))
> +		pr_notice("[%s]:[%s:%d]:%d: %pV",
> +			  dev_name(&qedi->pdev->dev), nfunc, line,
> +			  qedi->host_no, &vaf);
> +	else
> +		pr_notice("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
> +
> +	va_end(va);
> +}
> +
> +void
> +qedi_dbg_info(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
> +	      u32 level, const char *fmt, ...)
> +{
> +	va_list va;
> +	struct va_format vaf;
> +	char nfunc[32];
> +
> +	memset(nfunc, 0, sizeof(nfunc));
> +	memcpy(nfunc, func, sizeof(nfunc) - 1);
> +
> +	va_start(va, fmt);
> +
> +	vaf.fmt = fmt;
> +	vaf.va = &va;
> +
> +	if (!(debug & level))
> +		return;
> +
> +	if (likely(qedi) && likely(qedi->pdev))
> +		pr_info("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
> +			nfunc, line, qedi->host_no, &vaf);
> +	else
> +		pr_info("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
> +
> +	va_end(va);
> +}
> +
> +int
> +qedi_create_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
> +{
> +	int ret = 0;
> +
> +	for (; iter->name; iter++) {
> +		ret = sysfs_create_bin_file(&shost->shost_gendev.kobj,
> +					    iter->attr);
> +		if (ret)
> +			pr_err("Unable to create sysfs %s attr, err(%d).\n",
> +			       iter->name, ret);
> +	}
> +	return ret;
> +}
> +
> +void
> +qedi_remove_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
> +{
> +	for (; iter->name; iter++)
> +		sysfs_remove_bin_file(&shost->shost_gendev.kobj, iter->attr);
> +}
> diff --git a/drivers/scsi/qedi/qedi_dbg.h b/drivers/scsi/qedi/qedi_dbg.h
> new file mode 100644
> index 0000000..5beb3ec
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi_dbg.h
> @@ -0,0 +1,144 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +
> +#ifndef _QEDI_DBG_H_
> +#define _QEDI_DBG_H_
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/compiler.h>
> +#include <linux/string.h>
> +#include <linux/version.h>
> +#include <linux/pci.h>
> +#include <linux/delay.h>
> +#include <scsi/scsi_transport.h>
> +#include <scsi/scsi_transport_iscsi.h>
> +#include <linux/fs.h>
> +
> +#define __PREVENT_QED_HSI__
> +#include <linux/qed/common_hsi.h>
> +#include <linux/qed/qed_if.h>
> +
> +extern uint debug;
> +
> +/* Debug print level definitions */
> +#define QEDI_LOG_DEFAULT	0x1		/* Set default logging mask */
> +#define QEDI_LOG_INFO		0x2		/* Informational logs,
> +						 * MAC address, WWPN, WWNN
> +						 */
> +#define QEDI_LOG_DISC		0x4		/* Init, discovery, rport */
> +#define QEDI_LOG_LL2		0x8		/* LL2, VLAN logs */
> +#define QEDI_LOG_CONN		0x10		/* Connection setup, cleanup */
> +#define QEDI_LOG_EVT		0x20		/* Events, link, mtu */
> +#define QEDI_LOG_TIMER		0x40		/* Timer events */
> +#define QEDI_LOG_MP_REQ		0x80		/* Middle Path (MP) logs */
> +#define QEDI_LOG_SCSI_TM	0x100		/* SCSI Aborts, Task Mgmt */
> +#define QEDI_LOG_UNSOL		0x200		/* unsolicited event logs */
> +#define QEDI_LOG_IO		0x400		/* scsi cmd, completion */
> +#define QEDI_LOG_MQ		0x800		/* Multi Queue logs */
> +#define QEDI_LOG_BSG		0x1000		/* BSG logs */
> +#define QEDI_LOG_DEBUGFS	0x2000		/* debugFS logs */
> +#define QEDI_LOG_LPORT		0x4000		/* lport logs */
> +#define QEDI_LOG_ELS		0x8000		/* ELS logs */
> +#define QEDI_LOG_NPIV		0x10000		/* NPIV logs */
> +#define QEDI_LOG_SESS		0x20000		/* Conection setup, cleanup */
> +#define QEDI_LOG_UIO		0x40000		/* iSCSI UIO logs */
> +#define QEDI_LOG_TID		0x80000         /* FW TID context acquire,
> +						 * free
> +						 */
> +#define QEDI_TRACK_TID		0x100000        /* Track TID state. To be
> +						 * enabled only at module load
> +						 * and not run-time.
> +						 */
> +#define QEDI_TRACK_CMD_LIST    0x300000        /* Track active cmd list nodes,
> +						* done with reference to TID,
> +						* hence TRACK_TID also enabled.
> +						*/
> +#define QEDI_LOG_NOTICE		0x40000000	/* Notice logs */
> +#define QEDI_LOG_WARN		0x80000000	/* Warning logs */
> +
> +/* Debug context structure */
> +struct qedi_dbg_ctx {
> +	unsigned int host_no;
> +	struct pci_dev *pdev;
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *bdf_dentry;
> +#endif
> +};
> +
> +#define QEDI_ERR(pdev, fmt, ...)	\
> +		qedi_dbg_err(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
> +#define QEDI_WARN(pdev, fmt, ...)	\
> +		qedi_dbg_warn(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
> +#define QEDI_NOTICE(pdev, fmt, ...)	\
> +		qedi_dbg_notice(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
> +#define QEDI_INFO(pdev, level, fmt, ...)	\
> +		qedi_dbg_info(pdev, __func__, __LINE__, level, fmt,	\
> +			      ## __VA_ARGS__)
> +
> +void qedi_dbg_err(struct qedi_dbg_ctx *, const char *, u32,
> +		  const char *, ...);
> +void qedi_dbg_warn(struct qedi_dbg_ctx *, const char *, u32,
> +		   const char *, ...);
> +void qedi_dbg_notice(struct qedi_dbg_ctx *, const char *, u32,
> +		     const char *, ...);
> +void qedi_dbg_info(struct qedi_dbg_ctx *, const char *, u32, u32,
> +		   const char *, ...);
> +
> +struct Scsi_Host;
> +
> +struct sysfs_bin_attrs {
> +	char *name;
> +	struct bin_attribute *attr;
> +};
> +
> +int qedi_create_sysfs_attr(struct Scsi_Host *,
> +			   struct sysfs_bin_attrs *);
> +void qedi_remove_sysfs_attr(struct Scsi_Host *,
> +			    struct sysfs_bin_attrs *);
> +
> +#ifdef CONFIG_DEBUG_FS
> +/* DebugFS related code */
> +struct qedi_list_of_funcs {
> +	char *oper_str;
> +	ssize_t (*oper_func)(struct qedi_dbg_ctx *qedi);
> +};
> +
> +struct qedi_debugfs_ops {
> +	char *name;
> +	struct qedi_list_of_funcs *qedi_funcs;
> +};
> +
> +#define qedi_dbg_fileops(drv, ops) \
> +{ \
> +	.owner  = THIS_MODULE, \
> +	.open   = simple_open, \
> +	.read   = drv##_dbg_##ops##_cmd_read, \
> +	.write  = drv##_dbg_##ops##_cmd_write \
> +}
> +
> +/* Used for debugfs sequential files */
> +#define qedi_dbg_fileops_seq(drv, ops) \
> +{ \
> +	.owner = THIS_MODULE, \
> +	.open = drv##_dbg_##ops##_open, \
> +	.read = seq_read, \
> +	.llseek = seq_lseek, \
> +	.release = single_release, \
> +}
> +
> +void qedi_dbg_host_init(struct qedi_dbg_ctx *,
> +			struct qedi_debugfs_ops *,
> +			const struct file_operations *);
> +void qedi_dbg_host_exit(struct qedi_dbg_ctx *);
> +void qedi_dbg_init(char *);
> +void qedi_dbg_exit(void);
> +#endif /* CONFIG_DEBUG_FS */
> +
> +#endif /* _QEDI_DBG_H_ */
> diff --git a/drivers/scsi/qedi/qedi_debugfs.c b/drivers/scsi/qedi/qedi_debugfs.c
> new file mode 100644
> index 0000000..9559362
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi_debugfs.c
> @@ -0,0 +1,244 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +
> +#include "qedi.h"
> +#include "qedi_dbg.h"
> +
> +#include <linux/uaccess.h>
> +#include <linux/debugfs.h>
> +#include <linux/module.h>
> +
> +int do_not_recover;
> +static struct dentry *qedi_dbg_root;
> +
> +void
> +qedi_dbg_host_init(struct qedi_dbg_ctx *qedi,
> +		   struct qedi_debugfs_ops *dops,
> +		   const struct file_operations *fops)
> +{
> +	char host_dirname[32];
> +	struct dentry *file_dentry = NULL;
> +
> +	sprintf(host_dirname, "host%u", qedi->host_no);
> +	qedi->bdf_dentry = debugfs_create_dir(host_dirname, qedi_dbg_root);
> +	if (!qedi->bdf_dentry)
> +		return;
> +
> +	while (dops) {
> +		if (!(dops->name))
> +			break;
> +
> +		file_dentry = debugfs_create_file(dops->name, 0600,
> +						  qedi->bdf_dentry, qedi,
> +						  fops);
> +		if (!file_dentry) {
> +			QEDI_INFO(qedi, QEDI_LOG_DEBUGFS,
> +				  "Debugfs entry %s creation failed\n",
> +				  dops->name);
> +			debugfs_remove_recursive(qedi->bdf_dentry);
> +			return;
> +		}
> +		dops++;
> +		fops++;
> +	}
> +}
> +
> +void
> +qedi_dbg_host_exit(struct qedi_dbg_ctx *qedi)
> +{
> +	debugfs_remove_recursive(qedi->bdf_dentry);
> +	qedi->bdf_dentry = NULL;
> +}
> +
> +void
> +qedi_dbg_init(char *drv_name)
> +{
> +	qedi_dbg_root = debugfs_create_dir(drv_name, NULL);
> +	if (!qedi_dbg_root)
> +		QEDI_INFO(NULL, QEDI_LOG_DEBUGFS, "Init of debugfs failed\n");
> +}
> +
> +void
> +qedi_dbg_exit(void)
> +{
> +	debugfs_remove_recursive(qedi_dbg_root);
> +	qedi_dbg_root = NULL;
> +}
> +
> +static ssize_t
> +qedi_dbg_do_not_recover_enable(struct qedi_dbg_ctx *qedi_dbg)
> +{
> +	if (!do_not_recover)
> +		do_not_recover = 1;
> +
> +	QEDI_INFO(qedi_dbg, QEDI_LOG_DEBUGFS, "do_not_recover=%d\n",
> +		  do_not_recover);
> +	return 0;
> +}
> +
> +static ssize_t
> +qedi_dbg_do_not_recover_disable(struct qedi_dbg_ctx *qedi_dbg)
> +{
> +	if (do_not_recover)
> +		do_not_recover = 0;
> +
> +	QEDI_INFO(qedi_dbg, QEDI_LOG_DEBUGFS, "do_not_recover=%d\n",
> +		  do_not_recover);
> +	return 0;
> +}
> +
> +static struct qedi_list_of_funcs qedi_dbg_do_not_recover_ops[] = {
> +	{ "enable", qedi_dbg_do_not_recover_enable },
> +	{ "disable", qedi_dbg_do_not_recover_disable },
> +	{ NULL, NULL }
> +};
> +
> +struct qedi_debugfs_ops qedi_debugfs_ops[] = {
> +	{ "gbl_ctx", NULL },
> +	{ "do_not_recover", qedi_dbg_do_not_recover_ops},
> +	{ "io_trace", NULL },
> +	{ NULL, NULL }
> +};
> +
> +static ssize_t
> +qedi_dbg_do_not_recover_cmd_write(struct file *filp, const char __user *buffer,
> +				  size_t count, loff_t *ppos)
> +{
> +	size_t cnt = 0;
> +	struct qedi_dbg_ctx *qedi_dbg =
> +			(struct qedi_dbg_ctx *)filp->private_data;
> +	struct qedi_list_of_funcs *lof = qedi_dbg_do_not_recover_ops;
> +
> +	if (*ppos)
> +		return 0;
> +
> +	while (lof) {
> +		if (!(lof->oper_str))
> +			break;
> +
> +		if (!strncmp(lof->oper_str, buffer, strlen(lof->oper_str))) {
> +			cnt = lof->oper_func(qedi_dbg);
> +			break;
> +		}
> +
> +		lof++;
> +	}
> +	return (count - cnt);
> +}
> +
> +static ssize_t
> +qedi_dbg_do_not_recover_cmd_read(struct file *filp, char __user *buffer,
> +				 size_t count, loff_t *ppos)
> +{
> +	size_t cnt = 0;
> +
> +	if (*ppos)
> +		return 0;
> +
> +	cnt = sprintf(buffer, "do_not_recover=%d\n", do_not_recover);
> +	cnt = min_t(int, count, cnt - *ppos);
> +	*ppos += cnt;
> +	return cnt;
> +}
> +
> +static int
> +qedi_gbl_ctx_show(struct seq_file *s, void *unused)
> +{
> +	struct qedi_fastpath *fp = NULL;
> +	struct qed_sb_info *sb_info = NULL;
> +	struct status_block *sb = NULL;
> +	struct global_queue *que = NULL;
> +	int id;
> +	u16 prod_idx;
> +	struct qedi_ctx *qedi = s->private;
> +	unsigned long flags;
> +
> +	seq_puts(s, " DUMP CQ CONTEXT:\n");
> +
> +	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
> +		spin_lock_irqsave(&qedi->hba_lock, flags);
> +		seq_printf(s, "=========FAST CQ PATH [%d] ==========\n", id);
> +		fp = &qedi->fp_array[id];
> +		sb_info = fp->sb_info;
> +		sb = sb_info->sb_virt;
> +		prod_idx = (sb->pi_array[QEDI_PROTO_CQ_PROD_IDX] &
> +			    STATUS_BLOCK_PROD_INDEX_MASK);
> +		seq_printf(s, "SB PROD IDX: %d\n", prod_idx);
> +		que = qedi->global_queues[fp->sb_id];
> +		seq_printf(s, "DRV CONS IDX: %d\n", que->cq_cons_idx);
> +		seq_printf(s, "CQ complete host memory: %d\n", fp->sb_id);
> +		seq_puts(s, "=========== END ==================\n\n\n");
> +		spin_unlock_irqrestore(&qedi->hba_lock, flags);
> +	}
> +	return 0;
> +}
> +
> +static int
> +qedi_dbg_gbl_ctx_open(struct inode *inode, struct file *file)
> +{
> +	struct qedi_dbg_ctx *qedi_dbg = inode->i_private;
> +	struct qedi_ctx *qedi = container_of(qedi_dbg, struct qedi_ctx,
> +					     dbg_ctx);
> +
> +	return single_open(file, qedi_gbl_ctx_show, qedi);
> +}
> +
> +static int
> +qedi_io_trace_show(struct seq_file *s, void *unused)
> +{
> +	int id, idx = 0;
> +	struct qedi_ctx *qedi = s->private;
> +	struct qedi_io_log *io_log;
> +	unsigned long flags;
> +
> +	seq_puts(s, " DUMP IO LOGS:\n");
> +	spin_lock_irqsave(&qedi->io_trace_lock, flags);
> +	idx = qedi->io_trace_idx;
> +	for (id = 0; id < QEDI_IO_TRACE_SIZE; id++) {
> +		io_log = &qedi->io_trace_buf[idx];
> +		seq_printf(s, "iodir-%d:", io_log->direction);
> +		seq_printf(s, "tid-0x%x:", io_log->task_id);
> +		seq_printf(s, "cid-0x%x:", io_log->cid);
> +		seq_printf(s, "lun-%d:", io_log->lun);
> +		seq_printf(s, "op-0x%02x:", io_log->op);
> +		seq_printf(s, "0x%02x%02x%02x%02x:", io_log->lba[0],
> +			   io_log->lba[1], io_log->lba[2], io_log->lba[3]);
> +		seq_printf(s, "buflen-%d:", io_log->bufflen);
> +		seq_printf(s, "sgcnt-%d:", io_log->sg_count);
> +		seq_printf(s, "res-0x%08x:", io_log->result);
> +		seq_printf(s, "jif-%lu:", io_log->jiffies);
> +		seq_printf(s, "blk_req_cpu-%d:", io_log->blk_req_cpu);
> +		seq_printf(s, "req_cpu-%d:", io_log->req_cpu);
> +		seq_printf(s, "intr_cpu-%d:", io_log->intr_cpu);
> +		seq_printf(s, "blk_rsp_cpu-%d\n", io_log->blk_rsp_cpu);
> +
> +		idx++;
> +		if (idx == QEDI_IO_TRACE_SIZE)
> +			idx = 0;
> +	}
> +	spin_unlock_irqrestore(&qedi->io_trace_lock, flags);
> +	return 0;
> +}
> +
> +static int
> +qedi_dbg_io_trace_open(struct inode *inode, struct file *file)
> +{
> +	struct qedi_dbg_ctx *qedi_dbg = inode->i_private;
> +	struct qedi_ctx *qedi = container_of(qedi_dbg, struct qedi_ctx,
> +					     dbg_ctx);
> +
> +	return single_open(file, qedi_io_trace_show, qedi);
> +}
> +
> +const struct file_operations qedi_dbg_fops[] = {
> +	qedi_dbg_fileops_seq(qedi, gbl_ctx),
> +	qedi_dbg_fileops(qedi, do_not_recover),
> +	qedi_dbg_fileops_seq(qedi, io_trace),
> +	{ NULL, NULL },
> +};
> diff --git a/drivers/scsi/qedi/qedi_hsi.h b/drivers/scsi/qedi/qedi_hsi.h
> new file mode 100644
> index 0000000..b442a62
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi_hsi.h
> @@ -0,0 +1,52 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +#ifndef __QEDI_HSI__
> +#define __QEDI_HSI__
> +/********************************/
> +/* Add include to common target */
> +/********************************/
> +#include <linux/qed/common_hsi.h>
> +
Please use kernel-doc style for comments

> +/****************************************/
> +/* Add include to common storage target */
> +/****************************************/
> +#include <linux/qed/storage_common.h>
> +
> +/************************************************************************/
> +/* Add include to common TCP target */
> +/************************************************************************/
> +#include <linux/qed/tcp_common.h>
> +
> +/*************************************************************************/
> +/* Add include to common iSCSI target for both eCore and protocol driver */
> +/************************************************************************/
> +#include <linux/qed/iscsi_common.h>
> +
> +/*
> + * iSCSI CMDQ element
> + */
> +struct iscsi_cmdqe {
> +	__le16 conn_id;
> +	u8 invalid_command;
> +	u8 cmd_hdr_type;
> +	__le32 reserved1[2];
> +	__le32 cmd_payload[13];
> +};
> +
> +/*
> + * iSCSI CMD header type
> + */
> +enum iscsi_cmd_hdr_type {
> +	ISCSI_CMD_HDR_TYPE_BHS_ONLY /* iSCSI BHS with no expected AHS */,
> +	ISCSI_CMD_HDR_TYPE_BHS_W_AHS /* iSCSI BHS with expected AHS */,
> +	ISCSI_CMD_HDR_TYPE_AHS /* iSCSI AHS */,
> +	MAX_ISCSI_CMD_HDR_TYPE
> +};
> +
> +#endif /* __QEDI_HSI__ */
> diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
> new file mode 100644
> index 0000000..35ab2f9
> --- /dev/null
> +++ b/drivers/scsi/qedi/qedi_main.c
> @@ -0,0 +1,1550 @@
> +/*
> + * QLogic iSCSI Offload Driver
> + * Copyright (c) 2016 Cavium Inc.
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/kernel.h>
> +#include <linux/if_arp.h>
> +#include <scsi/iscsi_if.h>
> +#include <linux/inet.h>
> +#include <net/arp.h>
> +#include <linux/list.h>
> +#include <linux/kthread.h>
> +#include <linux/mm.h>
> +#include <linux/if_vlan.h>
> +#include <linux/cpu.h>
> +
> +#include <scsi/scsi_cmnd.h>
> +#include <scsi/scsi_device.h>
> +#include <scsi/scsi_eh.h>
> +#include <scsi/scsi_host.h>
> +#include <scsi/scsi.h>
> +
> +#include "qedi.h"
> +
> +static uint fw_debug;
> +module_param(fw_debug, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(fw_debug, " Firmware debug level 0(default) to 3");
> +
> +static uint int_mode;
> +module_param(int_mode, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(int_mode,
> +		 " Force interrupt mode other than MSI-X: (1 INT#x; 2 MSI)");
> +
> +uint debug = QEDI_LOG_WARN | QEDI_LOG_SCSI_TM;
> +module_param(debug, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(debug, " Default debug level");
> +
> +const struct qed_iscsi_ops *qedi_ops;
> +static struct scsi_transport_template *qedi_scsi_transport;
> +static struct pci_driver qedi_pci_driver;
> +static DEFINE_PER_CPU(struct qedi_percpu_s, qedi_percpu);
> +/* Static function declaration */
> +static int qedi_alloc_global_queues(struct qedi_ctx *qedi);
> +static void qedi_free_global_queues(struct qedi_ctx *qedi);
> +
> +static int qedi_iscsi_event_cb(void *context, u8 fw_event_code, void *fw_handle)
> +{
> +	struct qedi_ctx *qedi;
> +	struct qedi_endpoint *qedi_ep;
> +	struct async_data *data;
> +	int rval = 0;
> +
> +	if (!context || !fw_handle) {
> +		QEDI_ERR(NULL, "Recv event with ctx NULL\n");
> +		return -EINVAL;
> +	}
> +
> +	qedi = (struct qedi_ctx *)context;
> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
> +		  "Recv Event %d fw_handle %p\n", fw_event_code, fw_handle);
> +
> +	data = (struct async_data *)fw_handle;
> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
> +		  "cid=0x%x tid=0x%x err-code=0x%x fw-dbg-param=0x%x\n",
> +		   data->cid, data->itid, data->error_code,
> +		   data->fw_debug_param);
> +
> +	qedi_ep = qedi->ep_tbl[data->cid];
> +
> +	if (!qedi_ep) {
> +		QEDI_WARN(&qedi->dbg_ctx,
> +			  "Cannot process event, ep already disconnected, cid=0x%x\n",
> +			   data->cid);
> +		WARN_ON(1);
> +		return -ENODEV;
> +	}
> +
> +	switch (fw_event_code) {
> +	case ISCSI_EVENT_TYPE_ASYN_CONNECT_COMPLETE:
> +		if (qedi_ep->state == EP_STATE_OFLDCONN_START)
> +			qedi_ep->state = EP_STATE_OFLDCONN_COMPL;
> +
> +		wake_up_interruptible(&qedi_ep->tcp_ofld_wait);
> +		break;
> +	case ISCSI_EVENT_TYPE_ASYN_TERMINATE_DONE:
> +		qedi_ep->state = EP_STATE_DISCONN_COMPL;
> +		wake_up_interruptible(&qedi_ep->tcp_ofld_wait);
> +		break;
> +	case ISCSI_EVENT_TYPE_ISCSI_CONN_ERROR:
> +		qedi_process_iscsi_error(qedi_ep, data);
> +		break;
> +	case ISCSI_EVENT_TYPE_ASYN_ABORT_RCVD:
> +	case ISCSI_EVENT_TYPE_ASYN_SYN_RCVD:
> +	case ISCSI_EVENT_TYPE_ASYN_MAX_RT_TIME:
> +	case ISCSI_EVENT_TYPE_ASYN_MAX_RT_CNT:
> +	case ISCSI_EVENT_TYPE_ASYN_MAX_KA_PROBES_CNT:
> +	case ISCSI_EVENT_TYPE_ASYN_FIN_WAIT2:
> +	case ISCSI_EVENT_TYPE_TCP_CONN_ERROR:
> +		qedi_process_tcp_error(qedi_ep, data);
> +		break;
> +	default:
> +		QEDI_ERR(&qedi->dbg_ctx, "Recv Unknown Event %u\n",
> +			 fw_event_code);
> +	}
> +
> +	return rval;
> +}
> +
> +static int qedi_alloc_and_init_sb(struct qedi_ctx *qedi,
> +				  struct qed_sb_info *sb_info, u16 sb_id)
> +{
> +	struct status_block *sb_virt;
> +	dma_addr_t sb_phys;
> +	int ret;
> +
> +	sb_virt = dma_alloc_coherent(&qedi->pdev->dev,
> +				     sizeof(struct status_block), &sb_phys,
> +				     GFP_KERNEL);
> +	if (!sb_virt) {
> +		QEDI_ERR(&qedi->dbg_ctx,
> +			 "Status block allocation failed for id = %d.\n",
> +			  sb_id);
> +		return -ENOMEM;
> +	}
> +
> +	ret = qedi_ops->common->sb_init(qedi->cdev, sb_info, sb_virt, sb_phys,
> +				       sb_id, QED_SB_TYPE_STORAGE);
> +	if (ret) {
> +		QEDI_ERR(&qedi->dbg_ctx,
> +			 "Status block initialization failed for id = %d.\n",
> +			  sb_id);
> +		return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static void qedi_free_sb(struct qedi_ctx *qedi)
> +{
> +	struct qed_sb_info *sb_info;
> +	int id;
> +
> +	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
> +		sb_info = &qedi->sb_array[id];
> +		if (sb_info->sb_virt)
> +			dma_free_coherent(&qedi->pdev->dev,
> +					  sizeof(*sb_info->sb_virt),
> +					  (void *)sb_info->sb_virt,
> +					  sb_info->sb_phys);
> +	}
> +}
> +
> +static void qedi_free_fp(struct qedi_ctx *qedi)
> +{
> +	kfree(qedi->fp_array);
> +	kfree(qedi->sb_array);
> +}
> +
> +static void qedi_destroy_fp(struct qedi_ctx *qedi)
> +{
> +	qedi_free_sb(qedi);
> +	qedi_free_fp(qedi);
> +}
> +
> +static int qedi_alloc_fp(struct qedi_ctx *qedi)
> +{
> +	int ret = 0;
> +
> +	qedi->fp_array = kcalloc(MIN_NUM_CPUS_MSIX(qedi),
> +				 sizeof(struct qedi_fastpath), GFP_KERNEL);
> +	if (!qedi->fp_array) {
> +		QEDI_ERR(&qedi->dbg_ctx,
> +			 "fastpath fp array allocation failed.\n");
> +		return -ENOMEM;
> +	}
> +
> +	qedi->sb_array = kcalloc(MIN_NUM_CPUS_MSIX(qedi),
> +				 sizeof(struct qed_sb_info), GFP_KERNEL);
> +	if (!qedi->sb_array) {
> +		QEDI_ERR(&qedi->dbg_ctx,
> +			 "fastpath sb array allocation failed.\n");
> +		ret = -ENOMEM;
> +		goto free_fp;
> +	}
> +
> +	return ret;
> +
> +free_fp:
> +	qedi_free_fp(qedi);
> +	return ret;
> +}
> +
> +static void qedi_int_fp(struct qedi_ctx *qedi)
> +{
> +	struct qedi_fastpath *fp;
> +	int id;
> +
> +	memset((void *)qedi->fp_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
> +	       sizeof(*qedi->fp_array));
> +	memset((void *)qedi->sb_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
> +	       sizeof(*qedi->sb_array));
> +
> +	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
> +		fp = &qedi->fp_array[id];
> +		fp->sb_info = &qedi->sb_array[id];
> +		fp->sb_id = id;
> +		fp->qedi = qedi;
> +		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
> +			 "qedi", id);
> +
> +		/* fp_array[i] ---- irq cookie
> +		 * So init data which is needed in int ctx
> +		 */
> +	}
> +}
> +
Please check if you cannot make use of Christophs irq rework.

> +static int qedi_prepare_fp(struct qedi_ctx *qedi)
> +{
> +	struct qedi_fastpath *fp;
> +	int id, ret = 0;
> +
> +	ret = qedi_alloc_fp(qedi);
> +	if (ret)
> +		goto err;
> +
> +	qedi_int_fp(qedi);
> +
> +	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
> +		fp = &qedi->fp_array[id];
> +		ret = qedi_alloc_and_init_sb(qedi, fp->sb_info, fp->sb_id);
> +		if (ret) {
> +			QEDI_ERR(&qedi->dbg_ctx,
> +				 "SB allocation and initialization failed.\n");
> +			ret = -EIO;
> +			goto err_init;
> +		}
> +	}
> +
> +	return 0;
> +
> +err_init:
> +	qedi_free_sb(qedi);
> +	qedi_free_fp(qedi);
> +err:
> +	return ret;
> +}
> +
> +static enum qed_int_mode qedi_int_mode_to_enum(void)
> +{
> +	switch (int_mode) {
> +	case 0: return QED_INT_MODE_MSIX;
> +	case 1: return QED_INT_MODE_INTA;
> +	case 2: return QED_INT_MODE_MSI;
> +	default:
> +		QEDI_ERR(NULL, "Unknown qede_int_mode=%08x; "
> +			 "Defaulting to MSI-x\n", int_mode);
> +		return QED_INT_MODE_MSIX;
> +	}
> +}
> +
> +static int qedi_setup_cid_que(struct qedi_ctx *qedi)
> +{
> +	int i;
> +
> +	qedi->cid_que.cid_que_base = kmalloc((qedi->max_active_conns *
> +					      sizeof(u32)), GFP_KERNEL);
> +	if (!qedi->cid_que.cid_que_base)
> +		return -ENOMEM;
> +
> +	qedi->cid_que.conn_cid_tbl = kmalloc((qedi->max_active_conns *
> +					      sizeof(struct qedi_conn *)),
> +					     GFP_KERNEL);
> +	if (!qedi->cid_que.conn_cid_tbl) {
> +		kfree(qedi->cid_que.cid_que_base);
> +		qedi->cid_que.cid_que_base = NULL;
> +		return -ENOMEM;
> +	}
> +
> +	qedi->cid_que.cid_que = (u32 *)qedi->cid_que.cid_que_base;
> +	qedi->cid_que.cid_q_prod_idx = 0;
> +	qedi->cid_que.cid_q_cons_idx = 0;
> +	qedi->cid_que.cid_q_max_idx = qedi->max_active_conns;
> +	qedi->cid_que.cid_free_cnt = qedi->max_active_conns;
> +
> +	for (i = 0; i < qedi->max_active_conns; i++) {
> +		qedi->cid_que.cid_que[i] = i;
> +		qedi->cid_que.conn_cid_tbl[i] = NULL;
> +	}
> +
> +	return 0;
> +}
> +
> +static void qedi_release_cid_que(struct qedi_ctx *qedi)
> +{
> +	kfree(qedi->cid_que.cid_que_base);
> +	qedi->cid_que.cid_que_base = NULL;
> +
> +	kfree(qedi->cid_que.conn_cid_tbl);
> +	qedi->cid_que.conn_cid_tbl = NULL;
> +}
> +
> +static int qedi_init_id_tbl(struct qedi_portid_tbl *id_tbl, u16 size,
> +			    u16 start_id, u16 next)
> +{
> +	id_tbl->start = start_id;
> +	id_tbl->max = size;
> +	id_tbl->next = next;
> +	spin_lock_init(&id_tbl->lock);
> +	id_tbl->table = kzalloc(DIV_ROUND_UP(size, 32) * 4, GFP_KERNEL);
> +	if (!id_tbl->table)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void qedi_free_id_tbl(struct qedi_portid_tbl *id_tbl)
> +{
> +	kfree(id_tbl->table);
> +	id_tbl->table = NULL;
> +}
> +
> +int qedi_alloc_id(struct qedi_portid_tbl *id_tbl, u16 id)
> +{
> +	int ret = -1;
> +
> +	id -= id_tbl->start;
> +	if (id >= id_tbl->max)
> +		return ret;
> +
> +	spin_lock(&id_tbl->lock);
> +	if (!test_bit(id, id_tbl->table)) {
> +		set_bit(id, id_tbl->table);
> +		ret = 0;
> +	}
> +	spin_unlock(&id_tbl->lock);
> +	return ret;
> +}
> +
> +u16 qedi_alloc_new_id(struct qedi_portid_tbl *id_tbl)
> +{
> +	u16 id;
> +
> +	spin_lock(&id_tbl->lock);
> +	id = find_next_zero_bit(id_tbl->table, id_tbl->max, id_tbl->next);
> +	if (id >= id_tbl->max) {
> +		id = QEDI_LOCAL_PORT_INVALID;
> +		if (id_tbl->next != 0) {
> +			id = find_first_zero_bit(id_tbl->table, id_tbl->next);
> +			if (id >= id_tbl->next)
> +				id = QEDI_LOCAL_PORT_INVALID;
> +		}
> +	}
> +
> +	if (id < id_tbl->max) {
> +		set_bit(id, id_tbl->table);
> +		id_tbl->next = (id + 1) & (id_tbl->max - 1);
> +		id += id_tbl->start;
> +	}
> +
> +	spin_unlock(&id_tbl->lock);
> +
> +	return id;
> +}
> +
> +void qedi_free_id(struct qedi_portid_tbl *id_tbl, u16 id)
> +{
> +	if (id == QEDI_LOCAL_PORT_INVALID)
> +		return;
> +
> +	id -= id_tbl->start;
> +	if (id >= id_tbl->max)
> +		return;
> +
> +	clear_bit(id, id_tbl->table);
> +}
> +
> +static void qedi_cm_free_mem(struct qedi_ctx *qedi)
> +{
> +	kfree(qedi->ep_tbl);
> +	qedi->ep_tbl = NULL;
> +	qedi_free_id_tbl(&qedi->lcl_port_tbl);
> +}
> +
> +static int qedi_cm_alloc_mem(struct qedi_ctx *qedi)
> +{
> +	u16 port_id;
> +
> +	qedi->ep_tbl = kzalloc((qedi->max_active_conns *
> +				sizeof(struct qedi_endpoint *)), GFP_KERNEL);
> +	if (!qedi->ep_tbl)
> +		return -ENOMEM;
> +	port_id = prandom_u32() % QEDI_LOCAL_PORT_RANGE;
> +	if (qedi_init_id_tbl(&qedi->lcl_port_tbl, QEDI_LOCAL_PORT_RANGE,
> +			     QEDI_LOCAL_PORT_MIN, port_id)) {
> +		qedi_cm_free_mem(qedi);
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +
> +static struct qedi_ctx *qedi_host_alloc(struct pci_dev *pdev)
> +{
> +	struct Scsi_Host *shost;
> +	struct qedi_ctx *qedi = NULL;
> +
> +	shost = iscsi_host_alloc(&qedi_host_template,
> +				 sizeof(struct qedi_ctx), 0);
> +	if (!shost) {
> +		QEDI_ERR(NULL, "Could not allocate shost\n");
> +		goto exit_setup_shost;
> +	}
> +
> +	shost->max_id = QEDI_MAX_ISCSI_CONNS_PER_HBA;
> +	shost->max_channel = 0;
> +	shost->max_lun = ~0;
> +	shost->max_cmd_len = 16;
> +	shost->transportt = qedi_scsi_transport;
> +
> +	qedi = iscsi_host_priv(shost);
> +	memset(qedi, 0, sizeof(*qedi));
> +	qedi->shost = shost;
> +	qedi->dbg_ctx.host_no = shost->host_no;
> +	qedi->pdev = pdev;
> +	qedi->dbg_ctx.pdev = pdev;
> +	qedi->max_active_conns = ISCSI_MAX_SESS_PER_HBA;
> +	qedi->max_sqes = QEDI_SQ_SIZE;
> +
> +	if (shost_use_blk_mq(shost))
> +		shost->nr_hw_queues = MIN_NUM_CPUS_MSIX(qedi);
> +
> +	pci_set_drvdata(pdev, qedi);
> +
> +exit_setup_shost:
> +	return qedi;
> +}
> +
> +static int qedi_set_iscsi_pf_param(struct qedi_ctx *qedi)
> +{
> +	u8 num_sq_pages;
> +	u32 log_page_size;
> +	int rval = 0;
> +
> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC, "Min number of MSIX %d\n",
> +		  MIN_NUM_CPUS_MSIX(qedi));
> +
> +	num_sq_pages = (MAX_OUSTANDING_TASKS_PER_CON * 8) / PAGE_SIZE;
> +
> +	qedi->num_queues = MIN_NUM_CPUS_MSIX(qedi);
> +
> +	memset(&qedi->pf_params.iscsi_pf_params, 0,
> +	       sizeof(qedi->pf_params.iscsi_pf_params));
> +
> +	qedi->p_cpuq = pci_alloc_consistent(qedi->pdev,
> +			qedi->num_queues * sizeof(struct qedi_glbl_q_params),
> +			&qedi->hw_p_cpuq);
> +	if (!qedi->p_cpuq) {
> +		QEDI_ERR(&qedi->dbg_ctx, "pci_alloc_consistent fail\n");
> +		rval = -1;
> +		goto err_alloc_mem;
> +	}
> +
> +	rval = qedi_alloc_global_queues(qedi);
> +	if (rval) {
> +		QEDI_ERR(&qedi->dbg_ctx, "Global queue allocation failed.\n");
> +		rval = -1;
> +		goto err_alloc_mem;
> +	}
> +
> +	qedi->pf_params.iscsi_pf_params.num_cons = QEDI_MAX_ISCSI_CONNS_PER_HBA;
> +	qedi->pf_params.iscsi_pf_params.num_tasks = QEDI_MAX_ISCSI_TASK;
> +	qedi->pf_params.iscsi_pf_params.half_way_close_timeout = 10;
> +	qedi->pf_params.iscsi_pf_params.num_sq_pages_in_ring = num_sq_pages;
> +	qedi->pf_params.iscsi_pf_params.num_r2tq_pages_in_ring = num_sq_pages;
> +	qedi->pf_params.iscsi_pf_params.num_uhq_pages_in_ring = num_sq_pages;
> +	qedi->pf_params.iscsi_pf_params.num_queues = qedi->num_queues;
> +	qedi->pf_params.iscsi_pf_params.debug_mode = fw_debug;
> +
> +	for (log_page_size = 0 ; log_page_size < 32 ; log_page_size++) {
> +		if ((1 << log_page_size) == PAGE_SIZE)
> +			break;
> +	}
> +	qedi->pf_params.iscsi_pf_params.log_page_size = log_page_size;
> +
> +	qedi->pf_params.iscsi_pf_params.glbl_q_params_addr = qedi->hw_p_cpuq;
> +
> +	/* RQ BDQ initializations.
> +	 * rq_num_entries: suggested value for Initiator is 16 (4KB RQ)
> +	 * rqe_log_size: 8 for 256B RQE
> +	 */
> +	qedi->pf_params.iscsi_pf_params.rqe_log_size = 8;
> +	/* BDQ address and size */
> +	qedi->pf_params.iscsi_pf_params.bdq_pbl_base_addr[BDQ_ID_RQ] =
> +							qedi->bdq_pbl_list_dma;
> +	qedi->pf_params.iscsi_pf_params.bdq_pbl_num_entries[BDQ_ID_RQ] =
> +						qedi->bdq_pbl_list_num_entries;
> +	qedi->pf_params.iscsi_pf_params.rq_buffer_size = QEDI_BDQ_BUF_SIZE;
> +
> +	/* cq_num_entries: num_tasks + rq_num_entries */
> +	qedi->pf_params.iscsi_pf_params.cq_num_entries = 2048;
> +
> +	qedi->pf_params.iscsi_pf_params.gl_rq_pi = QEDI_PROTO_CQ_PROD_IDX;
> +	qedi->pf_params.iscsi_pf_params.gl_cmd_pi = 1;
> +	qedi->pf_params.iscsi_pf_params.ooo_enable = 1;
> +
> +err_alloc_mem:
> +	return rval;
> +}
> +
> +/* Free DMA coherent memory for array of queue pointers we pass to qed */
> +static void qedi_free_iscsi_pf_param(struct qedi_ctx *qedi)
> +{
> +	size_t size = 0;
> +
> +	if (qedi->p_cpuq) {
> +		size = qedi->num_queues * sizeof(struct qedi_glbl_q_params);
> +		pci_free_consistent(qedi->pdev, size, qedi->p_cpuq,
> +				    qedi->hw_p_cpuq);
> +	}
> +
> +	qedi_free_global_queues(qedi);
> +
> +	kfree(qedi->global_queues);
> +}
> +
> +static void qedi_link_update(void *dev, struct qed_link_output *link)
> +{
> +	struct qedi_ctx *qedi = (struct qedi_ctx *)dev;
> +
> +	if (link->link_up) {
> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO, "Link Up event.\n");
> +		atomic_set(&qedi->link_state, QEDI_LINK_UP);
> +	} else {
> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
> +			  "Link Down event.\n");
> +		atomic_set(&qedi->link_state, QEDI_LINK_DOWN);
> +	}
> +}
> +
> +static struct qed_iscsi_cb_ops qedi_cb_ops = {
> +	{
> +		.link_update =		qedi_link_update,
> +	}
> +};
> +
> +static bool qedi_process_completions(struct qedi_fastpath *fp)
> +{
> +	struct qedi_work *qedi_work = NULL;
> +	struct qedi_ctx *qedi = fp->qedi;
> +	struct qed_sb_info *sb_info = fp->sb_info;
> +	struct status_block *sb = sb_info->sb_virt;
> +	struct qedi_percpu_s *p = NULL;
> +	struct global_queue *que;
> +	u16 prod_idx;
> +	unsigned long flags;
> +	union iscsi_cqe *cqe;
> +	int cpu;
> +
> +	/* Get the current firmware producer index */
> +	prod_idx = sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
> +
> +	if (prod_idx >= QEDI_CQ_SIZE)
> +		prod_idx = prod_idx % QEDI_CQ_SIZE;
> +
> +	que = qedi->global_queues[fp->sb_id];
> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
> +		  "Before: global queue=%p prod_idx=%d cons_idx=%d, sb_id=%d\n",
> +		  que, prod_idx, que->cq_cons_idx, fp->sb_id);
> +
> +	qedi->intr_cpu = fp->sb_id;
> +	cpu = smp_processor_id();
> +	p = &per_cpu(qedi_percpu, cpu);
> +
> +	if (unlikely(!p->iothread))
> +		WARN_ON(1);
> +
> +	spin_lock_irqsave(&p->p_work_lock, flags);
> +	while (que->cq_cons_idx != prod_idx) {
> +		cqe = &que->cq[que->cq_cons_idx];
> +
> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
> +			  "cqe=%p prod_idx=%d cons_idx=%d.\n",
> +			  cqe, prod_idx, que->cq_cons_idx);
> +
> +		/* Alloc and copy to the cqe */
> +		qedi_work = kzalloc(sizeof(*qedi_work), GFP_ATOMIC);
> +		if (qedi_work) {
> +			INIT_LIST_HEAD(&qedi_work->list);
> +			qedi_work->qedi = qedi;
> +			memcpy(&qedi_work->cqe, cqe, sizeof(union iscsi_cqe));
> +			qedi_work->que_idx = fp->sb_id;
> +			list_add_tail(&qedi_work->list, &p->work_list);
> +		} else {
> +			WARN_ON(1);
> +			continue;
> +		}
> +
Memory allocation in an interrupt routine?
You must be kidding ...

> +		que->cq_cons_idx++;
> +		if (que->cq_cons_idx == QEDI_CQ_SIZE)
> +			que->cq_cons_idx = 0;
> +	}
> +	wake_up_process(p->iothread);
> +	spin_unlock_irqrestore(&p->p_work_lock, flags);
> +
> +	return true;
> +}
> +
> +static bool qedi_fp_has_work(struct qedi_fastpath *fp)
> +{
> +	struct qedi_ctx *qedi = fp->qedi;
> +	struct global_queue *que;
> +	struct qed_sb_info *sb_info = fp->sb_info;
> +	struct status_block *sb = sb_info->sb_virt;
> +	u16 prod_idx;
> +
> +	barrier();
> +
> +	/* Get the current firmware producer index */
> +	prod_idx = sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
> +
> +	/* Get the pointer to the global CQ this completion is on */
> +	que = qedi->global_queues[fp->sb_id];
> +
> +	/* prod idx wrap around uint16 */
> +	if (prod_idx >= QEDI_CQ_SIZE)
> +		prod_idx = prod_idx % QEDI_CQ_SIZE;
> +
> +	return (que->cq_cons_idx != prod_idx);
> +}
> +
> +/* MSI-X fastpath handler code */
> +static irqreturn_t qedi_msix_handler(int irq, void *dev_id)
> +{
> +	struct qedi_fastpath *fp = dev_id;
> +	struct qedi_ctx *qedi = fp->qedi;
> +	bool wake_io_thread = true;
> +
> +	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0);
> +
> +process_again:
> +	wake_io_thread = qedi_process_completions(fp);
> +	if (wake_io_thread) {
> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
> +			  "process already running\n");
> +	}
> +
> +	if (qedi_fp_has_work(fp) == 0)
> +		qed_sb_update_sb_idx(fp->sb_info);
> +
> +	/* Check for more work */
> +	rmb();
> +
> +	if (qedi_fp_has_work(fp) == 0)
> +		qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
> +	else
> +		goto process_again;
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/* simd handler for MSI/INTa */
> +static void qedi_simd_int_handler(void *cookie)
> +{
> +	/* Cookie is qedi_ctx struct */
> +	struct qedi_ctx *qedi = (struct qedi_ctx *)cookie;
> +
> +	QEDI_WARN(&qedi->dbg_ctx, "qedi=%p.\n", qedi);
> +}
> +
> +#define QEDI_SIMD_HANDLER_NUM		0
> +static void qedi_sync_free_irqs(struct qedi_ctx *qedi)
> +{
> +	int i;
> +
> +	if (qedi->int_info.msix_cnt) {
> +		for (i = 0; i < qedi->int_info.used_cnt; i++) {
> +			synchronize_irq(qedi->int_info.msix[i].vector);
> +			irq_set_affinity_hint(qedi->int_info.msix[i].vector,
> +					      NULL);
> +			free_irq(qedi->int_info.msix[i].vector,
> +				 &qedi->fp_array[i]);
> +		}
> +	} else {
> +		qedi_ops->common->simd_handler_clean(qedi->cdev,
> +						     QEDI_SIMD_HANDLER_NUM);
> +	}
> +
> +	qedi->int_info.used_cnt = 0;
> +	qedi_ops->common->set_fp_int(qedi->cdev, 0);
> +}
> +
Again, consider using the interrupt affinity rework from Christoph Hellwig.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
