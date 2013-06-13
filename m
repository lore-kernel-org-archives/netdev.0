From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH 1/2] macvtap: slient sparse warnings
Date: Thu, 13 Jun 2013 14:27:56 +0800
Message-ID: <51B9666C.7090108@redhat.com>
References: <1371097294-5626-1-git-send-email-jasowang@redhat.com> <1371102507.3252.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371102507.3252.96.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2013 01:48 PM, Eric Dumazet wrote:
> On Thu, 2013-06-13 at 12:21 +0800, Jason Wang wrote:
>> This patch silents the following sparse warnings:
>>
>> dr
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/macvtap.c      |    2 +-
>>  include/linux/if_macvlan.h |    2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 992151c..acf55ba 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -429,7 +429,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
>>  	if (!q)
>>  		goto out;
>>  
>> -	q->sock.wq = &q->wq;
>> +	rcu_assign_pointer(q->sock.wq, &q->wq);
> Since nobody but you [1] can access this object at that time, you could
> rather use
> 	RCU_INIT_POINTER(q->sock.wq, &q->wq);
>
> rcu_assign_pointer() is also a documentation point (memory barrier)
>
> By using RCU_INIT_POINTER() you clearly show that you know you need no
> memory barrier.
>

True.
>>  	init_waitqueue_head(&q->wq.wait);
> [1] :
> or else, this init_waitqueue_head() should be done _before_ the
> rcu_asign_pointer()

Thanks, I will send v2 by using RCU_INIT_POINTER().
>
>>  	q->sock.type = SOCK_RAW;
>>  	q->sock.state = SS_CONNECTED;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
