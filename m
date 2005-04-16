From: Andre Tomt <andre@tomt.net>
Subject: Re: FIB alternative fib_hash2.c
Date: Sat, 16 Apr 2005 10:55:07 +0200
Message-ID: <4260D2EB.6070400@tomt.net>
References: <16991.54602.218744.163816@robur.slu.se>	<425FFA54.9070106@tomt.net> <16992.48513.102876.620927@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16992.48513.102876.620927@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Andre Tomt writes:
> 
>  > Drool. Got some numbers? pps - flows - memory use, on what hardware, 
>  > that sort of thing.
> 
>  For testing reasons I use pure rDoS with 1 dst per packet. Routing table 
>  is taken from bgp route some year ago w 123 kroutes.
> 
>  Also to test just FIB lookup I use the preroute paches to bypass dst
>  hash this only works with gatewayed routes  which is fine for me.
> 
>  Some numbers from a 1.6 GHz Opteron. rDoS at 720 kpps injected in eth0.
>  result is what get out on eth1, eth3.
> 
> 
> Current FIB 
> -----------
> Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
> eth0   1500   0 2346827 9125541 9125541 7653595    262      0      0      0 BRU
> eth1   1500   0      4      0      0      0 2325770      0      0      0 BRU
> eth2   1500   0      0      0      0      0      5      0      0      0 BRU
> eth3   1500   0      1      0      0      0  20652      0      0      0 BRU
> eth4   1500   0      0      0      0      0      5      0      0      0 BRU
> 
> 
> New hash2
> ----------
> eth0   1500   0 4389455 8372826 8372826 5610843    199      0      0      0 BRU
> eth1   1500   0      2      0      0      0 4349633      0      0      0 BRU
> eth2   1500   0      0      0      0      0      5      0      0      0 BRU
> eth3   1500   0      1      0      0      0  38875      0      0      0 BRU
> eth4   1500   0      0      0      0      0      5      0      0      0 BRU
> 
> 
> 168 kpps vs 316 kpps on this box so quite substantial improvement and if 
> you can merge local and main table you get even more. Well to honest we 
> can merge tables do this current FIB too.

Nice. What kind of equipment and/or software do you use to generate this 
sort of traffic pattern? And how much is one expected to gain by merging 
local and main tables? I try to avoid policy routing wherever possible - 
so merging is very interesting indeed.

> Mem usage 
> 
> IP: FIB vers 0.58 routing table of 16777216 buckets, 65536Kbytes for table id=255
> 
> So ~66 MB for hash structure to that comes routing info this can too a lot
> as hash2 makes  /24 prefix-clones of prefixes in range 0>plen>24, I see
> 294 MB for the full BGP table.

I reckon this would be limited to available lowmem on 32bit (ick) systems?

> I have some single flow numbers if you are interested too.

If its not too much trouble I would apriciate it.
