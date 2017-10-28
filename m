From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next] qed: Set error code for allocation failures
Date: Sat, 28 Oct 2017 13:50:25 +0800
Message-ID: <d7bf6549-b3ce-f2d8-3879-69002f38dbcb@huawei.com>
References: <20171027064020.aq52ue4kfp5htrb5@mwanda>
 <9ae1759e-18a1-18fb-ec93-8edf947b1cc6@huawei.com>
 <20171027115252.hhqc2u6zrn5b4uet@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <Ariel.Elior@cavium.com>,
        <everest-linux-l2@cavium.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:9464 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdJ1FwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:52:19 -0400
In-Reply-To: <20171027115252.hhqc2u6zrn5b4uet@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dan

On 2017/10/27 19:52, Dan Carpenter wrote:
> On Fri, Oct 27, 2017 at 05:32:42PM +0800, Yunsheng Lin wrote:
>> Hi, Dan
>>
>> On 2017/10/27 14:40, Dan Carpenter wrote:
>>> There are several places where we accidentally return success when
>>> kcalloc() fails.
>>>
>>> Fixes: fcb39f6c10b2 ("qed: Add mpa buffer descriptors for storing and processing mpa fpdus")
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>
>>> diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
>>> index 409041eab189..6366f2ef82b7 100644
>>> --- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
>>> +++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
>>> @@ -2585,7 +2585,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>>>  	struct qed_ll2_cbs cbs;
>>>  	u32 mpa_buff_size;
>>>  	u16 n_ooo_bufs;
>>> -	int rc = 0;
>>> +	int rc;
>>>  	int i;
>>>  
>>>  	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
>>> @@ -2696,6 +2696,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>>>  	if (rc)
>>>  		goto err;
>>>  
>>> +	rc = -ENOMEM;
>>>  	iwarp_info->partial_fpdus = kcalloc((u16)p_hwfn->p_rdma_info->num_qps,
>>>  					    sizeof(*iwarp_info->partial_fpdus),
>>>  					    GFP_KERNEL);
>>
>> Does the memory allocated here need to be freed when error happens below?
>>
> 
> Hm...  I think you're right that it leaks.  Also I'm confused by the
> qed_iwarp_ll2_alloc_buffers() allocation.  The comment in there says
> that /* buffers will be deallocated by qed_ll2 */ but qed_ll2 is not
> a function name or something which is useful to grep.

Yes, I am confused by it too.

Even in qed_iwarp_ll2_alloc_buffers, if kzcalloc failed, it do not clean
up the memory allocated by pre kzcalloc.

> 
> regards,
> dan carpenter
> 
> 
> .
> 
