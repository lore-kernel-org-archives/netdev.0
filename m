From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] libcxgbi: do not print a message when memory allocation
 fails
Date: Mon, 26 Dec 2011 16:41:22 -0200
Message-ID: <20111226184122.GA4277@oc1711230544.ibm.com>
References: <1323877583-6844-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <8A71B368A89016469F72CD08050AD3340AA0DF94@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu, davem@davemloft.net,
	JBottomley@parallels.com, linux-kernel@vger.kernel.org
To: Karen Xie <kxie@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8A71B368A89016469F72CD08050AD3340AA0DF94@maui.asicdesigners.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2011 at 04:52:42PM -0800, Karen Xie wrote:
> The patch looks fine to me.
> 
> Thanks,
> Karen
> 

Hi, Karen.

Thanks for your quick response.

Care to send a proper Acked-by? It seems this patch has not yet catch up
in James' tree.

Regards.
Cascardo.


> -----Original Message-----
> From: Thadeu Lima de Souza Cascardo [mailto:cascardo@linux.vnet.ibm.com]
> 
> Sent: Wednesday, December 14, 2011 7:46 AM
> To: linux-scsi@vger.kernel.org
> Cc: netdev@vger.kernel.org; Karen Xie; michaelc@cs.wisc.edu;
> davem@davemloft.net; JBottomley@parallels.com;
> linux-kernel@vger.kernel.org; Thadeu Lima de Souza Cascardo
> Subject: [PATCH] libcxgbi: do not print a message when memory allocation
> fails
> 
> In alloc_pdu, libcxgbi tries to allocate a skb with GFP_ATOMIC, which
> may potentially fail. When it happens, the current code prints a warning
> message.
> 
> When the system is under IO stress, this failure may happen lots of
> times and it usually scares users.
> 
> Instead of printing the warning message, the code now increases the
> tx_dropped statistics for the ethernet interface wich is doing the iscsi
> task.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo
> <cascardo@linux.vnet.ibm.com>
> ---
>  drivers/scsi/cxgbi/libcxgbi.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/scsi/cxgbi/libcxgbi.c
> b/drivers/scsi/cxgbi/libcxgbi.c
> index c10f74a..3422bc2 100644
> --- a/drivers/scsi/cxgbi/libcxgbi.c
> +++ b/drivers/scsi/cxgbi/libcxgbi.c
> @@ -1862,8 +1862,9 @@ int cxgbi_conn_alloc_pdu(struct iscsi_task *task,
> u8 opcode)
>  
>  	tdata->skb = alloc_skb(cdev->skb_tx_rsvd + headroom,
> GFP_ATOMIC);
>  	if (!tdata->skb) {
> -		pr_warn("alloc skb %u+%u, opcode 0x%x failed.\n",
> -			cdev->skb_tx_rsvd, headroom, opcode);
> +		struct cxgbi_sock *csk = cconn->cep->csk;
> +		struct net_device *ndev = cdev->ports[csk->port_id];
> +		ndev->stats.tx_dropped++;
>  		return -ENOMEM;
>  	}
>  
> -- 
> 1.7.4.4
> 

