From: YueHaibing <yuehaibing@huawei.com>
Subject: Re: [PATCH RFC net-next 2/7] net: add dst_pending_confirm flag to
 skbuff
Date: Fri, 20 Jan 2017 11:39:25 +0800
Message-ID: <11f3e6c9-5eec-8275-3323-0c1de91f8c23@huawei.com>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>
 <1482094596-26046-3-git-send-email-ja@ssi.bg>
 <1482164252.1521.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.11.1612192203480.3105@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
        <linux-sctp@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25773 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdATDki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 22:40:38 -0500
In-Reply-To: <alpine.LFD.2.11.1612192203480.3105@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2016/12/20 4:37, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 19 Dec 2016, Eric Dumazet wrote:
> 
>> I am still digesting this awesome patch series ;)
> 
> 	Thanks. I don't feel quite comfortable with some
> of the changes (mostly XFRM, dst_confirm usage in CXGB) and
> I hope the discussion can provide adequate solution.
> 
>> Not sure why you used an unlikely() here. TCP for example would hit this
>> path quite often.
> 
> 	I was not sure, may be because ACKs can come with lower
> rate than the sent packets. Also because non-TCP rarely uses
> MSG_CONFIRM. If you still think it is better without unlikely,
> I'll remove it.
> 
>> So considering sk_dst_pending_confirm might be dirtied quite often,further 
>>
>> I am not sure why you placed it in the cache line that contains
>> sk_rx_dst (in 1st patch)
> 
> 	I saw your recent changes and was worried if the
> sk_dst_confirm() calling on RX can cause unwanted dirtying of
> additional cache line. My preliminary analyze pointed
> sk_omem_alloc as good candidate for moving to next cache
> line. I know how critical is to properly place the new flags,
> so I really need recommendations about this.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
> .
> 

Sorry for so late reply.
I have test your new patch, It works well in my scene.

Everybody,Is there any further comment about this awesome patch series?
