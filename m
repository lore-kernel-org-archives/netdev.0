From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc v7 2/3] virtio_net: multiqueue support
Date: Mon, 3 Dec 2012 12:14:36 +0200
Message-ID: <20121203101436.GB23009@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
 <1354011360-39479-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, krkumar2@in.ibm.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr,
	shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354011360-39479-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 06:15:59PM +0800, Jason Wang wrote:
> -	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
> -		schedule_delayed_work(&vi->rq.refill, 0);
> +	for (i = 0; i < vi->max_queue_pairs; i++)
> +		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> +			schedule_delayed_work(&vi->rq[i].refill, 0);
>  
>  	mutex_lock(&vi->config_lock);
>  	vi->config_enable = true;
>  	mutex_unlock(&vi->config_lock);
>  
> +	BUG_ON(virtnet_set_queues(vi));
> +
>  	return 0;
>  }
>  #endif

Also crashing on device nack of command is also not nice.
In this case it seems we can just switch to
single-queue mode which should always be safe.
