From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: correct length checks on hash
 copy_ops
Date: Wed, 18 May 2016 10:42:03 +0100
Message-ID: <20160518094203.GY8974@citrix.com>
References: <1463557981-17294-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36343 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbcERJmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 05:42:07 -0400
Content-Disposition: inline
In-Reply-To: <1463557981-17294-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 08:53:01AM +0100, Paul Durrant wrote:
> The length checks on the grant table copy_ops for setting hash key and
> hash mapping are checking the local 'len' value which is correct in
> the case of the former but not the latter. This was picked up by
> static analysis checks.
> 
> This patch replaces checks of 'len' with 'copy_op.len' in both cases
> to correct the incorrect check, keep the two checks consistent, and to
> make it clear what the checks are for.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/hash.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/hash.c b/drivers/net/xen-netback/hash.c
> index 392e392..fb87cb3 100644
> --- a/drivers/net/xen-netback/hash.c
> +++ b/drivers/net/xen-netback/hash.c
> @@ -311,7 +311,7 @@ u32 xenvif_set_hash_key(struct xenvif *vif, u32 gref, u32 len)
>  	if (len > XEN_NETBK_MAX_HASH_KEY_SIZE)
>  		return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
>  
> -	if (len != 0) {
> +	if (copy_op.len != 0) {
>  		gnttab_batch_copy(&copy_op, 1);
>  
>  		if (copy_op.status != GNTST_okay)
> @@ -359,7 +359,7 @@ u32 xenvif_set_hash_mapping(struct xenvif *vif, u32 gref, u32 len,
>  		if (mapping[off++] >= vif->num_queues)
>  			return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
>  
> -	if (len != 0) {
> +	if (copy_op.len != 0) {
>  		gnttab_batch_copy(&copy_op, 1);
>  
>  		if (copy_op.status != GNTST_okay)
> -- 
> 2.1.4
> 
