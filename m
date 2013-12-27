From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next v3 2/2] tipc: make the code look more readable
Date: Fri, 27 Dec 2013 09:59:51 +0800
Message-ID: <52BCDF17.9090907@huawei.com>
References: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com> <1387263827-20876-3-git-send-email-wangweidong1@huawei.com> <52BCDBA4.9050607@huawei.com> <52BCDD0C.6030508@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Ying Xue <ying.xue@windriver.com>, <jon.maloy@ericsson.com>,
	<allan.stephens@windriver.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:47232 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3L0CA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 21:00:26 -0500
In-Reply-To: <52BCDD0C.6030508@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/27 9:51, Ying Xue wrote:
> On 12/27/2013 09:45 AM, Wang Weidong wrote:
>> In commit 3b8401fe9d ("tipc: kill unnecessary goto's") didn't make
>> the code look most readable, so fix it. This patch is cosmetic
>> and does not change the operation of TIPC in any way.
>>
>> v3: fix the spelling error which pointed out by Sergei.
>>
>> v2: fix the problem "Referring commit purely by
>>     SHA1 ID is ambiguous" which pointed out by David.
>>
> 
> Please don't add review version history into patch head comments.
> 
Ok, Got it.

Thanks,
Wang

> 
>> Suggested-by: David Laight <David.Laight@ACULAB.COM>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/tipc/socket.c | 7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
>> index 83f466e..5efdeef 100644
>> --- a/net/tipc/socket.c
>> +++ b/net/tipc/socket.c
>> @@ -751,13 +751,10 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
>>  
>>  	/* Handle special cases where there is no connection */
>>  	if (unlikely(sock->state != SS_CONNECTED)) {
>> -		res = -ENOTCONN;
>> -
>>  		if (sock->state == SS_UNCONNECTED)
>>  			res = send_packet(NULL, sock, m, total_len);
>> -		else if (sock->state == SS_DISCONNECTING)
>> -			res = -EPIPE;
>> -
>> +		else
>> +			res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
>>  		goto exit;
>>  	}
>>  
>>
> 
> 
> .
> 
