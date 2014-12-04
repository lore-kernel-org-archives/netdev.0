From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbe,
 ixgbevf: Add new mbox API to enable MC promiscuous mode
Date: Thu, 04 Dec 2014 09:43:51 -0800
Message-ID: <54809D57.9060804@gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05DBFDAD@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>, Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05DBFDAD@BPXM14GP.gisp.nec.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11/27/2014 02:39 AM, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> The limitation of the number of multicast address for VF is not enough
> for the large scale server with SR-IOV feature.
> IPv6 requires the multicast MAC address for each IP address to handle
> the Neighbor Solicitation message.
> We couldn't assign over 30 IPv6 addresses to a single VF interface.
>
> The easy way to solve this is enabling multicast promiscuous mode.
> It is good to have a functionality to enable multicast promiscuous mode
> for each VF from VF driver.
>
> This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> enable/disable multicast promiscuous mode in VF. If multicast promiscuous
> mode is enabled the VF can receive all multicast packets.
>
> With this patch, the ixgbevf driver automatically enable multicast
> promiscuous mode when the number of multicast addresses is over than 30
> if possible.
>
> This also bump the API version up to 1.2 to check whether the API,
> IXGBE_VF_SET_MC_PROMISC is available.
>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>

This is a REALLY bad idea unless you plan to limit this to privileged VFs.

I would recommend looking at adding an ndo operation to control this
feature so that it could be disabled by default in the PF and only
enabled on the host side if specifically requested.  Otherwise the
problem is I can easily see this leading security issues as the VFs
might begin getting access to messages that they aren't supposed to.

- Alex

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
