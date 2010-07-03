From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6 1/3] ethtool: Change
 ethtool_op_set_flags to validate flags
Date: Sat, 3 Jul 2010 12:07:29 -0700
Message-ID: <20100703120729.f2a2715b.randy.dunlap@oracle.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	<20100702095514.7fb324c8.randy.dunlap@oracle.com>
	<20100702.220711.39188625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, linux-net-drivers@solarflare.com, dm@chelsio.com,
	sgruszka@redhat.com, amwang@redhat.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	anirban.chakraborty@qlogic.com, vkolluri@cisco.com,
	brice@myri.com, gallatin@myri.com, bhutchings@solarflare.com,
	scofeldm@cisco.com, shemminger@linux-foundation.org,
	jgarzik@redhat.com, buytenh@wantstofly.org, roprabhu@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100702.220711.39188625.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 02 Jul 2010 22:07:11 -0700 (PDT) David Miller wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Fri, 2 Jul 2010 09:55:14 -0700
> 
> > On Wed, 30 Jun 2010 13:44:32 +0100 Ben Hutchings wrote:
> >> @@ -457,7 +457,7 @@ int ethtool_op_set_tso(struct net_device *dev, u32 data);
> >>  u32 ethtool_op_get_ufo(struct net_device *dev);
> >>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
> >>  u32 ethtool_op_get_flags(struct net_device *dev);
> >> -int ethtool_op_set_flags(struct net_device *dev, u32 data);
> >> +int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
> > 
> > That one-line change is missing from linux-next-20100702, causing:
> > 
> > drivers/infiniband/ulp/ipoib/ipoib_ethtool.c:157: warning: initialization from incompatible pointer type
> 
> Strange, it's in net-next-2.6 for sure:
> 
> davem@sunset:~/src/GIT/net-next-2.6$ egrep ethtool_op_set_flags include/linux/ethtool.h
> int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);

Yep, my bad.

In include/linux/ethtool.h, struct ethtool_ops, field/member 'set_flags':

	int	(*set_flags)(struct net_device *, u32);

Does that need another u32 for 'supported'?  This is where the linux-next
warnings are coming from.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
