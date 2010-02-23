From: Juan Quintela <quintela@redhat.com>
Subject: Re: [PATCH 2/3] vhost: initialize log eventfd context pointer
Date: Tue, 23 Feb 2010 20:31:11 +0100
Message-ID: <m37hq3wxz4.fsf@trasno.mitica>
References: <cover.1266943453.git.mst@redhat.com>
	<f383d82104a04b92fe2953a4d8a98425c1ff6cde.1266943453.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	markmc@redhat.com, gleb@redhat.com, herbert.xu@redhat.com,
	dlaor@redhat.com, avi@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f383d82104a04b92fe2953a4d8a98425c1ff6cde.1266943453.git.mst@redhat.com>
	(Michael S. Tsirkin's message of "Tue, 23 Feb 2010 18:57:51 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote:
> vq log eventfd context pointer needs to be initialized, otherwise
> operation may fail or oops if log is enabled but log eventfd not set by
> userspace.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Reviewed-by: Juan Quintela <quintela@redhat.com>

When log_ctx for device is created, it is copied to the vq.  This reset
was missing.

> ---
>  drivers/vhost/vhost.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index c767279..d4f8fdf 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -121,6 +121,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->kick = NULL;
>  	vq->call_ctx = NULL;
>  	vq->call = NULL;
> +	vq->log_ctx = NULL;
>  }
>  
>  long vhost_dev_init(struct vhost_dev *dev,
