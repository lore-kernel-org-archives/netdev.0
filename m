From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 22:14:35 +0000
Message-ID: <42278C4B.2030701@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<42278122.6000000@ev-en.org>	<20050303133659.0d224e61.davem@davemloft.net>	<42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303135718.2e1a0170.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 03 Mar 2005 21:44:52 +0000
> Baruch Even <baruch@ev-en.org> wrote:
> 
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

Stephen has a patch to move some of the extra congestion control data to 
their own struct, that would free some space for me :-)

I'll need to take a look at this again, the original patch actually 
increased the number of bytes for the cb from 40 to get some extra space.

Baruch
