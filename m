From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v9 net-next 5/7] net: simple poll/select
 low latency socket poll
Date: Wed, 05 Jun 2013 08:20:06 -0700
Message-ID: <1370445606.24311.265.camel@edumazet-glaptop>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
	<20130605103452.11172.31453.stgit@ladj378.jer.intel.com>
	<1370439054.24311.248.camel@edumazet-glaptop>
	<51AF401C.2030506@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51AF401C.2030506@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-05 at 16:41 +0300, Eliezer Tamir wrote:
> On 05/06/2013 16:30, Eric Dumazet wrote:

> > I am a bit uneasy with this one, because an applicatio polling() on one
> > thousand file descriptors using select()/poll(), will call sk_poll_ll()
> > one thousand times.
> 
> But we call sk_poll_ll() with nonblock set, so it will only test once
> for each socket and not loop.
> 
> I think this is not as bad as it sounds.
> We still honor the time limit on how long to poll.

We still call ndo_ll_poll() a thousand times, and probably do a
spinlock/unlock a thousand times in the driver.

I would definitely be convinced if you give us some performance numbers
of a poll() on a thousand tcp sockets for example.

See my following mail about sk_poll_ll()


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
