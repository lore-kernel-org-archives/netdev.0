From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip6tables: use skb->len for accounting
Date: Fri, 23 Jul 2010 16:21:11 +0200
Message-ID: <4C49A557.1080502@trash.net>
References: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com> 	<alpine.LSU.2.01.1007230813300.815@obet.zrqbmnf.qr> <AANLkTik_2HMl3OaGvZiJPCO09Bu4lj6S0PNWFbw1BGXe@mail.gmail.com> 	<4C498172.40404@trash.net> <AANLkTi=PAVfcX4ttUsSgm+A_WMYcfXt4FLvYunccgtjS@mail.gmail.com>
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
In-Reply-To: <AANLkTi=PAVfcX4ttUsSgm+A_WMYcfXt4FLvYunccgtjS@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 15:05, Changli Gao wrote:
> On Fri, Jul 23, 2010 at 7:48 PM, Patrick McHardy <kaber@trash.net> wrote:
>> On 23.07.2010 08:38, Changli Gao wrote:
>>>
>>> For the packets received, ip_rcv, ipv6_rcv and bridge all call
>>> pskb_trim_rcsum before feeding them to netfilter. The raw packets are
>>> sent via dev_queue_xmit(), and they don't pass through the output path
>>> of netfilter.
>>
>> That's not true, raw packets also pass through netfilter. However
>> I agree that this patch makes sense to properly deal with jumbo
>> frames, but you should also update xt_length for consistency.
>>
> 
> In order to support jumbo frames, we have to change the type of min
> and max in xt_length_info to u32.

I see. In that case I'll apply your skb->len patches as they are,
so please make the xt_length change in a new patch.

> I'll change xt_match.revision to 1,
> do I need to support the current revision 0 at the same time?

You should simply keep the revision 0 code as it is. Revision 1,
using skb->len, can be used for both IPv4 and IPv6.
