From: David Miller <davem@davemloft.net>
Subject: Re: bridge: fix use-after-free in br_cleanup_bridges()
Date: Thu, 03 Jul 2008 03:54:08 -0700 (PDT)
Message-ID: <20080703.035408.214725711.davem@davemloft.net>
References: <486B7CCE.2@trash.net>
	<20080702094817.646c6c60@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20080702094817.646c6c60@extreme>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Jul 2008 09:48:17 -0700

> On Wed, 02 Jul 2008 15:04:14 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > commit 96f1dd78dad10d61bdd487edadea6adda5425e4c
> > Author: Patrick McHardy <kaber@trash.net>
> > Date:   Wed Jul 2 15:02:23 2008 +0200
> > 
> >     bridge: fix use-after-free in br_cleanup_bridges()
> > 
> >     Unregistering a bridge device may cause virtual devices stacked on the
> >     bridge, like vlan or macvlan devices, to be unregistered as well.
> >     br_cleanup_bridges() uses for_each_netdev_safe() to iterate over all
> >     devices during cleanup. This is not enough however, if one of the
> >     additionally unregistered devices is next in the list to the bridge
> >     device, it will get freed as well and the iteration continues on
> >     the freed element.
> > 
> >     Restart iteration after each bridge device removal from the beginning to
> >     fix this, similar to what rtnl_link_unregister() does.
> > 
> >     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks everyone.
