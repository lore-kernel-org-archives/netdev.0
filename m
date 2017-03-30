From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/2] virtio: allow drivers to validate features
Date: Thu, 30 Mar 2017 11:06:27 +0200
Message-ID: <20170330110627.01713921.cornelia.huck@de.ibm.com>
References: <1490807652-27889-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490807652-27889-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 20:14:44 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Some drivers can't support all features in all configurations.  At the
> moment we blindly set FEATURES_OK and later FAILED.  Support this better
> by adding a callback drivers can use to do some early checks.

Looks reasonable. Do we need to document that the driver must not do
anything beyond dealing with features and reading the config space that
early?

> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/virtio/virtio.c | 6 ++++++
>  include/linux/virtio.h  | 1 +
>  2 files changed, 7 insertions(+)
> 
> diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
> index 400d70b..48230a5 100644
> --- a/drivers/virtio/virtio.c
> +++ b/drivers/virtio/virtio.c
> @@ -232,6 +232,12 @@ static int virtio_dev_probe(struct device *_d)
>  		if (device_features & (1ULL << i))
>  			__virtio_set_bit(dev, i);
>  
> +	if (drv->validate) {
> +		err = drv->validate(dev);
> +		if (err)
> +			goto err;
> +	}
> +
>  	err = virtio_finalize_features(dev);
>  	if (err)
>  		goto err;
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 193fea9..ed04753 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -176,6 +176,7 @@ struct virtio_driver {
>  	unsigned int feature_table_size;
>  	const unsigned int *feature_table_legacy;
>  	unsigned int feature_table_size_legacy;
> +	int (*validate)(struct virtio_device *dev);
>  	int (*probe)(struct virtio_device *dev);
>  	void (*scan)(struct virtio_device *dev);
>  	void (*remove)(struct virtio_device *dev);

Would be good to add some doc; but other members are undocumented here
already...
