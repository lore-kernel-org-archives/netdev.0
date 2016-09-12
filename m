From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] net: inet: diag: Fix an error handling
Date: Mon, 12 Sep 2016 20:20:53 +0200
Message-ID: <3861cfae-c325-c6c1-803a-3996ee3e8242@wanadoo.fr>
References: <1473660133-9195-1-git-send-email-christophe.jaillet@wanadoo.fr>
 <255c4841-f8d2-062f-f4ba-871c91b92e1b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <255c4841-f8d2-062f-f4ba-871c91b92e1b@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/09/2016 à 16:35, David Ahern a écrit :
> On 9/12/16 12:02 AM, Christophe JAILLET wrote:
>> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
>> index abfbe492ebfe..795af25cf84c 100644
>> --- a/net/ipv4/inet_diag.c
>> +++ b/net/ipv4/inet_diag.c
>> @@ -1134,7 +1134,6 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
>>   
>>   	handler = inet_diag_lock_handler(sk->sk_protocol);
>>   	if (IS_ERR(handler)) {
>> -		inet_diag_unlock_handler(handler);
>>   		nlmsg_cancel(skb, nlh);
>>   		return PTR_ERR(handler);
>>   	}
>>
> That call is needed. inet_diag_unlock_handler does not operate on the input arg but a global mutex. Perhaps a better patch is to change inet_diag_unlock_handler() to a void.
This is obvious. Sorry for the noise.

CJ
