From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: [PATCH resend] qla3xxx: convert byte order of constant instead ofvariable
Date: Tue, 12 Feb 2008 15:36:43 -0800
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC070127727B@AVEXCH1.qlogic.org>
References: <20080210100546.GA6737@joi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "LKML" <linux-kernel@vger.kernel.org>
To: "Marcin Slusarz" <marcin.slusarz@gmail.com>,
	<netdev@vger.kernel.org>, "Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:30435 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbYBLXgo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 18:36:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080210100546.GA6737@joi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Marcin Slusarz [mailto:marcin.slusarz@gmail.com] 
> Sent: Sunday, February 10, 2008 2:06 AM
> To: netdev@vger.kernel.org; Linux Driver
> Cc: LKML
> Subject: [PATCH resend] qla3xxx: convert byte order of 
> constant instead ofvariable
> 
> convert byte order of constant instead of variable
> which can be done at compile time (vs run time)
> 
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> ---
>  drivers/net/qla3xxx.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index a6aeb9d..b7f7b22 100644
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -2472,8 +2472,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
>  
>  	if (seg_cnt == 1) {
>  		/* Terminate the last segment. */
> -		oal_entry->len =
> -		    cpu_to_le32(le32_to_cpu(oal_entry->len) | 
> OAL_LAST_ENTRY);
> +		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
>  	} else {
>  		oal = tx_cb->oal;
>  		for (completed_segs=0; completed_segs<frag_cnt; 
> completed_segs++,seg++) {
> @@ -2530,8 +2529,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
>  					  frag->size);
>  		}
>  		/* Terminate the last segment. */
> -		oal_entry->len =
> -		    cpu_to_le32(le32_to_cpu(oal_entry->len) | 
> OAL_LAST_ENTRY);
> +		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
>  	}
>  
>  	return NETDEV_TX_OK;
> -- 
> 1.5.3.7
> 
> 

Thanks

Acked-by: Ron Mercer <ron.mercer@qlogic.com> 
