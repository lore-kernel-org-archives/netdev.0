From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Wed, 11 Jun 2003 12:38:33 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16103.1705.531076.869230@robur.slu.se>
References: <20030610.085600.71109220.davem@redhat.com>
	<Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
	<20030610164949.GB13246@wotan.suse.de>
	<16102.64602.19145.131439@robur.slu.se>
	<20030611100520.GB27119@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
	"David S. Miller" <davem@redhat.com>, sim@netnation.com,
	ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030611100520.GB27119@oldwotan.suse.de>
List-Id: netdev.vger.kernel.org



Andi Kleen writes:

 > eth_type_trans checks the ethernet protocol ID and sets the broadcast/multicast/
 > unicast L2 type.
 > 
 > Some NICs have bits in the RX descriptor for most of them. They have a 
 > "packet is TCP or UDP or IP" bit and also a bit for unicast or sometimes
 > even multicast/broadcast. So when you have the RX descriptor you 
 > can just derive these values from there and put them into the skb
 > without calling eth_type_trans or looking at the cache cold header.
 > 
 > Then you do a prefetch on the header. When the packet reaches the 
 > network stack later the header has already reached cache  and it can be
 > processed without a memory round trip latency.
 > 
 > Caveats: 
 > On some cards it doesn't work for all packets or can be only done 
 > if you don't have any multicast addresses hashed (that's the case
 > for the e1000 if I read the header bits correctly). The lxt1001 
 > (old EOLed card) can do it for all packet types.

 Thanks!
 
 Yes. Like to give this a try when I got chance. It should be something 
 for the driver authors. Any patch handy? e1000?


 Cheers.
						--ro
