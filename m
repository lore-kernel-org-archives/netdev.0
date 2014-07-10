From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH v7 15/33] net: xen-netback - set name assign type
Date: Thu, 10 Jul 2014 13:55:16 +0530
Message-ID: <53BE4DEC.7030909@gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no> <1404980258-30853-16-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
To: Tom Gundersen <teg@jklm.no>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-16-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/10/2014 01:47 PM, Tom Gundersen wrote:
> The name contains then xen handle, which is not guaranteed to be
> stable between restarts, so label this NET_NAME_ENUM.
>
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: xen-devel@lists.xenproject.org
> ---
>   drivers/net/xen-netback/interface.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 793275d..da906d1 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -418,8 +418,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>   	 * When the guest selects the desired number, it will be updated
>   	 * via netif_set_real_num_*_queues().
>   	 */
> -	dev = alloc_netdev_mq(sizeof(struct xenvif), name, NET_NAME_UNKNOWN,
> -			      ether_setup, xenvif_max_queues);
> +	dev = alloc_netdev_mq(sizeof(struct xenvif), name, NET_NAME_ENUM, ether_setup,
> +			      xenvif_max_queues);

What i am suggesting is irrelavent to this patch. But also consider this suggestion

In place sizeof(struct xenvif) --> sizeof(*vif) ???

>   	if (dev == NULL) {
>   		pr_warn("Could not allocate netdev for %s\n", name);
>   		return ERR_PTR(-ENOMEM);


-- 
Regards,
Varka Bhadram.
