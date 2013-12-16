From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH net-next 2/4] tipc: kill unnecessary goto's
Date: Mon, 16 Dec 2013 22:19:47 +0800
Message-ID: <52AF0C03.40409@gmail.com>
References: <1387197631-17240-1-git-send-email-wangweidong1@huawei.com> <1387197631-17240-3-git-send-email-wangweidong1@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7495@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: erik.hugne@ericsson.com, maloy@donjonn.com, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:37630 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab3LPOTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 09:19:24 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so5396376pde.28
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 06:19:24 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7495@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang weidong <wangweidong1@huawei.com>

On 2013/12/16 21:30, David Laight wrote:
>> From: Wang Weidong
>> Sent: 16 December 2013 12:40
>> Remove a number of needless 'goto exit' in send_stream
>> when the socket is in an unconnected state.
>> This patch is cosmetic and does not alter the operation of
>> TIPC in any way.
>>
>> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/tipc/socket.c | 14 ++++++--------
>>   1 file changed, 6 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
>> index 32037c5..844bf34 100644
>> --- a/net/tipc/socket.c
>> +++ b/net/tipc/socket.c
>> @@ -751,16 +751,14 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
>>
>>   	/* Handle special cases where there is no connection */
>>   	if (unlikely(sock->state != SS_CONNECTED)) {
>> -		if (sock->state == SS_UNCONNECTED) {
>> +		res = -ENOTCONN;
>> +
>> +		if (sock->state == SS_UNCONNECTED)
>>   			res = send_packet(NULL, sock, m, total_len);
>> -			goto exit;
>> -		} else if () {
>> +		else if (sock->state == SS_DISCONNECTING)
>>   			res = -EPIPE;
>> -			goto exit;
>> -		} else {
>> -			res = -ENOTCONN;
>> -			goto exit;
>> -		}
>> +
>> +		goto exit;
>
> I'm not sure that 'removing needless gotos' is a good description of the change.
> Possibly the code is easier to read with only one goto, ymmv.

I thinks so.

> You could remove the 'else' after the 'goto'.
> Maybe the easiest to read is:
> 	if (sock->state == SS_UNCONNECTED)
> 		res = send_packet(NULL, sock, m, total_len);
> 	else
> 		res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
> 	goto exit;
>
> 	David
>
Thanks for your suggestion. I will fix it too.

Regards.
Wang
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
