From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v4] xen-netback: Adding debugfs
 "io_ring_qX" files
Date: Tue, 8 Jul 2014 14:59:24 -0400
Message-ID: <20140708185923.GA32404@laptop.dumpdata.com>
References: <1404845354-16237-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404845354-16237-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -246,8 +415,12 @@ static void backend_create_xenvif(struct backend_info *be)
>  
>  static void backend_disconnect(struct backend_info *be)
>  {
> -	if (be->vif)
> +	if (be->vif) {
> +#ifdef CONFIG_DEBUG_FS
> +		xenvif_debugfs_delif(be->vif);
> +#endif /* CONFIG_DEBUG_FS */
>  		xenvif_disconnect(be->vif);
> +	}
>  }
>  
>  static void backend_connect(struct backend_info *be)
> @@ -560,6 +733,9 @@ static void connect(struct backend_info *be)
>  			be->vif->num_queues = queue_index;
>  			goto err;
>  		}
> +#ifdef CONFIG_DEBUG_FS
> +		xenvif_debugfs_addif(queue);
> +#endif /* CONFIG_DEBUG_FS */

You really like those /* CONFIG_DEBUG_FS */ comments, eh :-)

>  	}
>  
>  	/* Initialisation completed, tell core driver the number of
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
