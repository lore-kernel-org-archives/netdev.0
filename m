From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Tue, 08 Mar 2005 15:42:06 +0000
Message-ID: <422DC7CE.2040800@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<42278122.6000000@ev-en.org>	<20050303133659.0d224e61.davem@davemloft.net>	<42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303135718.2e1a0170.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 03 Mar 2005 21:44:52 +0000
> Baruch Even <baruch@ev-en.org> wrote:
> 
>>The current linked list goes over all the packets, the linked list we 
>>add is for the packets that were not SACKed. The idea being that it is a 
>>lot faster since there are a lot less packets not SACKed compared to 
>>packets already SACKed (or never mentioned in SACKs).
>>
>>If you have a way around this I'd be happy to hear it.
> 
> I'm sure you can find a way to steal sizeof(void *) from
> "struct tcp_skb_cb" :-)
> 
> It is currently 36 bytes on both 32-bit and 64-bit platforms.
> This means if you can squeeze out 4 bytes (so that it fits
> in the skb->cb[] 40 byte area), you can fit a pointer in there
> for the linked list stuff.

The current code adds 2 pointers to tcp_skb_cb and 20 bytes tcp_sock.

I can squeeze the tcp_skb_cb to one pointer at the expense of extra work 
to remove a packet from the list (the other pointer is the prev pointer).

I'm trying to do two tasks at the same time, port to 2.6.11 and rerun 
all the tests to produce a chapter in my thesis (on the ported 2.6.11 
patches). Hopefully it will work out, otherwise the porting will be delayed.

Baruch
