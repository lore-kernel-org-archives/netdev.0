From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
	device specific ndisc information
Date: Mon, 28 Jan 2013 00:26:33 +0100
Message-ID: <20130128002633.0eac1d6c@stein>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org>
	<50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org>
	<50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein>
	<50FD962B.8020500@gmail.com> <50FD9DB7.60802@linux-ipv6.org>
	<50FDB039.2070604@gmail.com> <20130127154332.6b5730f9@stein>
	<5105621F.4040408@gmail.com> <51057FEF.9090006@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51057FEF.9090006@linux-ipv6.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jan 28 YOSHIFUJI Hideaki wrote:
> Stephan Gatzka wrote:
> 
> >> I am not a contributor to net/, hence don't have a say over how the
> >> networking APIs should evolve.
> >>
> >> Any solution is fine with me, as long as net/ does not use any definitions
> >> or declarations from <linux/firewire.h>.
> > 
> > O.k. then I will go for Yoshifujis "extended hwaddress" approch.
> > 
> > I think I will divide all the stuff into two major pieces:
> > 
> > First I will rewrite the existing IPv4 over Firewire driver to use the notification mechanisms and also generate the RFC2734 ARP packets in the arp code.
> > 
> > Then I'll implement the IPv6 stuff based on that IPv4 solution.
> 
> I even think that we do not need to have event notification if we
> can just use max_rec, sspd and fifo embedded in the destination
> "MAC address" in the sending packet.

Yes and no.  After a bus topology change, it takes a brief period for
firewire-core to have the new node(s) scanned and tell firewire-net about
them, so that firewire-net can add (or remove) items in the list for the
mapping between GUID on one hand and card:generation:nodeID on the other
hand.

So, right after a bus reset, we may already receive IP packets from nodes
which firewire-core didn't process yet.  But I guess this short period
isn't really a problem.

By the way, I wouldn't trust max_rec and sspd from 1394-ARP or 1394-NDP
packets.  These should rather be taken from firewire-core's bus analysis
as soon as this is complete.  Only unicast_FIFO can alas not be obtained
by bus analysis.  (IEEE 1394 addendum B:2002 made things more complicated
with regard to maximum payload and maximum transmission speed then they
were until addendum A:2000, in ways that the authors of RFC 2374 and 3146
surely could not anticipate.)
-- 
Stefan Richter
-=====-===-= ---= ===--
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. ON SALE this month only -- learn more at:
http://p.sf.net/sfu/learnnow-d2d
