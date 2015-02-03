From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v2 18/18] vhost: vhost_scsi_handle_vq() should just use
 copy_from_user()
Date: Mon, 02 Feb 2015 16:42:56 -0800
Message-ID: <1422924176.24128.9.camel@haakon3.risingtidesystems.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
	 <1422863977-17668-18-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	target-devel <target-devel@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:51807 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbBCAm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 19:42:57 -0500
In-Reply-To: <1422863977-17668-18-git-send-email-viro@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Al,

On Mon, 2015-02-02 at 07:59 +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> it has just verified that it asks no more than the length of the
> first segment of iovec.
> 
> And with that the last user of stuff in lib/iovec.c is gone.
> RIP.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Nicholas A. Bellinger <nab@linux-iscsi.org>
> Cc: kvm@vger.kernel.org
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/vhost/scsi.c |  2 +-
>  include/linux/uio.h  |  2 --
>  lib/Makefile         |  2 +-
>  lib/iovec.c          | 36 ------------------------------------
>  4 files changed, 2 insertions(+), 40 deletions(-)
>  delete mode 100644 lib/iovec.c
> 
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index d695b16..dc78d87 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1079,7 +1079,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
>  			       req_size, vq->iov[0].iov_len);
>  			break;
>  		}
> -		ret = memcpy_fromiovecend(req, &vq->iov[0], 0, req_size);
> +		ret = copy_from_user(req, vq->iov[0].iov_base, req_size);
>  		if (unlikely(ret)) {
>  			vq_err(vq, "Faulted on virtio_scsi_cmd_req\n");
>  			break;

Is this in for-next yet..?

If not, please push out ASAP so SFR can hit the conflict between
target-pending/for-next as a heads up for Linus..

--nab
