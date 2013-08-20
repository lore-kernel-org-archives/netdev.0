From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 2/3] net/mlx4_en: Notify user when TX ring in
 error state
Date: Tue, 20 Aug 2013 10:55:20 +0300
Message-ID: <521320E8.9020109@mellanox.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com> <1376894542-27854-3-git-send-email-amirv@mellanox.com> <521268CE.7040508@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:57783 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751304Ab3HTHz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 03:55:27 -0400
In-Reply-To: <521268CE.7040508@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/2013 21:49, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/19/2013 10:42 AM, Amir Vadai wrote:
> 
>> When hardware gets into error state, must notify user about it.
>> When QP in error state no traffic will be tx'ed from the attached
>> tx_ring.
> 
>> Driver should know how to recover from this unexpected state. I will
>> send later
>> on the recovery flow, but having the print shouldn't be delayed.
> 
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 ++++++++
>>   1 file changed, 8 insertions(+)
> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 6dcca98..157bcd1 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -362,6 +362,14 @@ static void mlx4_en_process_tx_cq(struct
>> net_device *dev, struct mlx4_en_cq *cq)
>>            */
>>           rmb();
>>
>> +        if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
>> +                 MLX4_CQE_OPCODE_ERROR)) {
>> +            struct mlx4_err_cqe *cqe_err = (struct mlx4_err_cqe *)cqe;
> 
>    Empty line wouldn't hurt here, after declaration.
> 
>> +            en_err(priv, "CQE error - vendor syndrom: 0x%x syndrom:
>> 0x%x\n",
> 
>    s/syndrom/syndrome/ as below?
> 
>> +                   cqe_err->vendor_err_syndrome,
>> +                   cqe_err->syndrome);
>> +        }
>> +
> 
> WBR, Sergei
> 
> 

Thanks - will be fixed for V1

Amir
