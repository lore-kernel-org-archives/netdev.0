From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Wed, 11 Jun 2003 08:08:00 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611075703.R39786@shell.cyberus.ca>
References: <20030610.085600.71109220.davem@redhat.com>
 <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
 <20030610164949.GB13246@wotan.suse.de> <16102.64602.19145.131439@robur.slu.se>
 <20030611100520.GB27119@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
	"David S. Miller" <davem@redhat.com>, sim@netnation.com,
	ralph+d@istop.com, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030611100520.GB27119@oldwotan.suse.de>
List-Id: netdev.vger.kernel.org



On Wed, 11 Jun 2003, Andi Kleen wrote:

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

I have done prefetching experiments with a NAPIezed sb1250.c driver on
MIPS. I never got rid of eth_type_trans() just prefetched skb->data
a few lines before calling it. I did see eth_type_trans() almost
disappear from the profile (it was way low to be important).
Andis idea is even more interesting.

I did see i think about 10Kpps more in throughput.
Robert, this means our biggest bottleneck right now is cache misses.
The MIPS processor i am playing with is SMP and has a large shared L2
cache. What i am observing is that this is quiet useful for SMP.
I am limited by how much traffic i can generate right now to test it
more. I can do 295Kpps L3 easy.  This board is an excuse for you to
come down to Ottawa in July ;->


> Caveats:
> On some cards it doesn't work for all packets or can be only done
> if you don't have any multicast addresses hashed (that's the case
> for the e1000 if I read the header bits correctly). The lxt1001
> (old EOLed card) can do it for all packet types.
>

So can the sb1250. I'll try this out.

> Often prefetch size is limited so you should not prefetch more
> than what you can store until the packet reaches the stack.
>

Good point. So is there a systematic way to find out the effects
of the prefecth size or you just have to keep trying until you get
it right?

cheers,
jamal
