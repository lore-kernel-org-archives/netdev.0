From: Chad Dupuis <chad.dupuis@cavium.com>
Subject: Re: [PATCH V2 2/2] qedf: Add QLogic FastLinQ offload FCoE driver
 framework.
Date: Tue, 31 Jan 2017 13:38:45 -0500
Message-ID: <alpine.OSX.2.00.1701311333580.1961@administrators-macbook-pro.local>
References: <1485376423-18737-1-git-send-email-chad.dupuis@cavium.com> <1485376423-18737-3-git-send-email-chad.dupuis@cavium.com> <28df9087-4eaf-d72c-ccee-89408d3a1b32@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <martin.petersen@oracle.com>, <linux-scsi@vger.kernel.org>,
        <fcoe-devel@open-fcoe.org>, <netdev@vger.kernel.org>,
        <yuval.mintz@cavium.com>, <QLogic-Storage-Upstream@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <28df9087-4eaf-d72c-ccee-89408d3a1b32@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 30 Jan 2017, 10:34am -0000, Hannes Reinecke wrote:

> On 01/25/2017 09:33 PM, Dupuis, Chad wrote:

> > +static int qedf_request_msix_irq(struct qedf_ctx *qedf)
> > +{
> > +	int i, rc, cpu;
> > +
> > +	cpu = cpumask_first(cpu_online_mask);
> > +	for (i = 0; i < qedf->num_queues; i++) {
> > +		rc = request_irq(qedf->int_info.msix[i].vector,
> > +		    qedf_msix_handler, 0, "qedf", &qedf->fp_array[i]);
> > +
> > +		if (rc) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "request_irq failed.\n");
> > +			qedf_sync_free_irqs(qedf);
> > +			return rc;
> > +		}
> > +
> > +		qedf->int_info.used_cnt++;
> > +		rc = irq_set_affinity_hint(qedf->int_info.msix[i].vector,
> > +		    get_cpu_mask(cpu));
> > +		cpu = cpumask_next(cpu, cpu_online_mask);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> Please use pci_alloc_irq_vectors() here; that avoid you having to do SMP
> affinity setting yourself.

This wil be difficult to coordinate with three other drivers (qedi, qede 
and qedr) using the same vector allocation code in the qed module.

> 
> Cheers,
> 
> Hannes
> 
