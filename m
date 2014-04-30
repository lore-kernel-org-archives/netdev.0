From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 net-next 0/7] Non-promisc bidge ports
	support
Date: Wed, 30 Apr 2014 20:37:37 +0300
Message-ID: <20140430173737.GA24794@redhat.com>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
	<20140430102241.2fa8ac7b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com,
	john.r.fastabend@intel.com, shemminger@vyatta.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140430102241.2fa8ac7b@nehalam.linuxnetplumber.net>
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

On Wed, Apr 30, 2014 at 10:22:41AM -0700, Stephen Hemminger wrote:
> On Tue, 29 Apr 2014 17:20:21 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
> > This patch series is a re-implementation of prior attempts to support
> > non-promiscuous bridge ports.
> > 
> > The basic concept is the same as before.  The bridge keeps
> > track of the ports that support learning and flooding packets
> > to unknown destinations.  We call these ports auto-discovery
> > ports since they automatically discover who is behind them through
> > learning and flooding.  
> > 
> > If flooding and learning are disabled via flags, then the port
> > requires static configuration to tell it which mac addresses
> > are behind it.  This is accomplished through adding of fdbs.
> > These fdbs should be static as dynamic fdbs can expire and systems
> > will become unreachable due to lack of flooding.
> > 
> > If the user marks all ports are needing static configuration then
> > we can safely make them non-promiscuous, we will know all the
> > information about them.
> > 
> > If the user leaves only 1 port as automatic, then we can mark
> > that port as not-promiscuous as well.  One could think of
> > this a edge relay similar to what's support by embedded switches
> > in SRIOV devices.  Since we have all the information about the
> > other ports, we can just program the mac addresses into the
> > single automatic port to receive all necessary traffic.
> > 
> > In other cases, we keep all ports promiscuous as before.
> > 
> > There are some other cases when promiscuous mode has to be turned
> > back on.  One is when the bridge itself if placed in promiscuous
> > mode (use sets promisc flag).  The other is if vlan filtering is
> > turned off.  Since this is the default configuration, the default
> > bridge operation is not changed.
> 
> I like this because it does the right thing and is transparent to
> the user. You might also not want to do it if the underlying device
> does not support multiple MAC addresses 
> ie !(dev->priv_flags & IFF_UNICAST_FLT)

The point being, attempt to add an address to a device without IFF_UNICAST_FLT
will put it right back in promisc mode?

Good point.

> 
> You could even go into looking at L2 offload on lower device.
