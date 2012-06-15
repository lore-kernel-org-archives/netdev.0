From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [patch] qlcnic: off by one in qlcnic_init_pci_info()
Date: Thu, 14 Jun 2012 21:03:14 -0700
Message-ID: <CC000197.32F56%anirban.chakraborty@qlogic.com>
References: <20120614183424.GC6383@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe001.messaging.microsoft.com ([213.199.154.139]:30891
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725Ab2FOEDW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 00:03:22 -0400
In-Reply-To: <20120614183424.GC6383@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/14/12 11:34 AM, "Dan Carpenter" <dan.carpenter@oracle.com> wrote:

>The adapter->npars[] array has QLCNIC_MAX_PCI_FUNC elements.  We
>allocate it that way a few lines earlier in the function.  So this test
>is off by one.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>index 33c3e46..212c121 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>@@ -479,7 +479,7 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
> 
> 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
> 		pfn = pci_info[i].id;
>-		if (pfn > QLCNIC_MAX_PCI_FUNC) {
>+		if (pfn >= QLCNIC_MAX_PCI_FUNC) {
> 			ret = QL_STATUS_INVALID_PARAM;
> 			goto err_eswitch;
> 		}

Thanks for the patch.

Acked-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
