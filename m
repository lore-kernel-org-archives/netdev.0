From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: fix missing unlock on error in
 __ibmvnic_reset()
Date: Thu, 18 May 2017 12:29:36 -0500
Message-ID: <2a9bde84-eb86-c964-7be8-2018eae45d7b@linux.vnet.ibm.com>
References: <20170518152452.8606-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45050 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751974AbdERR3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 13:29:42 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4IHSjEu066649
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 13:29:41 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ahcfdu541-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 13:29:41 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Thu, 18 May 2017 13:29:40 -0400
In-Reply-To: <20170518152452.8606-1-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 10:24 AM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Add the missing unlock before return from function __ibmvnic_reset()
> in the error handling case.
> 
> Fixes: ed651a10875f ("ibmvnic: Updated reset handling")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

> ---
>  drivers/net/ethernet/ibm/ibmvnic.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
> index 4f2d329..27f7933 100644
> --- a/drivers/net/ethernet/ibm/ibmvnic.c
> +++ b/drivers/net/ethernet/ibm/ibmvnic.c
> @@ -1313,6 +1313,7 @@ static void __ibmvnic_reset(struct work_struct *work)
> 
>  	if (rc) {
>  		free_all_rwi(adapter);
> +		mutex_unlock(&adapter->reset_lock);
>  		return;
>  	}
> 
