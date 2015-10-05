From: Carol Soto <clsoto@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Test interrupts fail if not all
 comp vectors called request_irq
Date: Mon, 5 Oct 2015 10:24:19 -0500
Message-ID: <56129623.3060800@linux.vnet.ibm.com>
References: <1443551891-17971-1-git-send-email-clsoto@linux.vnet.ibm.com>
 <5610DD46.204@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
	amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e18.ny.us.ibm.com ([129.33.205.208]:34023 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbJEPYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:24:23 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Mon, 5 Oct 2015 11:24:22 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 422A9C90048
	for <netdev@vger.kernel.org>; Mon,  5 Oct 2015 11:12:31 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t95FOJG938928614
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 15:24:19 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t95FOI6h031968
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 11:24:19 -0400
In-Reply-To: <5610DD46.204@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/4/2015 3:03 AM, Or Gerlitz wrote:
> On 9/29/2015 9:38 PM, clsoto@linux.vnet.ibm.com wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>
>> Test interrupts fails if not all completion vectors called
>> request_irq. This case can happen if only mlx4_en loads and
>> we have more completion vectors than rx rings.
>
> good catch! is this a bug since the driver 0-day or was introduced by
> some recent commit? in the latercase, please add a Fixes: tag before 
> your S.O.B note.
Probably the issue was introduced by this one
Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
>>
>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c 
>> b/drivers/net/ethernet/mellanox/mlx4/eq.c
>> index 8e81e53..c344884 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
>> @@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
>>        * and performing a NOP command
>>        */
>>       for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
>> +        /* Make sure request_irq was called */
>> +        if (!priv->eq_table.eq[i].have_irq)
>> +            continue;
>> +
>>           /* Temporary use polling for command completions */
>>           mlx4_cmd_use_polling(dev);
>
