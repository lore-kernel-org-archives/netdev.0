From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [patch] qlcnic: info leak in qlcnic_dcb_peer_app_info()
Date: Mon, 26 May 2014 05:28:29 +0000
Message-ID: <290BEC245535C3449143D5D84900EEF78CE2AAD5@avmb3.qlogic.org>
References: <20140523163721.GA14067@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:34448 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbaEZF2e convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 01:28:34 -0400
In-Reply-To: <20140523163721.GA14067@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Friday, May 23, 2014 10:07 PM
> To: Shahed Shaikh; Sucheta Chakraborty
> Cc: Dept-HSG Linux NIC Dev; netdev; kernel-janitors@vger.kernel.org
> Subject: [patch] qlcnic: info leak in qlcnic_dcb_peer_app_info()
> 
> This function is called from dcbnl_build_peer_app().  The "info"
> struct isn't initialized at all so we disclose 2 bytes of uninitialized
> stack data.  We should clear it before passing it to the user.
> 
> Fixes: 48365e485275 ('qlcnic: dcb: Add support for CEE Netlink
> interface.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Thanks,
Sucheta.

> ---
> This is a static analysis patch, and I am not familiar with this code.
> We may want to put some useful information here, to go with the
> app_count.
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> index a51fe18..561cb11 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> @@ -1020,6 +1020,7 @@ static int qlcnic_dcb_peer_app_info(struct
> net_device *netdev,
>  	struct qlcnic_dcb_cee *peer;
>  	int i;
> 
> +	memset(info, 0, sizeof(*info));
>  	*app_count = 0;
> 
>  	if (!test_bit(QLCNIC_DCB_STATE, &adapter->dcb->state))
