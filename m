From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: FIB alternative fib_hash2.c
Date: Mon, 18 Apr 2005 18:06:23 +0200
Message-ID: <16995.56063.402097.475330@robur.slu.se>
References: <16991.54602.218744.163816@robur.slu.se>
	<425FFA54.9070106@tomt.net>
	<16992.48513.102876.620927@robur.slu.se>
	<4260D2EB.6070400@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Tomt <andre@tomt.net>
In-Reply-To: <4260D2EB.6070400@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andre Tomt writes:
 > > 168 kpps vs 316 kpps on this box so quite substantial improvement and if 
 > > you can merge local and main table you get even more. Well to honest we 
 > > can merge tables do this current FIB too.

 > If its not too much trouble I would apriciate it.

Well we get into FIB details we have to be careful with numbers as looking
up different prefixes is quite different. I.e if the matching route is 
/32 we find in the first zone compare to if we have to search through all 
zones to match /0 at last. HASH2 has other worst cases.

So the rDoS numbers may be more useful... Anyway to bomb you with numbers

FIB/24 313 kpps
FIB/0  264 kpps

HASH2/24 305 kpps
HASH2/0  296 kpps

local and main are not merged.


FIB 123 kroutes Single flow at 880 kpps we match /24 prefix --- T-put 313 kpps

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3564282 8405409 8405409 6435718      5      0      0      0 BRU
eth1   1500   0      6      0      0      0 3564294      0      0      0 BRU

FIB 123 kroutes single flow at 880 kpps we match /0 prefix --- T-put 264 kpps

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 2676826 8789144 8789144 7323321     95      0      0      0 BRU
eth1   1500   0      4      0      0      0 2676688      0      0      0 BRU

--------------------------------------------------------------------------------

HASH2 123kroutes single flow at 880 kpps we match /24 prefix  --- T-put 305 kpps

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3470186 8453021 8453021 6529814      5      0      0      0 BRU
eth1   1500   0      4      0      0      0 3470195      0      0      0 BRU


HASH2 123kroutes single flow at 880 kpps we match /0 prefix  --- T-put 296 kpps

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3373610 8479473 8479473 6626522     96      0      0      0 BRU
eth1   1500   0      4      0      0      0 3373487      0      0      0 BRU

Cheers.

						 --ro
