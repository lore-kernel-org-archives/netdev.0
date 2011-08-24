From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [patch -next] bna: off by one in bfa_msgq_rspq_pi_update()
Date: Wed, 24 Aug 2011 10:33:11 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A9E4B8C4E8@HQ1-EXCH01.corp.brocade.com>
References: <20110824113028.GD5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Debashis Dutt <ddutt@brocade.com>,
	"open list:BROCADE BNA 10 GI..." <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Jing Huang <huangj@Brocade.COM>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36924 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752618Ab1HXRdU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 13:33:20 -0400
In-Reply-To: <20110824113028.GD5975@shale.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Dan Carpenter [mailto:error27@gmail.com]
>Sent: Wednesday, August 24, 2011 4:30 AM
>
>The rspq->rsphdlr[] array has BFI_MC_MAX elements, so this test was
>off by one.
>
>Signed-off-by: Dan Carpenter <error27@gmail.com>
>
>diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
>b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
>index ed52187..dd36427 100644
>--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
>+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
>@@ -483,7 +483,7 @@ bfa_msgq_rspq_pi_update(struct bfa_msgq_rspq *rspq,
>struct bfi_mbmsg *mb)
> 		mc = msghdr->msg_class;
> 		num_entries = ntohs(msghdr->num_entries);
>
>-		if ((mc > BFI_MC_MAX) || (rspq->rsphdlr[mc].cbfn == NULL))
>+		if ((mc >= BFI_MC_MAX) || (rspq->rsphdlr[mc].cbfn == NULL))
> 			break;
>
> 		(rspq->rsphdlr[mc].cbfn)(rspq->rsphdlr[mc].cbarg, msghdr);

Acked-by: Rasesh Mody <rmody@brocade.com>

Thanks,
Rasesh
