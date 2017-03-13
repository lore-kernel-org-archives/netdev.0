From: Yanjun Zhu <yanjun.zhu@oracle.com>
Subject: Re: [PATCHv2 1/4] rds: ib: drop unnecessary rdma_reject
Date: Mon, 13 Mar 2017 08:59:28 +0800
Message-ID: <58C5EEF0.4050806@oracle.com>
References: <1489306078-3354-1-git-send-email-yanjun.zhu@oracle.com>
 <20170312193357.GH2079@mtr-leonro.local>
 <5ad1f78a-f558-7b26-7a31-95cd7507237f@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
To: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29767 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755792AbdCMA7L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 20:59:11 -0400
In-Reply-To: <5ad1f78a-f558-7b26-7a31-95cd7507237f@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/13 3:43, santosh.shilimkar@oracle.com wrote:
> On 3/12/17 12:33 PM, Leon Romanovsky wrote:
>> On Sun, Mar 12, 2017 at 04:07:55AM -0400, Zhu Yanjun wrote:
>>> When rdma_accept fails, rdma_reject is called in it. As such, it is
>>> not necessary to execute rdma_reject again.
>>>
>>> Cc: Joe Jin <joe.jin@oracle.com>
>>> Cc: Junxiao Bi <junxiao.bi@oracle.com>
>>> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>>> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
>>> ---
>>> Change from v1 to v2:
>>>   Add the acker.
>>>
>>>  net/rds/ib_cm.c | 3 +--
>>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>>
>>> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
>>> index ce3775a..eca3d5f 100644
>>> --- a/net/rds/ib_cm.c
>>> +++ b/net/rds/ib_cm.c
>>> @@ -677,8 +677,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id 
>>> *cm_id,
>>>          event->param.conn.initiator_depth);
>>>
>>>      /* rdma_accept() calls rdma_reject() internally if it fails */
>>> -    err = rdma_accept(cm_id, &conn_param);
>>> -    if (err)
>>> +    if (rdma_accept(cm_id, &conn_param))
>>>          rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
>>
>> You omitted initialization of "err" variable which you print here ^^^^^.
>>
> Its inited by rds_ib_setup_qp() but you are right. It will print
> failed with error = 0. :-)
>
> Zhu, please drop that 'err' from the message.
OK. I will do.

Zhu Yanjun
