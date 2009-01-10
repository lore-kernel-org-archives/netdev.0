From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2][RFC] virtio_net: Enable setting MAC, promisc, and allmulti mode
Date: Sat, 10 Jan 2009 21:13:42 +1030
Message-ID: <200901102113.44185.rusty@rustcorp.com.au>
References: <1231351562.7109.129.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231351562.7109.129.camel@lappy>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 January 2009 04:36:02 Alex Williamson wrote:
> virtio_net: Enable setting MAC, promisc, and allmulti mode

Hi Alex,

   There's nothing wrong with this idea: I assume you have an actual usage
for this rather than it being an abstract improvement?

> @@ -41,7 +41,14 @@ struct virtnet_info
>  	struct virtqueue *rvq, *svq;
>  	struct net_device *dev;
>  	struct napi_struct napi;
> -	unsigned int status;
> +	union {
> +		u16 raw;
> +		struct {
> +			u16 link:1;
> +			u16 promisc:1;
> +			u16 allmulti:1;
> +		} bits;
> +	} status;

I don't think this works, as it depends on bitfield endian.

> @@ -30,7 +32,14 @@ struct virtio_net_config
>  	__u8 mac[6];
>  	/* Status supplied by host; see VIRTIO_NET_F_STATUS and VIRTIO_NET_S_*
>  	 * bits above */
> -	__u16 status;
> +	union {
> +		__u16 raw;
> +		struct {
> +			__u16 link:1;
> +			__u16 promisc:1;
> +			__u16 allmulti:1;
> +		} bits;
> +       } status;
>  } __attribute__((packed));

As does this.  I think we need to leave the status bitfield as is.

Thanks,
Rusty.
