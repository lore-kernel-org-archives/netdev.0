From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 net-next 6/7] tap: support receiving skb from
 msg_control
Date: Fri, 31 Mar 2017 12:07:44 +0800
Message-ID: <e1b16f6c-f714-2efe-fe55-a7e827018012@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
 <1490858550-7763-7-git-send-email-jasowang@redhat.com>
 <20170330180140-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330180140-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年03月30日 23:03, Michael S. Tsirkin wrote:
> On Thu, Mar 30, 2017 at 03:22:29PM +0800, Jason Wang wrote:
>> This patch makes tap_recvmsg() can receive from skb from its caller
>> through msg_control. Vhost_net will be the first user.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>>   drivers/net/tap.c | 12 ++++++++----
>>   1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/tap.c b/drivers/net/tap.c
>> index abdaf86..07d9174 100644
>> --- a/drivers/net/tap.c
>> +++ b/drivers/net/tap.c
>> @@ -824,15 +824,17 @@ static ssize_t tap_put_user(struct tap_queue *q,
>>   
>>   static ssize_t tap_do_read(struct tap_queue *q,
>>   			   struct iov_iter *to,
>> -			   int noblock)
>> +			   int noblock, struct sk_buff *skb)
>>   {
>>   	DEFINE_WAIT(wait);
>> -	struct sk_buff *skb;
>>   	ssize_t ret = 0;
>>   
>>   	if (!iov_iter_count(to))
>>   		return 0;
>>   
>> +	if (skb)
>> +		goto done;
>> +
>>   	while (1) {
>>   		if (!noblock)
>>   			prepare_to_wait(sk_sleep(&q->sk), &wait,
>> @@ -856,6 +858,7 @@ static ssize_t tap_do_read(struct tap_queue *q,
>>   	if (!noblock)
>>   		finish_wait(sk_sleep(&q->sk), &wait);
>>   
>> +done:
> Please just use an if {} block here. goto on error is ok,
> but we are far from done here and goto done is misleading.
>
>

Ok.

Thanks.
