From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Fri, 31 Dec 2004 01:33:15 +0100
Message-ID: <41D49E4B.2020007@trash.net>
References: <1104432914.15601.19.camel@localhost.localdomain>	 <20041230222415.GB19587@xi.wantstofly.org> <1104448248.15601.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        snort2004@mail.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <1104448248.15601.55.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer wrote:
> Hi Lennert,
> 
> skb->protocol is not set for locally generated packets when the packet
> is still in the IP stack. I don't know what happens with it after the IP
> stack is finished with the packet.

It is set shortly before the packet leaves the IP stack,
in ip_finish_output. This is after LOCAL_OUT, but before
POST_ROUTING. So your fix looks fine.

> The comment in skbuff.h says "packet protocol from driver", from which I
> tend to conclude that skb->protocol is only set by drivers when a packet
> enters the box. Too bad stuff like this isn't clearly spelled out, the
> FIXME for the dst field has been sitting there for probably more than a
> year too. Anyway, it wouldn't hurt if the skb->protocol field always
> held the right value.

The IP stack knows it's IP anyway :) After that it has to
hold the right value.

Regards
Patrick
