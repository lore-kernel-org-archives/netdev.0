From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 31 Mar 2005 17:33:41 +0100
Message-ID: <424C2665.9040404@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<42278122.6000000@ev-en.org>	<20050303133659.0d224e61.davem@davemloft.net>	<42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jheffner@psc.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
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
> 
> I'm sure you can find a way to steal sizeof(void *) from
> "struct tcp_skb_cb" :-)
> 
> It is currently 36 bytes on both 32-bit and 64-bit platforms.
> This means if you can squeeze out 4 bytes (so that it fits
> in the skb->cb[] 40 byte area), you can fit a pointer in there
> for the linked list stuff.

I changed the code to use only the next pointer and dropped the prev. 
The cb still fits into 40 bytes for 32bit but for an em64t compile with 
gcc version 3.4.4 20041218 (prerelease) (Debian 3.4.3-6) the cb now 
requires 48 bytes. I haven't looked at the code emitted by I suspect 
it's an alignment that forced the pointer to start at 40 and then the 
size is 8 bytes.

 From a quick test I did there was no performance hit and the numbers 
very very similar to those in the 32bit case. The machine is exactly the 
  same (it's a 3Ghz xeon which I so-far only run as 32 bit, not 
suspecting I had a 64 bit test machine).

Baruch

p.s. Thanks to whomever put the compile time test of this, it probably 
saved me quite a lot of time of hunting weird crashes.
