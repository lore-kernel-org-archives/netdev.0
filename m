From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tun/macvtap: use consume_skb() instead of kfree_skb()
 in tun/macvtap_do_read()
Date: Wed, 26 Nov 2014 14:41:43 +0800
Message-ID: <54757627.7060105@redhat.com>
References: <1416982084-12212-1-git-send-email-jasowang@redhat.com> <1416983160.29427.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416983160.29427.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2014 02:26 PM, Eric Dumazet wrote:
> On Wed, 2014-11-26 at 14:08 +0800, Jason Wang wrote:
>> To be more friendly with drop monitor, we should use comsume_skb() instead
>> of kfree_skb() in tun/macvtap_do_read(). Otherwise, the packets will be
>> marked as dropped.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/macvtap.c | 2 +-
>>  drivers/net/tun.c     | 2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 42a80d3..74d1b23 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -862,7 +862,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
>>  		}
>>  		iov_iter_init(&iter, READ, iv, segs, len);
>>  		ret = macvtap_put_user(q, skb, &iter);
>> -		kfree_skb(skb);
>> +		consume_skb(skb);
>>  		break;
>>  	}
>>  
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index ac53a73..d7edeaf 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1363,7 +1363,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>>  
>>  	iov_iter_init(&iter, READ, iv, segs, len);
>>  	ret = tun_put_user(tun, tfile, skb, &iter);
>> -	kfree_skb(skb);
>> +	consume_skb(skb);
>>  
>>  	return ret;
>>  }
>
> These patches keep going on, but they are wrong.
>
> If you care about drop monitor, then you want to not hide drops but
> precisely report them.
>
> Surely tun_put_user() can return an error, and then packet _is_ dropped.

True, I miss this. Will post V2. Thanks
