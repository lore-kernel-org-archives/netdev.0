From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH] net: af_unix: protect ->sk_shutdown change with
 lock_sock()
Date: Wed, 18 May 2016 14:23:27 +0300
Message-ID: <573C50AF.6090301@virtuozzo.com>
References: <1463566486-9123-1-git-send-email-aryabinin@virtuozzo.com>
 <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a070f6f7-ed85-c909-ce8b-748210402211@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/18/2016 01:38 PM, Hannes Frederic Sowa wrote:
> On 18.05.2016 12:14, Andrey Ryabinin wrote:
>> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
>> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
>> sock_setsockopt() may write to these bits, while holding the socket lock.
>> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
>> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
>> to corrupting these bits.
>>
>> Fix that by protecting writes to ->sk_shutdown with lock_sock()
> 
> Is it possible to move sk_shutdown out of the bitfields? Maybe a whole
> which suites is available somewhere?
> 

Agreed. I see two possible 16-bit holes - one after 'sk_gso_max_segs'
and one more after 'sk_tsflags'.


> af_unix doesn't depend on the socket locks anywhere and it would keep
> locking much easier if we only depend on the state lock.
> 
> Bye,
> Hannes
> 
> 
