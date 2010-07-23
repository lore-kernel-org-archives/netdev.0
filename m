From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip6tables: use skb->len for accounting
Date: Fri, 23 Jul 2010 13:48:02 +0200
Message-ID: <4C498172.40404@trash.net>
References: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com> 	<alpine.LSU.2.01.1007230813300.815@obet.zrqbmnf.qr> <AANLkTik_2HMl3OaGvZiJPCO09Bu4lj6S0PNWFbw1BGXe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik_2HMl3OaGvZiJPCO09Bu4lj6S0PNWFbw1BGXe@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 08:38, Changli Gao wrote:
> On Fri, Jul 23, 2010 at 2:16 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>>
>> I wonder how this fares with trailing padding or data, like, when
>> you have a standard v4/v6 packet created in a raw socket, and append
>> a bunch of \0s to it.
>>
>>
> 
> For the packets received, ip_rcv, ipv6_rcv and bridge all call
> pskb_trim_rcsum before feeding them to netfilter. The raw packets are
> sent via dev_queue_xmit(), and they don't pass through the output path
> of netfilter.

That's not true, raw packets also pass through netfilter. However
I agree that this patch makes sense to properly deal with jumbo
frames, but you should also update xt_length for consistency.
