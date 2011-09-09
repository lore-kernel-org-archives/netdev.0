From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: [PATCH 2/2] GRETH: avoid overwrite IP-stack's IP-frags checksum
Date: Fri, 09 Sep 2011 16:41:05 +0200
Message-ID: <4E6A2581.9000709@gaisler.com>
References: <1315487676-16733-1-git-send-email-daniel@gaisler.com>	 <1315487676-16733-2-git-send-email-daniel@gaisler.com> <1315574967.2294.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kristoffer@gaisler.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:39152 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758408Ab1IIOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 10:40:21 -0400
In-Reply-To: <1315574967.2294.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2011 03:29 PM, Eric Dumazet wrote:
> Le jeudi 08 septembre 2011 =C3=A0 15:14 +0200, Daniel Hellstrom a =C3=
=A9crit :
>> The GRETH GBIT core does not do checksum offloading for IP
>> segmentation. This patch adds a check in the xmit function to
>> determine if the stack has calculated the checksum for us.
>>
>> Signed-off-by: Daniel Hellstrom<daniel@gaisler.com>
>> ---
>>   drivers/net/greth.c |    7 +++++--
>>   1 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/greth.c b/drivers/net/greth.c
>> index 9d39fb9..27ba855 100644
>> --- a/drivers/net/greth.c
>> +++ b/drivers/net/greth.c
>> @@ -489,7 +489,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struc=
t net_device *dev)
>>   	if (nr_frags !=3D 0)
>>   		status =3D GRETH_TXBD_MORE;
>>
>> -	status |=3D GRETH_TXBD_CSALL;
>> +	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
>> +		status |=3D GRETH_TXBD_CSALL;
>>   	status |=3D skb_headlen(skb)&  GRETH_BD_LEN;
>>   	if (greth->tx_next =3D=3D GRETH_TXBD_NUM_MASK)
>>   		status |=3D GRETH_BD_WR;
>> @@ -512,7 +513,9 @@ greth_start_xmit_gbit(struct sk_buff *skb, struc=
t net_device *dev)
>>   		greth->tx_skbuff[curr_tx] =3D NULL;
>>   		bdp =3D greth->tx_bd_base + curr_tx;
>>
>> -		status =3D GRETH_TXBD_CSALL | GRETH_BD_EN;
>> +		status =3D GRETH_BD_EN;
>> +		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
>> +			status | GRETH_TXBD_CSALL;
> 		typo here ?
Hi,

You're right, I had a missed space there so the code-style check failed=
 at that line, then I fixed that by adding a space... but must have scr=
ewed it up. Will repost patch.

Thanks,
Daniel



>
>>   		status |=3D frag->size&  GRETH_BD_LEN;
>>
>>   		/* Wrap around descriptor ring */
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
