From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] openvswitch: make for_each_node loops work with sparse
 numa systems
Date: Tue, 21 Jul 2015 15:04:30 -0700
Message-ID: <20150721220430.GC29402@linux.vnet.ibm.com>
References: <1437492756-22777-1-git-send-email-chris.j.arges@canonical.com>
 <20150721162418.GM38815@linux.vnet.ibm.com>
 <20150721163058.GA8589@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, linux-numa@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <linux-numa-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150721163058.GA8589@canonical.com>
Sender: linux-numa-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.07.2015 [11:30:58 -0500], Chris J Arges wrote:
> On Tue, Jul 21, 2015 at 09:24:18AM -0700, Nishanth Aravamudan wrote:
> > On 21.07.2015 [10:32:34 -0500], Chris J Arges wrote:
> > > Some architectures like POWER can have a NUMA node_possible_map that
> > > contains sparse entries. This causes memory corruption with openvswitch
> > > since it allocates flow_cache with a multiple of num_possible_nodes() and
> > 
> > Couldn't this also be fixed by just allocationg with a multiple of
> > nr_node_ids (which seems to have been the original intent all along)?
> > You could then make your stats array be sparse or not.
> > 
> 
> Yea originally this is what I did, but I thought it would be wasting memory.
> 
> > > assumes the node variable returned by for_each_node will index into
> > > flow->stats[node].
> > > 
> > > For example, if node_possible_map is 0x30003, this patch will map node to
> > > node_cnt as follows:
> > >     0,1,16,17 => 0,1,2,3
> > > 
> > > The crash was noticed after 3af229f2 was applied as it changed the
> > > node_possible_map to match node_online_map on boot.
> > > Fixes: 3af229f2071f5b5cb31664be6109561fbe19c861
> > 
> > My concern with this version of the fix is that you're relying on,
> > implicitly, the order of for_each_node's iteration corresponding to the
> > entries in stats 1:1. But what about node hotplug? It seems better to
> > have the enumeration of the stats array match the topology accurately,
> > rather, or to maintain some sort of internal map in the OVS code between
> > the NUMA node and the entry in the stats array?
> > 
> > I'm willing to be convinced otherwise, though :)
> > 
> > -Nish
> >
> 
> Nish,
> 
> The method I described should work for hotplug since it's using possible map
> which AFAIK is static rather than the online map. 

Oh you're right, I'm sorry!
