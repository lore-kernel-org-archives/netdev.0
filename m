From: Carol Soto <clsoto@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Tue, 6 Oct 2015 16:46:06 -0500
Message-ID: <5614411E.1070105@linux.vnet.ibm.com>
References: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
 <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
 <CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:50229 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbbJFVqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:46:09 -0400
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 15:46:08 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1CAD1C90045
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 17:34:18 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t96Lk6E064159930
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 21:46:06 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t96Lk5S5014372
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 17:46:06 -0400
In-Reply-To: <CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/6/2015 4:39 PM, Or Gerlitz wrote:
> On Wed, Oct 7, 2015 at 12:27 AM,  <clsoto@linux.vnet.ibm.com> wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>
>> If we get MAX_MSIX interrupts would like to have each receive ring
>> with his own msix interrupt line.
> so 9293267a3e2a  was only partially correct? and/or not fully optimal?
> please elaborate more on that in your change log.
just not fully optimal, with commit 9293267a3e2a if I have 64 MSIXs and 
2 ports I can get 8 rings for each port but then the rings will share 
the interrupt lines. For 64 MSIXs we can have each ring with his own 
interrupt line.

>> Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> Carol, you didn't use net/mlx4: prefix as ask for mlx4 driver patch
> titles, so please repost, but before that I'd like to see an ack from
> Matan for this patch as well.
Sorry completely missed it. When Matan acks will resend it.
>
> Or.
>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/main.c | 4 +---
>>   1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index 006757f..f03f513 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2673,10 +2673,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
>>
>>                  nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
>>                               nreq);
>> -               if (nreq > MAX_MSIX) {
>> +               if (nreq > MAX_MSIX)
>>                          nreq = MAX_MSIX;
>> -                       shared_ports = true;
>> -               }
>>
>>                  entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
>>                  if (!entries)
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
