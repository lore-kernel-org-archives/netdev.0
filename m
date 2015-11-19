From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [PATCH] bnx2x:Fix error handling and return statement in the
 function bnx2x_vf_init
Date: Thu, 19 Nov 2015 12:13:37 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C859087C45CD@avmb3.qlogic.org>
References: <1447903880-9369-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447903880-9369-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Nicholas Krause [mailto:xerofoify@gmail.com]
> Sent: Thursday, November 19, 2015 5:31 AM
> To: Ariel Elior <Ariel.Elior@qlogic.com>
> Cc: netdev <netdev@vger.kernel.org>; linux-kernel <linux-kernel@vger.kernel.org>
> Subject: [PATCH] bnx2x:Fix error handling and return statement in the function
> bnx2x_vf_init
> 
> This fixes error handling and the return statement in the function
> bnx2x_vf_init to properly check and return the error code returned
> by the call to the function bnx2x_post_vf_bulletin in order to
> allow callers of bnx2x_vf_init to be properly signaled and be able to
> handle in their own intended error paths if a error code is returned
> by this particular function call.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> index 9d02734..4434cdb 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> @@ -2087,6 +2087,7 @@ int bnx2x_vf_init(struct bnx2x *bp, struct bnx2x_virtf *vf,
> dma_addr_t *sb_map)
>  {
>  	struct bnx2x_func_init_params func_init = {0};
>  	int i;
> +	int rc;
> 
>  	/* the sb resources are initialized at this point, do the
>  	 * FW/HW initializations
> @@ -2129,9 +2130,9 @@ int bnx2x_vf_init(struct bnx2x *bp, struct bnx2x_virtf *vf,
> dma_addr_t *sb_map)
>  	vf->state = VF_ENABLED;
> 
>  	/* update vf bulletin board */
> -	bnx2x_post_vf_bulletin(bp, vf->index);
> +	rc = bnx2x_post_vf_bulletin(bp, vf->index);
> 
> -	return 0;
> +	return rc;
>  }
> 
>  struct set_vf_state_cookie {
> --
> 2.5.0

Acked-by: Ariel Elior <ariel.elior@qlogic.com>
