From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 10/18] RDS: IB: track and log active side
 endpoint in connection
Date: Wed, 7 Dec 2016 08:29:14 -0800
Message-ID: <7079ed0b-c05f-5223-7216-6a75025b3205@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
 <1481083316-11648-11-git-send-email-santosh.shilimkar@oracle.com>
 <20161207.105318.2143064665652853543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207.105318.2143064665652853543.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/7/2016 7:53 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Tue,  6 Dec 2016 20:01:48 -0800
>
>> @@ -181,6 +181,9 @@ struct rds_ib_connection {
>>
>>  	/* Batched completions */
>>  	unsigned int		i_unsignaled_wrs;
>> +
>> +	/* Endpoint role in connection */
>> +	int			i_active_side;
>>  };
>>
>  ...
>> @@ -685,6 +686,7 @@ int rds_ib_cm_initiate_connect(struct rdma_cm_id *cm_id)
>>  		if (ic->i_cm_id == cm_id)
>>  			ret = 0;
>>  	}
>> +	ic->i_active_side = true;
>>  	return ret;
>>  }
>>
>> @@ -859,6 +861,7 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
>>  	ic->i_sends = NULL;
>>  	vfree(ic->i_recvs);
>>  	ic->i_recvs = NULL;
>> +	ic->i_active_side = false;
>>  }
>>
>>  int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
>
> Use type "bool", not "int", for true/false values.
>
OK. Will fix it.

Regards,
Santosh
