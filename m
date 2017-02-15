From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH v3 net] packet: Do not call fanout_release from atomic
 contexts
Date: Wed, 15 Feb 2017 21:30:08 +0000
Message-ID: <83b09a68-b759-2ae5-5918-53581731c9bf@citrix.com>
References: <1487190339-6366-1-git-send-email-anoob.soman@citrix.com>
 <1487192551.1311.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:43820 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbdBOVah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 16:30:37 -0500
In-Reply-To: <1487192551.1311.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/17 21:02, Eric Dumazet wrote:
> On Wed, 2017-02-15 at 20:25 +0000, Anoob Soman wrote:
>
>> +static struct packet_fanout *fanout_release(struct sock *sk)
>>   {
>>   	struct packet_sock *po = pkt_sk(sk);
>>   	struct packet_fanout *f;
>> @@ -1728,17 +1736,17 @@ static void fanout_release(struct sock *sk)
>>   	if (f) {
>>   		po->fanout = NULL;
>>   
>> -		if (atomic_dec_and_test(&f->sk_ref)) {
>> +		if (atomic_dec_and_test(&f->sk_ref))
>>   			list_del(&f->list);
>> -			dev_remove_pack(&f->prot_hook);
>> -			fanout_release_data(f);
>> -			kfree(f);
>> -		}
>> +		else
>> +			f = NULL;
>
> Patch looks good, except this coding style issue.
>
> if (...) {
>          multi lines;
>          expressions;
> } else {
>          f = NULL;
> }
>
>
> Not :
>
> if (...) {
>          multi lines;
>          expressions;
> } else
>          f = NULL;
If statement looks like this.
if (atomic_dec_and_test(sk_ref))
     list_del(f->list);
else
    f = NULL;

there are no multiple lines under if.
