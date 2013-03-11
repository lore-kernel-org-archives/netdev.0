From: Jason Wang <jasowang@redhat.com>
Subject: Re: TCP small packets throughput and multiqueue virtio-net
Date: Mon, 11 Mar 2013 14:21:46 +0800
Message-ID: <513D77FA.6040402@redhat.com>
References: <5139840A.6020204@redhat.com> <1362755115.15793.236.camel@edumazet-glaptop> <513A1F36.5020401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, KVM <kvm@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jpirko@redhat.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <513A1F36.5020401@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2013 01:26 AM, Rick Jones wrote:
>
>>
>> Well, the point is : if your app does write(1024) bytes, thats probably
>> because it wants small packets from the very beginning. (See the TCP
>> PUSH flag ?)
>
> I think that raises the question of whether or not Jason was setting
> the test-specific -D option on his TCP_STREAM tests, to have netperf
> make a setsockopt(TCP_NODELAY) call.

I didn't set the -D option to disable nagle. But I get almost the almost
same result with -D (1024 byte TCP_STREAM from guest to local host).
>
> happy benchmarking,
>
> rick jones
>
>> If the transport is slow, TCP stack will automatically collapse several
>> write into single skbs (assuming TSO or GSO is on), and you'll see big
>> GSO packets with tcpdump [1]. So TCP will help you to get less overhead
>> in this case.
>>
>> But if transport is fast, you'll see small packets, and thats good for
>> latency.
>>
>> So my opinion is : its exactly behaving as expected.
>>
>> If you want bigger packets either :
>> - Make the application doing big write()
>> - Slow the vmexit ;)
>>
>> [1] GSO fools tcpdump : Actual packets sent to the wire are not 'big
>> packets', but they hit dev_hard_start_xmit() as GSO packets.
>>
>>
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>

