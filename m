From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Re: [PATCH v9 net-next 5/7] net: simple poll/select
	low latency socket poll
Date: Wed, 5 Jun 2013 14:49:31 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7270@saturn3.aculab.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
	<20130605103452.11172.31453.stgit@ladj378.jer.intel.com>
	<1370439054.24311.248.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Eliezer Tamir" <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <1370439054.24311.248.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> I am a bit uneasy with this one, because an applicatio polling() on one
> thousand file descriptors using select()/poll(), will call sk_poll_ll()
> one thousand times.

Anything calling poll() on 1000 fds probably has performance
issues already! Which is why kevent schemes have been added.

At least the Linux code doesn't use a linked list for
the fd -> 'struct file' map which made poll() O(n^2),
and getting to that number of open fds O(n^3) on
some versions of SVR4.

	David

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
