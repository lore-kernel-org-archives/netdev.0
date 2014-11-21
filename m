From: Anish Bhatt <anish@chelsio.com>
Subject: RE: [PATCH net] cxgb4 : Fix DCB priority groups being returned in
 wrong order
Date: Fri, 21 Nov 2014 01:16:29 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D8D85F42@nice.asicdesigners.com>
References: <1416523564-28126-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Hariprasad S <hariprasad@chelsio.com>
To: Anish Bhatt <anish@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12075 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756700AbaKUBQc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 20:16:32 -0500
In-Reply-To: <1416523564-28126-1-git-send-email-anish@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Anish Bhatt [mailto:anish@chelsio.com]
> Sent: Thursday, November 20, 2014 2:46 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Hariprasad S; Anish Bhatt
> Subject: [PATCH net] cxgb4 : Fix DCB priority groups being returned in wrong
> order
> 
> Peer priority groups were being reversed, but this was missed in the
> previous fix sent out for this issue.
> 
> Fixes :	ee7bc3cdc270 ('cxgb4 : dcb open-lldp interop fixes')
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> index cca6049..d8e60b3 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> @@ -1082,7 +1082,7 @@ static int cxgb4_cee_peer_getpg(struct net_device
> *dev, struct cee_pg *pg)
>  	pgid = be32_to_cpu(pcmd.u.dcb.pgid.pgid);
> 
>  	for (i = 0; i < CXGB4_MAX_PRIORITY; i++)
> -		pg->prio_pg[i] = (pgid >> (i * 4)) & 0xF;
> +		pg->prio_pg[7 - i] = (pgid >> (i * 4)) & 0xF;
> 
>  	INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
>  	pcmd.u.dcb.pgrate.type = FW_PORT_DCB_TYPE_PGRATE; @@ -
> 1094,7 +1094,8 @@ static int cxgb4_cee_peer_getpg(struct net_device *dev,
> struct cee_pg *pg)
>  	}
> 
>  	for (i = 0; i < CXGB4_MAX_PRIORITY; i++)
> -		pg->pg_bw[i] = pcmd.u.dcb.pgrate.pgrate[i];
> +		pg->pg_bw[7 - i] = pcmd.u.dcb.pgrate.pgrate[
> +			(pgid >> (i * 4)) & 0xF];
> 
>  	return 0;
>  }
> --
> 2.1.3

Just sent out a v2, Dave please ignore this patch.
-Anish
