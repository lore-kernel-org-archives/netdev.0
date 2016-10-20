From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Thu, 20 Oct 2016 08:27:50 +0000
Message-ID: <D42E7773.340BC%manish.rangankar@cavium.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-4-git-send-email-manish.rangankar@cavium.com>
 <50c821e3-28dc-78b1-8fa4-527a138f1709@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Dept-Eng QLogic Storage Upstream
        <QLogic-Storage-Upstream@cavium.com>,
        "Javali, Nilesh" <Nilesh.Javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Kashyap, Saurav" <Saurav.Kashyap@cavium.com>,
        "Easi, Arun" <Arun.Easi@cavium.com>
To: Hannes Reinecke <hare@suse.de>,
        "lduncan@suse.com" <lduncan@suse.com>,
        "cleech@redhat.com" <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0073.outbound.protection.outlook.com ([104.47.41.73]:27040
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751012AbcJTJB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 05:01:27 -0400
In-Reply-To: <50c821e3-28dc-78b1-8fa4-527a138f1709@suse.de>
Content-Language: en-US
Content-ID: <E4FC2B2A79FA6843945A3DAE27067CF1@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Hannes for the review, please see my comments below,

On 19/10/16 1:15 PM, "Hannes Reinecke" <hare@suse.de> wrote:

>On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
>> From: Manish Rangankar <manish.rangankar@cavium.com>
>>=20
>> The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
>> for 41000 Series Converged Network Adapters by QLogic.
>>=20
>> This patch consists of following changes:
>>   - MAINTAINERS Makefile and Kconfig changes for qedi,
>>   - PCI driver registration,
>>   - iSCSI host level initialization,
>>   - Debugfs and log level infrastructure.
>>=20
>> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
>> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
>> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
>> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
>> Signed-off-by: Arun Easi <arun.easi@cavium.com>
>> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
>> ---
>>  MAINTAINERS                         |    6 +
>>  drivers/net/ethernet/qlogic/Kconfig |   12 -
>>  drivers/scsi/Kconfig                |    1 +
>>  drivers/scsi/Makefile               |    1 +
>>  drivers/scsi/qedi/Kconfig           |   10 +
>>  drivers/scsi/qedi/Makefile          |    5 +
>>  drivers/scsi/qedi/qedi.h            |  286 +++++++
>>  drivers/scsi/qedi/qedi_dbg.c        |  143 ++++
>>  drivers/scsi/qedi/qedi_dbg.h        |  144 ++++
>>  drivers/scsi/qedi/qedi_debugfs.c    |  244 ++++++
>>  drivers/scsi/qedi/qedi_hsi.h        |   52 ++
>>  drivers/scsi/qedi/qedi_main.c       | 1550
>>+++++++++++++++++++++++++++++++++++
>>  drivers/scsi/qedi/qedi_sysfs.c      |   52 ++
>>  drivers/scsi/qedi/qedi_version.h    |   14 +
>>  14 files changed, 2508 insertions(+), 12 deletions(-)
>>  create mode 100644 drivers/scsi/qedi/Kconfig
>>  create mode 100644 drivers/scsi/qedi/Makefile
>>  create mode 100644 drivers/scsi/qedi/qedi.h
>>  create mode 100644 drivers/scsi/qedi/qedi_dbg.c
>>  create mode 100644 drivers/scsi/qedi/qedi_dbg.h
>>  create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
>>  create mode 100644 drivers/scsi/qedi/qedi_hsi.h
>>  create mode 100644 drivers/scsi/qedi/qedi_main.c
>>  create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
>>  create mode 100644 drivers/scsi/qedi/qedi_version.h
>>=20
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 5e925a2..906d05f 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -9909,6 +9909,12 @@ F:	drivers/net/ethernet/qlogic/qed/
>>  F:	include/linux/qed/
>>  F:	drivers/net/ethernet/qlogic/qede/
>> =20
>> +QLOGIC QL41xxx ISCSI DRIVER
>> +M:	QLogic-Storage-Upstream@cavium.com
>> +L:	linux-scsi@vger.kernel.org
>> +S:	Supported
>> +F:	drivers/scsi/qedi/
>> +
>>  QNX4 FILESYSTEM
>>  M:	Anders Larsen <al@alarsen.net>
>>  W:	http://www.alarsen.net/linux/qnx4fs/
>> diff --git a/drivers/net/ethernet/qlogic/Kconfig
>>b/drivers/net/ethernet/qlogic/Kconfig
>> index bad4fae..28b4366 100644
>> --- a/drivers/net/ethernet/qlogic/Kconfig
>> +++ b/drivers/net/ethernet/qlogic/Kconfig
>> @@ -121,16 +121,4 @@ config INFINIBAND_QEDR
>>  config QED_ISCSI
>>  	bool
>> =20
>> -config QEDI
>> -	tristate "QLogic QED 25/40/100Gb iSCSI driver"
>> -	depends on QED
>> -	select QED_LL2
>> -	select QED_ISCSI
>> -	default n
>> -	---help---
>> -	  This provides a temporary node that allows the compilation
>> -	  and logical testing of the hardware offload iSCSI support
>> -	  for QLogic QED. This would be replaced by the 'real' option
>> -	  once the QEDI driver is added [+relocated].
>> -
>>  endif # NET_VENDOR_QLOGIC
>Huh? You just introduce this one in patch 1/6.
>Please fold them together so that this can be omitted.

Yes, we will remove this in the next revision.

-- snipped --


>> @@ -0,0 +1,52 @@
>> +/*
>> + * QLogic iSCSI Offload Driver
>> + * Copyright (c) 2016 Cavium Inc.
>> + *
>> + * This software is available under the terms of the GNU General
>>Public License
>> + * (GPL) Version 2, available from the file COPYING in the main
>>directory of
>> + * this source tree.
>> + */
>> +#ifndef __QEDI_HSI__
>> +#define __QEDI_HSI__
>> +/********************************/
>> +/* Add include to common target */
>> +/********************************/
>> +#include <linux/qed/common_hsi.h>
>> +
>Please use kernel-doc style for comments

Will do.

--snipped--
>> +static void qedi_int_fp(struct qedi_ctx *qedi)
>> +{
>> +	struct qedi_fastpath *fp;
>> +	int id;
>> +
>> +	memset((void *)qedi->fp_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
>> +	       sizeof(*qedi->fp_array));
>> +	memset((void *)qedi->sb_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
>> +	       sizeof(*qedi->sb_array));
>> +
>> +	for (id =3D 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
>> +		fp =3D &qedi->fp_array[id];
>> +		fp->sb_info =3D &qedi->sb_array[id];
>> +		fp->sb_id =3D id;
>> +		fp->qedi =3D qedi;
>> +		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
>> +			 "qedi", id);
>> +
>> +		/* fp_array[i] ---- irq cookie
>> +		 * So init data which is needed in int ctx
>> +		 */
>> +	}
>> +}
>> +
>Please check if you cannot make use of Christophs irq rework.

