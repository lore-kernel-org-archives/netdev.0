From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Wed, 15 Mar 2017 11:42:11 +0100
Message-ID: <20170315104211.GA24409@salvia>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
	<20170315102608.GB24366@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170315102608.GB24366@breakpoint.cc>
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

On Wed, Mar 15, 2017 at 11:26:08AM +0100, Florian Westphal wrote:
> Linus Lüssing <linus.luessing@c0d3.blue> wrote:
> > When trying to redirect bridged frames to the bridge device itself
> > via the ebtables nat-prerouting chain and the dnat target then this
> > currently fails:
> > 
> > The ethernet destination of the frame is dnat'ed to the MAC address of
> > the bridge itself just fine and the correctly altered frame can even
> > be captured via a tcpdump on br0 (with or without promisc mode).
> >
> > However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
> > as the dnat target did not update the skb->pkt_type.
> 
> Right, thats the reason why ebtables also has ebt_redirect target
> which does this pkt_type fixup.

I'm missing then why redirect is not then just enough for Linus usecase.
