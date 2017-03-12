From: "santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 1/4] rds: ib: drop unnecessary rdma_reject
Date: Sun, 12 Mar 2017 12:43:42 -0700
Message-ID: <5ad1f78a-f558-7b26-7a31-95cd7507237f@oracle.com>
References: <1489306078-3354-1-git-send-email-yanjun.zhu@oracle.com>
 <20170312193357.GH2079@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170312193357.GH2079-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/12/17 12:33 PM, Leon Romanovsky wrote:
> On Sun, Mar 12, 2017 at 04:07:55AM -0400, Zhu Yanjun wrote:
>> When rdma_accept fails, rdma_reject is called in it. As such, it is
>> not necessary to execute rdma_reject again.
>>
>> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> ---
>> Change from v1 to v2:
>>   Add the acker.
>>
>>  net/rds/ib_cm.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
>> index ce3775a..eca3d5f 100644
>> --- a/net/rds/ib_cm.c
>> +++ b/net/rds/ib_cm.c
>> @@ -677,8 +677,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>>  		event->param.conn.initiator_depth);
>>
>>  	/* rdma_accept() calls rdma_reject() internally if it fails */
>> -	err = rdma_accept(cm_id, &conn_param);
>> -	if (err)
>> +	if (rdma_accept(cm_id, &conn_param))
>>  		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
>
> You omitted initialization of "err" variable which you print here ^^^^^.
>
Its inited by rds_ib_setup_qp() but you are right. It will print
failed with error = 0. :-)

Zhu, please drop that 'err' from the message.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