Sure, we will explore this.

--snipped--
>> +static bool qedi_process_completions(struct qedi_fastpath *fp)
>> +{
>> +	struct qedi_work *qedi_work =3D NULL;
>> +	struct qedi_ctx *qedi =3D fp->qedi;
>> +	struct qed_sb_info *sb_info =3D fp->sb_info;
>> +	struct status_block *sb =3D sb_info->sb_virt;
>> +	struct qedi_percpu_s *p =3D NULL;
>> +	struct global_queue *que;
>> +	u16 prod_idx;
>> +	unsigned long flags;
>> +	union iscsi_cqe *cqe;
>> +	int cpu;
>> +
>> +	/* Get the current firmware producer index */
>> +	prod_idx =3D sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
>> +
>> +	if (prod_idx >=3D QEDI_CQ_SIZE)
>> +		prod_idx =3D prod_idx % QEDI_CQ_SIZE;
>> +
>> +	que =3D qedi->global_queues[fp->sb_id];
>> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
>> +		  "Before: global queue=3D%p prod_idx=3D%d cons_idx=3D%d, sb_id=3D%d\=
n",
>> +		  que, prod_idx, que->cq_cons_idx, fp->sb_id);
>> +
>> +	qedi->intr_cpu =3D fp->sb_id;
>> +	cpu =3D smp_processor_id();
>> +	p =3D &per_cpu(qedi_percpu, cpu);
>> +
>> +	if (unlikely(!p->iothread))
>> +		WARN_ON(1);
>> +
>> +	spin_lock_irqsave(&p->p_work_lock, flags);
>> +	while (que->cq_cons_idx !=3D prod_idx) {
>> +		cqe =3D &que->cq[que->cq_cons_idx];
>> +
>> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
>> +			  "cqe=3D%p prod_idx=3D%d cons_idx=3D%d.\n",
>> +			  cqe, prod_idx, que->cq_cons_idx);
>> +
>> +		/* Alloc and copy to the cqe */
>> +		qedi_work =3D kzalloc(sizeof(*qedi_work), GFP_ATOMIC);
>> +		if (qedi_work) {
>> +			INIT_LIST_HEAD(&qedi_work->list);
>> +			qedi_work->qedi =3D qedi;
>> +			memcpy(&qedi_work->cqe, cqe, sizeof(union iscsi_cqe));
>> +			qedi_work->que_idx =3D fp->sb_id;
>> +			list_add_tail(&qedi_work->list, &p->work_list);
>> +		} else {
>> +			WARN_ON(1);
>> +			continue;
>> +		}
>> +
>Memory allocation in an interrupt routine?
>You must be kidding ...

