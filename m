From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] iov_iter: don't revert if csum error
Date: Sat, 29 Apr 2017 10:12:45 +0800
Message-ID: <1aa47008-d414-4731-e83b-39dbb9c2c2c3@huawei.com>
References: <080dafec-c57f-0546-4d2f-ce4a31222e25@huawei.com>
 <20170428131631.GA22996@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <pabeni@redhat.com>,
        <edumazet@google.com>, <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170428131631.GA22996@bistromath.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/4/28 21:16, Sabrina Dubroca wrote:
> 2017-04-28, 20:48:45 +0800, Ding Tianhong wrote:
>> The patch 3278682 (make skb_copy_datagram_msg() et.al. preserve
>> ->msg_iter on error) will revert the iov buffer if copy to iter
>> failed, but it looks no need to revert for csum error, so fix it.
>>
>> Fixes: 3278682 ("make skb_copy_datagram_msg() et.al. preserve->msg_iter on error")
> 
> Please use 12 digits, ie 327868212381.
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/core/datagram.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/datagram.c b/net/core/datagram.c
>> index f4947e7..475a8e9 100644
>> --- a/net/core/datagram.c
>> +++ b/net/core/datagram.c
>> @@ -760,7 +760,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
>>
>>  	if (msg_data_left(msg) < chunk) {
>>  		if (__skb_checksum_complete(skb))
>> -			goto csum_error;
>> +			goto fault;
> 
> With this patch, skb_copy_and_csum_datagram_msg() will return -EFAULT
> for an incorrect checksum, that doesn't seem right.
> 

Yes, should not change the return value, thanks.

Ding

>>  		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
>>  			goto fault;
>>  	} else {
>> -- 
>> 1.8.3.1
>>
> 
