From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Wed, 06 May 2009 11:40:54 -0500
Message-ID: <4A01BD96.60204@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-4-git-send-email-mchan@broadcom.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1241208039-6813-4-git-send-email-mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Michael Chan wrote:
> Add ISCSI_NETLINK messages to get/set vendor specific information.
> This is to support bnx2i that handles net config of private iSCSI
> IP address in userspace.
> 
> Signed-off-by: Anil Veerabhadrappa <anilgv-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  drivers/scsi/scsi_transport_iscsi.c |   59 ++++++++++++++++++++++++++++++++++-
>  include/scsi/iscsi_if.h             |   14 ++++++++
>  include/scsi/scsi_transport_iscsi.h |    6 +++
>  3 files changed, 78 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
> index 0947954..ef3af96 100644
> --- a/drivers/scsi/scsi_transport_iscsi.c
> +++ b/drivers/scsi/scsi_transport_iscsi.c
> @@ -995,6 +995,37 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
>  }
>  EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
>  
> +extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost,

Just a cut and paste error probably. You have an extern in there.

> +				  struct iscsi_transport *transport,
> +				  uint16_t priv_op,
> +				  char *data, uint16_t data_size)
> +{
