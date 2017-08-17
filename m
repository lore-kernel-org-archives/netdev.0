From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: make tun_build_skb() thread safe
Date: Thu, 17 Aug 2017 11:37:35 +0800
Message-ID: <13d6f0f3-62e1-d760-7504-341d420fa593@redhat.com>
References: <1502892873-10770-1-git-send-email-jasowang@redhat.com>
 <20170816195342-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816195342-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年08月17日 00:55, Michael S. Tsirkin wrote:
> On Wed, Aug 16, 2017 at 10:14:33PM +0800, Jason Wang wrote:
>> From: Eric Dumazet<eric.dumazet@gmail.com>
>>
>> tun_build_skb() is not thread safe since it uses per queue page frag,
>> this will break things when multiple threads are sending through same
>> queue. Switch to use per-thread generator (no lock involved).
>>
>> Fixes: 66ccbc9c87c2 ("tap: use build_skb() for small packet")
>> Tested-by: Jason Wang<jasowang@redhat.com>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
> Acked-by: Michael S. Tsirkin<mst@redhat.com>
>
> Jason, given the switch to task_frag, would it be worth it to look at
> using higher order allocs along the lines of
> 5640f7685831e088fe6c2e1f863a6805962f8e81 as well?
>

I think we've already used high order, don't we?

Thanks
