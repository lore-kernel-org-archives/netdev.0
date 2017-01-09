From: Chad Dupuis <chad.dupuis@cavium.com>
Subject: Re: [Open-FCoE] [PATCH RFC 3/5] qedf: Add offloaded I/O request
 functions.
Date: Mon, 9 Jan 2017 11:46:41 -0500
Message-ID: <alpine.OSX.2.00.1701091146230.1044@administrators-macbook-pro.local>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com> <1482520628-24207-4-git-send-email-chad.dupuis@cavium.com> <7cfe465a-ad6c-7604-1262-d4dbf4aee525@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <martin.petersen@oracle.com>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        <linux-scsi@vger.kernel.org>, <yuval.mintz@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <7cfe465a-ad6c-7604-1262-d4dbf4aee525@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 28 Dec 2016, 9:08am -0000, Hannes Reinecke wrote:

> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> > From: "Dupuis, Chad" <chad.dupuis@cavium.com>
> > 
> > This patch adds various I/O requests types that are handled in firmware:
> > 
> > - Normal I/O requests
> > - ABTS requests
> > - Cleanup requests
> > - Task management requests
> > 
> > It also contains:
> > 
> > - I/O request initialization
> > - Firmware completion handling
> > 
> > Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> > Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> > Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> > Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> > ---
> >  drivers/scsi/qedf/qedf_hsi.h |  427 ++++++++
> >  drivers/scsi/qedf/qedf_io.c  | 2303 ++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 2730 insertions(+)
> >  create mode 100644 drivers/scsi/qedf/qedf_hsi.h
> >  create mode 100644 drivers/scsi/qedf/qedf_io.c
> > 
> [ .. ]
> 
> > +static int qedf_execute_tmf(struct qedf_rport *fcport, struct scsi_cmnd *sc_cmd,
> > +	uint8_t tm_flags)
> > +{
> > +	struct qedf_ioreq *io_req;
> > +	struct qedf_mp_req *tm_req;
> > +	struct fcoe_task_context *task;
> > +	struct fc_frame_header *fc_hdr;
> > +	struct fcp_cmnd *fcp_cmnd;
> > +	struct qedf_ctx *qedf = fcport->qedf;
> > +	int rc = 0;
> > +	uint16_t xid;
> > +	uint32_t sid, did;
> > +	int tmo = 0;
> > +	unsigned long flags;
> > +
> > +	if (!sc_cmd) {
> > +		QEDF_ERR(&(qedf->dbg_ctx), "invalid arg\n");
> > +		return FAILED;
> > +	}
> > +
> > +	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
> > +		QEDF_ERR(&(qedf->dbg_ctx), "fcport not offloaded\n");
> > +		rc = FAILED;
> > +		return FAILED;
> > +	}
> > +
> > +	scsi_block_requests(qedf->lport->host);
> > +
> Typically, EH commands will be executed after the scsi host is stopped
> and no commands are outstanding.
> So there's no point in issuing 'scsi_block_requests()' here.
> 

Will remove.

> Cheers,
> 
> Hannes
> 
