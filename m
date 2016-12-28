From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH RFC 3/5] qedf: Add offloaded I/O request
 functions.
Date: Wed, 28 Dec 2016 10:08:09 +0100
Message-ID: <7cfe465a-ad6c-7604-1262-d4dbf4aee525@suse.de>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-4-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1482520628-24207-4-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> =

> This patch adds various I/O requests types that are handled in firmware:
> =

> - Normal I/O requests
> - ABTS requests
> - Cleanup requests
> - Task management requests
> =

> It also contains:
> =

> - I/O request initialization
> - Firmware completion handling
> =

> Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/scsi/qedf/qedf_hsi.h |  427 ++++++++
>  drivers/scsi/qedf/qedf_io.c  | 2303 ++++++++++++++++++++++++++++++++++++=
++++++
>  2 files changed, 2730 insertions(+)
>  create mode 100644 drivers/scsi/qedf/qedf_hsi.h
>  create mode 100644 drivers/scsi/qedf/qedf_io.c
> =

[ .. ]

> +static int qedf_execute_tmf(struct qedf_rport *fcport, struct scsi_cmnd =
*sc_cmd,
> +	uint8_t tm_flags)
> +{
> +	struct qedf_ioreq *io_req;
> +	struct qedf_mp_req *tm_req;
> +	struct fcoe_task_context *task;
> +	struct fc_frame_header *fc_hdr;
> +	struct fcp_cmnd *fcp_cmnd;
> +	struct qedf_ctx *qedf =3D fcport->qedf;
> +	int rc =3D 0;
> +	uint16_t xid;
> +	uint32_t sid, did;
> +	int tmo =3D 0;
> +	unsigned long flags;
> +
> +	if (!sc_cmd) {
> +		QEDF_ERR(&(qedf->dbg_ctx), "invalid arg\n");
> +		return FAILED;
> +	}
> +
> +	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
> +		QEDF_ERR(&(qedf->dbg_ctx), "fcport not offloaded\n");
> +		rc =3D FAILED;
> +		return FAILED;
> +	}
> +
> +	scsi_block_requests(qedf->lport->host);
> +
Typically, EH commands will be executed after the scsi host is stopped
and no commands are outstanding.
So there's no point in issuing 'scsi_block_requests()' here.

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		      zSeries & Storage
hare-l3A5Bk7waGM@public.gmane.org			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: J. Hawn, J. Guild, F. Imend=F6rffer, HRB 16746 (AG N=FCrnberg)
