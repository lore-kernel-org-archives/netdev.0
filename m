From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 17:04:00 +0200
Message-ID: <1349449440.21172.118.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349441509.28867.17.camel@sakura.staff.proxad.net>
	 <1349442173.21172.66.camel@edumazet-glaptop>
	 <1349448659.28867.27.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349448659.28867.27.camel@sakura.staff.proxad.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 16:50 +0200, Maxime Bizon wrote:
> On Fri, 2012-10-05 at 15:02 +0200, Eric Dumazet wrote:
> 
> > On Fri, 2012-10-05 at 14:51 +0200, Maxime Bizon wrote:
> > 
> > > > New convention would be : pass number of needed bytes after current
> > > > tail, not after current end.
> > > 
> > > Fully agree on this
> > > 
> > 
> > Here is the proposal :
> 
> Looks fine
> 
> What is your plan for the actual pskb_expand_head() code now that you
> will have absolute values for headroom & tailroom ?
> 

They stay relative values.

For example, netlink_trim() really wants to shrink the skb head.


> Because there will still be callers that have no clue of required
> tailroom (nor further headroom requirement), like skb_cow() in
> vlan_reorder_header().
> 

What I plan is to not shrink size, unless specifically asked.

Its 3.8 material anyway, so a stable fix is needed on skb_recycle() and
NET_SKB_PAD minimal value.
