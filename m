From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Thu, 12 Jan 2017 19:33:51 +0300
Message-ID: <dc41bc36-8239-39d7-def1-a60603e3890a@cogentembedded.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <3e1d4324-4288-8d65-56fd-8c3e7283020b@cogentembedded.com>
 <20170112131821.GA16060@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170112131821.GA16060@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2017 04:18 PM, Simon Horman wrote:

> ...
>
>>>>   Here, it stop once an untransmitted buffer is encountered...
>>>
>>> Yes, I see that now.
>>>
>>> I wonder if we should:
>>>
>>> a) paramatise ravb_tx_free() so it may either clear all transmitted buffers
>>>   (current behaviour) or all buffers (new behaviour).
>>> b) provide a different version of this loop in ravb_ring_free()
>>>
>>> What are your thoughts?
>>
>>    I'm voting for (b).
>
> Ok, something like this?
>
> @@ -215,6 +225,30 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	}
>
>  	if (priv->tx_ring[q]) {
> +		for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {

    You're still copying the loop logic from ravb_tx_free() while we (I think) 
need a simple loop over all the descriptor ring.

[...]

MBR, Sergei
