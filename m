From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 06 Nov 2002 10:44:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC96301.7070602@candelatech.com>
References: <Pine.LNX.4.44.0211061319220.13934-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> On Wed, 6 Nov 2002, Ben Greear wrote:
> 
> 
>>> I see you increased the RX-ring to 1024 pkts. 
>>> Did you really see any improvement with this?
>>
>>It helped drop fewer packets when running 4 ports at 92Mbps+
>>However, the difference between that and 512 is not large.
> 
> 
> Using 512 Rx buffers at 100Mbps seem like a pretty silly default.

I'm open to suggestions.  However, I am running 4 or 8 ports simultaneously,
on a single processor machine, so w/out large receive buffers, I drop packets
horribly.  If there is some magic number you think will be better than
others, I'll be happy to try it and report results...


> The trivial case is a module option that sets a variable replacing
> RX_RING_SIZE / TX_RING_SIZE..
> The passed-in value shouldn't be used directly:
>  - many drivers have upper and lower bounds
>  - the size can only be changed when the rings are initialized,
>    which occurs when the interface starts.

So, adjusting the ring size would require stopping and starting the
NIC?  Is that a full bounce (including auto-negotiation)?

>  - users thinking "if 32 is good, 32000 is better"

The sad truth is, most NICs/drivers do not perform at high
speeds w/out hacking them in various ways.  Where to lay the
blame (VM, shitty hardware, etc) is debatable, but it doesn't
change the results.  I do know that 1024 is better than 32 for
high speeds on muliple ports, on my NICs.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
