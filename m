From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH (net.git)] stmmac: display the descriptors if DES0 = 0
Date: Thu, 20 Oct 2016 11:29:35 +0200
Message-ID: <98fb451a-9d51-c372-f75b-a9ee79a564c0@st.com>
References: <1476950488-24923-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:46241 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751044AbcJTJ3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 05:29:40 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
        by mx07-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u9K9RNKn029674
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:29:38 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
        by mx07-.pphosted.com with ESMTP id 266f85uamy-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:29:38 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
        by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B146738
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:29:37 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
        by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7C6B92464
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:29:37 +0000 (GMT)
In-Reply-To: <1476950488-24923-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

On 10/20/2016 10:01 AM, Giuseppe Cavallaro wrote:
> It makes sense to display the descriptors even if
> DES0 is zero. This helps for example in case of it
> is needed to dump rx write-back descriptors to get
> timestamp status.
>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre TORGUE <alexandre.torgue@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> index 4ec7397..a1b17cd 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> @@ -347,10 +347,9 @@ static void dwmac4_display_ring(void *head, unsigned int size, bool rx)
>  	pr_info("%s descriptor ring:\n", rx ? "RX" : "TX");
>
>  	for (i = 0; i < size; i++) {
> -		if (p->des0)
> -			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
> -				i, (unsigned int)virt_to_phys(p),
> -				p->des0, p->des1, p->des2, p->des3);
> +		pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
> +			i, (unsigned int)virt_to_phys(p),
> +			p->des0, p->des1, p->des2, p->des3);
>  		p++;
>  	}
>  }
>
I agree. Acked-by: Alexandre Torgue <alexandre.torgue@st.com>

Thanks
Alex
