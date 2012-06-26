From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] use USER_DS in vhost_worker thread
Date: Tue, 26 Jun 2012 14:42:26 +0300
Message-ID: <20120626114226.GC13618@redhat.com>
References: <1340708398-17965-1-git-send-email-borntraeger@de.ibm.com>
 <1340708398-17965-2-git-send-email-borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Jens Freimann <jfrei@linux.vnet.ibm.com>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340708398-17965-2-git-send-email-borntraeger@de.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2012 at 12:59:58PM +0200, Christian Borntraeger wrote:
> From: Jens Freimann <jfrei@linux.vnet.ibm.com>
> 
> On some architectures address spaces are set up in a way that this is
> not necessary to work properly but on some others (like s390) it is.
> Make sure we operate on the user address space to allow copy_xxx_user()
> from the vhost_worker() thread by setting it explicitly before calling
> use_mm() and revert it after unuse_mm().
> 
> Signed-off-by: Jens Freimann <jfrei@linux.vnet.ibm.com>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

Dave, can you queue this up for 3.5 please?

Thanks.

> ---
>  drivers/vhost/vhost.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 94dbd25..112156f 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -191,7 +191,9 @@ static int vhost_worker(void *data)
>  	struct vhost_dev *dev = data;
>  	struct vhost_work *work = NULL;
>  	unsigned uninitialized_var(seq);
> +	mm_segment_t oldfs = get_fs();
>  
> +	set_fs(USER_DS);
>  	use_mm(dev->mm);
>  
>  	for (;;) {
> @@ -229,6 +231,7 @@ static int vhost_worker(void *data)
>  
>  	}
>  	unuse_mm(dev->mm);
> +	set_fs(oldfs);
>  	return 0;
>  }
>  
> -- 
> 1.7.0.4
