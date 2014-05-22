From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 20:39:27 +0100
Message-ID: <537E526F.8060608@mentor.com>
References: <537E4AFD.20304@mentor.com> <537E4F29.9080103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <kamal@canonical.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	<edumazet@google.com>, <mszeredi@suse.cz>, <fw@strlen.de>
To: Vlad Yasevich <vyasevich@gmail.com>, <linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E4F29.9080103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/05/14 20:25, Vlad Yasevich wrote:
> On 05/22/2014 03:07 PM, Jim Baxter wrote:
>>
>>     skb2 = skb_clone(skb, GFP_ATOMIC);
>>     if (skb2 == NULL)
>>         goto err;
>>
>>     if (!skb_pull(skb2, index)) {
>>         ret = -EOVERFLOW;
>>         goto err;
>>     }
> 
> This assumes that you original 16K packet is linear.  Is that
> always the case?
The packets within the original packet are linear, however they could be
in an arbitrary order because they are just offsets from the start of
the 16k skb.


> 
> This is the very same problem that I ran into with SCTP since it
> has similar code in it.  You can play games with truesize manually,
> but you have to be very careful here.
> 
> -vlad

I now think that the correct solution here is to create a new smaller
skb and copy the data from the sub packets into it.

Jim
