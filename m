From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 3/5] ixgbe: Add support for ndo_ll_poll
Date: Tue, 05 Mar 2013 09:36:52 -0800
Message-ID: <1362505012.15793.128.camel@edumazet-glaptop>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227175606.10611.55498.stgit@gitlad.jf.intel.com>
	<1362504410.2791.44.camel@bwh-desktop.uk.solarflarecom.com>
	<1362504520.2791.46.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	Willem de Bruijn <willemb@google.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	HPA <hpa@zytor.com>, Eliezer Tamir <eliezer@tamir.org.il>,
	Dave Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1362504520.2791.46.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-05 at 17:28 +0000, Ben Hutchings wrote:
> On Tue, 2013-03-05 at 17:26 +0000, Ben Hutchings wrote:
> > On Wed, 2013-02-27 at 09:56 -0800, Eliezer Tamir wrote:
> > > Add the ixgbe driver code implementing ndo_ll_poll.
> > > It should be easy for other drivers to do something similar
> > > in order to enable support for CONFIG_INET_LL_RX_POLL
> > 
> > Yes... in fact I wonder whether the lock and state couldn't be added to
> > napi_struct instead of being driver-specific.
> [...]
> 
> That would potentially allow GRO to detect that it's being called in
> low-latency context...

Not sure we have to add another test in fast path.

Users wanting polling support should disable GRO (ethtool -K eth0 gro
off)

Doing this dynamically would be nice of course.




------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
