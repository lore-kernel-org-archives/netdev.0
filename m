From: rebelyouth <rebelyouth.hacklab@gmail.com>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast
 Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated)
 Version 2
Date: Sat, 23 Mar 2013 00:54:25 -0400
Message-ID: <514D3581.4040001@gmail.com>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:55846 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755516Ab3CWEy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 00:54:29 -0400
Received: by mail-ie0-f169.google.com with SMTP id qd14so4198579ieb.14
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 21:54:28 -0700 (PDT)
In-Reply-To: <20130323021008.GC939@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/03/13 10:10 PM, Hannes Frederic Sowa wrote:
> On Fri, Mar 22, 2013 at 08:07:22PM -0400, rebelyouth wrote:
>> On 22/03/13 07:54 PM, Eric Dumazet wrote:
>>> On Fri, 2013-03-22 at 19:07 -0400, rebelyouth wrote:
>>>> Hi,
>>>>
>>>> I'm writing again for the same issue about :
>>>>
>>> Your mail is so long that we are lost.
>>>
>>> Have you done some research to tell if the bug is :
>>>
>>> 1) Sending corrupt frames
>>>
>>> 2) receive corrupt frames
>>>
>>>
>> Hi Eric and Hannes,
>>
>> The server receiver errors  when I use the atheros:
>>
>> RX packets:78125369 errors:58741 dropped:0 overruns:58741 frame:0
>>
>> but on the client side  there aren't any error but the file  is corrupted
>>
>> I rebooted  the server and did the test with the Realtek:
>>
>>   file ok , no errors in both sides
>>
>> I also reset again the server and did a test on windows using samba and
>> the Atheros:
>>
>>   file ok , no errors in both sides
> Could you try this patch? It solves the problem with an atl1e nic on my
> friends computer. This does not solve the real problem, which I have
> not yet understood (wrong packets will be discarded now and will be
> hopefully resend).
>
> [PATCH RFC] atl1e: don't rely on hardware checksumming
>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> index e1f1b2a..0363e5b 100644
> --- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> +++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> @@ -1337,6 +1337,8 @@ static inline void atl1e_rx_checksum(struct atl1e_adapter *adapter,
>   	u16 err_flags;
>   
>   	skb_checksum_none_assert(skb);
> +	goto hw_xsum;
> +
>   	pkt_flags = prrs->pkt_flag;
>   	err_flags = prrs->err_flag;
>   	if (((pkt_flags & RRS_IS_IPV4) || (pkt_flags & RRS_IS_IPV6)) &&
Hi Hannes,

I applied your patch on my the kernel 3.7.9 and look like the patch do 
what you said before :

"This does not solve the real problem, which I have not yet understood 
(wrong packets will be discarded now and will be hopefully resend). "

There are errors on the RX side of the server and the speed is 5~10% 
less but the files are ok in nfsv4 , SFTP/FTP and samba.

Maybe the Atheros drivers for windows had a patch for the checksum 
already in the drivers and the chipset  have some hardware bug, but for 
me your patch is already an achievement and I really thank you for your 
time and consideration.

You will upload  this patch to be included in the kernel? I hope so, a 
lot of people had problem with this issue before and will be fantastic 
if this fix will be included.

Thank you

Rebelyouth
