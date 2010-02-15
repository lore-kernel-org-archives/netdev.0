From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] tun: socket filter support
Date: Mon, 15 Feb 2010 16:24:43 +0100
Message-ID: <4B79673B.7050908@trash.net>
References: <cover.1266144917.git.mst@redhat.com> <20100214110110.GC30182@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100214110110.GC30182@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
> +	case TUNATTACHFILTER:
> +		/* Can be set only for TAPs */
> +		ret = -EINVAL;
> +		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
> +			break;
> +		ret = -EFAULT;
> +		if (copy_from_user(&fprog, argp, sizeof(fprog)))
> +			break;
> +
> +		ret = sk_attach_filter(&fprog, tun->socket.sk);
> +		break;
> +
> +	case TUNDETACHFILTER:
> +		/* Can be set only for TAPs */
> +		ret = -EINVAL;
> +		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
> +			break;
> +		ret = sk_detach_filter(tun->socket.sk);
> +		break;
> +

I'm not sure how the tun socket is exposed, but won't the regular
SO_ATTACH_FILTER/SO_DETACH_FILTER setsockopts already work for
tun sockets?
