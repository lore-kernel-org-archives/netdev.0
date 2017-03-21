From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Tue, 21 Mar 2017 11:11:21 +0100
Message-ID: <20170321101121.GB1719@salvia>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
	<20170315102608.GB24366@breakpoint.cc>
	<20170315104211.GA24409@salvia> <20170315142720.GU15692@otheros>
	<20170315181539.GA31875@salvia> <20170315211619.GA3464@otheros>
	<20170315220605.GA1766@salvia> <20170317131044.GA11995@salvia>
	<20170319165506.GA15475@otheros> <20170321000947.GA31709@otheros>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170321000947.GA31709@otheros>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 01:09:47AM +0100, Linus Lüssing wrote:
> On Sun, Mar 19, 2017 at 05:55:06PM +0100, Linus Lüssing wrote:
> > On Fri, Mar 17, 2017 at 02:10:44PM +0100, Pablo Neira Ayuso wrote:
> > > Wait.
> > > 
> > > May this break local multicast listener that are bound to the bridge
> > > interface? Assuming the bridge interface got an IP address, and that
> > > there is local multicast listener.
> > > 
> > > Missing anything here?
> > 
> > Hm, for multicast packets usually the code path a few lines
> > later in br_handle_frame_finish() should be taken instead.
> > 
> > But you might be right for IP multicast packets with a unicast MAC
> > destination (due to whatever reason, for instance via DNAT'ing
> > again).
> > 
> > Will check that - thanks!
> 
> Ok, I tested DNAT'ing an IP multicast packet to the unicast MAC address
> of the bridge interface.
> 
> Both ping-ing to an IPv4 and IPv6 multicast listener on br0 worked
> and was replied to fine, both with or without changing skb->pkt_type
> from PACKET_MULTICAST to PACKET_HOST.
> ("$ ping 224.1.0.123" and "$ ping6 ff02::1:ff40:707c%in0" from a
>  network namespace, tied into the bridge via veth)
> 
> Also, a DNAT'ed PACKET_BROADCAST worked, with or without changing
> it to PACKET_HOST.
> 
> I also checked via tcpdump that the destination MAC was changed
> successfully.

Thanks for looking into this more in depth.

> So, so far I wasn't able to find any bugs with the current
> patch. But I think I like the idea of leaving the skb->pkt_type
> unaltered for PACKET_MULTICAST and PACKET_BROADCAST, seems cleaner.

Yes, and matching on skb->pkt_type would not break from netfilter.

> I'd just add an "if (skb->pkt_type == PACKET_OTHERHOST)" check
> then and resend a PATCH v2.

Thanks.
