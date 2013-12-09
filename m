From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v6 1/2] net: sched: tbf: fix the calculation of max_size
Date: Mon, 9 Dec 2013 11:26:02 +0800
Message-ID: <52A5384A.8050106@huawei.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com> <1386313205-87660-2-git-send-email-yangyingliang@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:2345 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760283Ab3LID0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:26:40 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/6 18:56, David Laight wrote:
>> From: Yang Yingliang
> ...
>>
>> +/* Time to Length, convert time in ns to length in bytes
>> + * to determinate how many bytes can be sent in given time.
>> + */
>> +static u64 psched_ns_t2l(const struct psched_ratecfg *r,
>> +			 u64 time_in_ns)
>> +{
>> +	/* The formula is :
>> +	 * len = (time_in_ns * r->rate_bytes_ps) / NSEC_PER_SEC
>> +	 */
>> +	u64 len = time_in_ns * r->rate_bytes_ps;
>> +
>> +	do_div(len, NSEC_PER_SEC);
> 
> You are multiplying two values then dividing by 10**9
> I'd guess that the intermediate value might exceed 2**64.
> 
>> +	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
>> +		len = (len / 53) * 48;
> 
> You probably want to do the multiply first.
> But why not scale rate_bytes_ps instead.
> 

When the linklayer is ATM, the formula to calculate tokens is:

((u64)(DIV_ROUND_UP(len,48)*53) * r->mult) >> r->shift

So, I scale len here.

Regards,
Yang
