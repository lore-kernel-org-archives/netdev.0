From: Yanjun Zhu <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/5] rds: tcp: release the created connection
Date: Mon, 27 Mar 2017 16:05:45 +0800
Message-ID: <58D8C7D9.1070509@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
 <1490598390-13812-2-git-send-email-yanjun.zhu@oracle.com>
 <20170327073756.GA21982@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170327073756.GA21982-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2017/3/27 15:37, Sowmini Varadhan wrote:
> On (03/27/17 03:06), Zhu Yanjun wrote:
>> Date: Mon, 27 Mar 2017 03:06:26 -0400
>> From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> To: yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
>>   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>>   rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
>> Subject: [PATCH 1/5] rds: tcp: release the created connection
>> X-Mailer: git-send-email 2.7.4
>>
>> When some error occurs, the created connection should be destroyed.
> No please dont do this.
>
> This is the case when there are duelling connections. We want
> to reset the new (accept sock) and leave the old socket in place.
>
> How did you test this? Did you test it with network namespaces?
Sorry. I just made simple test. It seems that it worked well. Would you 
like to show me some test about this patch?

Thanks a lot.
Zhu Yanjun
>
> --Sowmini
>
>
>>   net/rds/tcp_listen.c | 1 +
>>
>> diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
>> index 5076788..58aa5bc 100644
>> --- a/net/rds/tcp_listen.c
>> +++ b/net/rds/tcp_listen.c
>> @@ -196,6 +196,7 @@ int rds_tcp_accept_one(struct socket *sock)
>>   rst_nsk:
>>   	/* reset the newly returned accept sock and bail */
>>   	kernel_sock_shutdown(new_sock, SHUT_RDWR);
>> +	rds_conn_destroy(conn);
>>   	ret = 0;
>>   out:
>>   	if (rs_tcp)
>> -- 
>> 2.7.4
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
