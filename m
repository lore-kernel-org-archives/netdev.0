From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
Date: Tue, 17 Dec 2013 06:37:40 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46CE9055@avmb2.qlogic.org>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: David Gibson <david@gibson.dropbear.id.au>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"Rajesh Borundia" <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:23315 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752071Ab3LQGhr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 01:37:47 -0500
In-Reply-To: <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
Content-Language: en-US
Content-ID: <D114BF2A54F7F243AE1113039AE7B464@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

You may also want to include fix for receive rings.

        if (unlikely(ring > adapter->max_rds_rings))
		return NULL;


Jiten

On 12/16/13 9:22 PM, "David Gibson" <david@gibson.dropbear.id.au> wrote:

>After retrieving an Rx buffer index from the hardware, the netxen driver
>bounds checks it against its array of receive buffers.  However in the
>case
>of LRO packets, there's an off-by-one error in the check - it uses >
>instead of the >= it uses for the normal receive path in
>netxen_process_rcv().
>
>Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
>---
> drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
>b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
>index 7692dfd..68658b8 100644
>--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
>+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
>@@ -1610,7 +1610,7 @@ netxen_process_lro(struct netxen_adapter *adapter,
> 	rds_ring = &recv_ctx->rds_rings[ring];
> 
> 	index = netxen_get_lro_sts_refhandle(sts_data0);
>-	if (unlikely(index > rds_ring->num_desc))
>+	if (unlikely(index >= rds_ring->num_desc))
> 		return NULL;
> 
> 	buffer = &rds_ring->rx_buf_arr[index];
>-- 
>1.8.3.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
