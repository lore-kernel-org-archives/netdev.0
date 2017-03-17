From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Fri, 17 Mar 2017 14:10:44 +0100
Message-ID: <20170317131044.GA11995@salvia>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
	<20170315102608.GB24366@breakpoint.cc>
	<20170315104211.GA24409@salvia> <20170315142720.GU15692@otheros>
	<20170315181539.GA31875@salvia> <20170315211619.GA3464@otheros>
	<20170315220605.GA1766@salvia>
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
In-Reply-To: <20170315220605.GA1766@salvia>
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

On Wed, Mar 15, 2017 at 11:06:05PM +0100, Pablo Neira Ayuso wrote:
> On Wed, Mar 15, 2017 at 10:16:19PM +0100, Linus Lüssing wrote:
> > On Wed, Mar 15, 2017 at 07:15:39PM +0100, Pablo Neira Ayuso wrote:
> > > Could you update ebtables dnat to check if the ethernet address
> > > matches the one of the input bridge interface, so we mangle the
> > > ->pkt_type accordingly from there, instead of doing this from the
> > > core?
> > 
> > Actually, that was the approach I thought about and went for first
> > (and it would probably work for me). Just checking against the
> > bridge device's net_device::dev_addr.
> > 
> > I scratched it though, as I was afraid that the issue might still
> > exist for people using some other upper device on top of the bridge
> > device. For instance, macvlan? And iterating over the
> > net_device::dev_addrs list seemed too costly for fast path to me.
> 
> I was more thinking of following the simple approach that we follow in
> ebt_redirect_tg() by taking the input interface.
> 
> Anyway, I'm ok with this.

Wait.

May this break local multicast listener that are bound to the bridge
interface? Assuming the bridge interface got an IP address, and that
there is local multicast listener.

Missing anything here?
