From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [for-next 08/12] net/mlx5e: IPoIB, Use hash-table to map between
 QPN to child netdev
Date: Mon, 23 Oct 2017 09:47:36 -0600
Message-ID: <20171023154736.GF11952@obsidianresearch.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
 <20171014184827.18491-9-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171014184827.18491-9-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 14, 2017 at 11:48:23AM -0700, Saeed Mahameed wrote:
> From: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> This change is needed for PKEY support, since the RQs are shared
> between the child interface and the parent. The parent is responsible
> for NAPI and the precessing of RX completions. Using the dqpn in the
> completion descriptor we set the corresponding child IPoIB netdevice
> on the SKB.
> The mapping between the dqpn and the netdevice is done using a HT,
> each mlx5 IPoIB interface registers its mapping on creation.

It seems really really weird to share the receive Q across all of the
children and do the sorting in software.. why is this done like this?

Wouldn't it be better to allow the children to progress concurrently,
potentially on multiple cores? They all have their own QPs after all..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
