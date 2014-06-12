From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost-scsi: don't open-code kvfree
Date: Thu, 12 Jun 2014 18:56:34 +0200
Message-ID: <5399DBC2.6070004@redhat.com>
References: <1402588896-25446-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1402588896-25446-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Il 12/06/2014 18:02, Michael S. Tsirkin ha scritto:
> Now that we have kvfree, use it in vhost-scsi instead of
> the open-coded version.
>
> Cc: Nicholas Bellinger <nab@linux-iscsi.org>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> I have this queued for -rc2.
> Nicholas could you review ack pls?
>
>  drivers/vhost/scsi.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index 83b834b..b08863e 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1396,14 +1396,6 @@ static int vhost_scsi_set_features(struct vhost_scsi *vs, u64 features)
>  	return 0;
>  }
>
> -static void vhost_scsi_free(struct vhost_scsi *vs)
> -{
> -	if (is_vmalloc_addr(vs))
> -		vfree(vs);
> -	else
> -		kfree(vs);
> -}
> -
>  static int vhost_scsi_open(struct inode *inode, struct file *f)
>  {
>  	struct vhost_scsi *vs;
> @@ -1443,7 +1435,7 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
>  	return 0;
>
>  err_vqs:
> -	vhost_scsi_free(vs);
> +	kvfree(vs);
>  err_vs:
>  	return r;
>  }
> @@ -1462,7 +1454,7 @@ static int vhost_scsi_release(struct inode *inode, struct file *f)
>  	/* Jobs can re-queue themselves in evt kick handler. Do extra flush. */
>  	vhost_scsi_flush(vs);
>  	kfree(vs->dev.vqs);
> -	vhost_scsi_free(vs);
> +	kvfree(vs);
>  	return 0;
>  }
>
>

You didn't CC Nicholas. :)  Anyway,

Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>

Paolo
