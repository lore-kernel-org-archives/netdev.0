From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ip6tables: use skb->len for accounting
Date: Fri, 23 Jul 2010 21:05:31 +0800
Message-ID: <AANLkTi=PAVfcX4ttUsSgm+A_WMYcfXt4FLvYunccgtjS@mail.gmail.com>
References: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LSU.2.01.1007230813300.815@obet.zrqbmnf.qr> <AANLkTik_2HMl3OaGvZiJPCO09Bu4lj6S0PNWFbw1BGXe@mail.gmail.com>
	<4C498172.40404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C498172.40404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 7:48 PM, Patrick McHardy <kaber@trash.net> wrote:
> On 23.07.2010 08:38, Changli Gao wrote:
>>
>> For the packets received, ip_rcv, ipv6_rcv and bridge all call
>> pskb_trim_rcsum before feeding them to netfilter. The raw packets are
>> sent via dev_queue_xmit(), and they don't pass through the output path
>> of netfilter.
>
> That's not true, raw packets also pass through netfilter. However
> I agree that this patch makes sense to properly deal with jumbo
> frames, but you should also update xt_length for consistency.
>

In order to support jumbo frames, we have to change the type of min
and max in xt_length_info to u32. I'll change xt_match.revision to 1,
do I need to support the current revision 0 at the same time?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