We will revisit this code.

>
>> +		que->cq_cons_idx++;
>> +		if (que->cq_cons_idx =3D=3D QEDI_CQ_SIZE)
>> +			que->cq_cons_idx =3D 0;
>> +	}
>> +	wake_up_process(p->iothread);
>> +	spin_unlock_irqrestore(&p->p_work_lock, flags);
>> +
>> +	return true;
>> +}
>> +
>> +static bool qedi_fp_has_work(struct qedi_fastpath *fp)
>> +{
>> +	struct qedi_ctx *qedi =3D fp->qedi;
>> +	struct global_queue *que;
>> +	struct qed_sb_info *sb_info =3D fp->sb_info;
>> +	struct status_block *sb =3D sb_info->sb_virt;
>> +	u16 prod_idx;
>> +
>> +	barrier();
>> +
>> +	/* Get the current firmware producer index */
>> +	prod_idx =3D sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
>> +
>> +	/* Get the pointer to the global CQ this completion is on */
>> +	que =3D qedi->global_queues[fp->sb_id];
>> +
>> +	/* prod idx wrap around uint16 */
>> +	if (prod_idx >=3D QEDI_CQ_SIZE)
>> +		prod_idx =3D prod_idx % QEDI_CQ_SIZE;
>> +
>> +	return (que->cq_cons_idx !=3D prod_idx);
>> +}
>> +
>> +/* MSI-X fastpath handler code */
>> +static irqreturn_t qedi_msix_handler(int irq, void *dev_id)
>> +{
>> +	struct qedi_fastpath *fp =3D dev_id;
>> +	struct qedi_ctx *qedi =3D fp->qedi;
>> +	bool wake_io_thread =3D true;
>> +
>> +	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0);
>> +
>> +process_again:
>> +	wake_io_thread =3D qedi_process_completions(fp);
>> +	if (wake_io_thread) {
>> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
>> +			  "process already running\n");
>> +	}
>> +
>> +	if (qedi_fp_has_work(fp) =3D=3D 0)
>> +		qed_sb_update_sb_idx(fp->sb_info);
>> +
>> +	/* Check for more work */
>> +	rmb();
>> +
>> +	if (qedi_fp_has_work(fp) =3D=3D 0)
>> +		qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
>> +	else
>> +		goto process_again;
>> +
>> +	return IRQ_HANDLED;
>> +}
>> +
>> +/* simd handler for MSI/INTa */
>> +static void qedi_simd_int_handler(void *cookie)
>> +{
>> +	/* Cookie is qedi_ctx struct */
>> +	struct qedi_ctx *qedi =3D (struct qedi_ctx *)cookie;
>> +
>> +	QEDI_WARN(&qedi->dbg_ctx, "qedi=3D%p.\n", qedi);
>> +}
>> +
>> +#define QEDI_SIMD_HANDLER_NUM		0
>> +static void qedi_sync_free_irqs(struct qedi_ctx *qedi)
>> +{
>> +	int i;
>> +
>> +	if (qedi->int_info.msix_cnt) {
>> +		for (i =3D 0; i < qedi->int_info.used_cnt; i++) {
>> +			synchronize_irq(qedi->int_info.msix[i].vector);
>> +			irq_set_affinity_hint(qedi->int_info.msix[i].vector,
>> +					      NULL);
>> +			free_irq(qedi->int_info.msix[i].vector,
>> +				 &qedi->fp_array[i]);
>> +		}
>> +	} else {
>> +		qedi_ops->common->simd_handler_clean(qedi->cdev,
>> +						     QEDI_SIMD_HANDLER_NUM);
>> +	}
>> +
>> +	qedi->int_info.used_cnt =3D 0;
>> +	qedi_ops->common->set_fp_int(qedi->cdev, 0);
>> +}
>> +
>Again, consider using the interrupt affinity rework from Christoph Hellwig

Sure, we will explore this one also.
