From: Simon Horman <horms@verge.net.au>
Subject: igb bandwidth allocation configuration
Date: Thu, 10 Sep 2009 18:18:45 +1000
Message-ID: <20090910081844.GA5421@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

I have been looking into adding support the 82586's per-PF/VF
bandwidth allocation to the igb driver. It seems that the trickiest
part is working out how to expose things to user-space.

I was thinking along the lines of an ethtool option as follows:

	ethtool --bandwidth ethN LIMIT...

	where:
		* There is one LIMIT per PF/VF.
		  The 82576 can have up to 7 VFs per PF,
		  so there would be up to 8 LIMITS
		* A keyword (none?) can be used to denote that
		  bandwidth allocation should be disabled for the
		  corresponding VM
		* Otherwise LIMITS are in Megabits/s

This may get a bit combersome if there are a lot of VFs per PF,
perhaps a better syntax would be:

	ethtool --bandwidth ethN M=LIMIT...

	where:
		* LIMIT is as above
		* M is some key to denote which VF/PF is
		  having its limit set.

Internally it seems that actually the limits are applied to HW Tx queues
rather than directly VMs. There are 16 such queues. Accordingly it might
be useful to design an interface to set limits per-queue using ethtool.
But this would seem to also require exposing which queues are associated
with which PF/VF.


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
