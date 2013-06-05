From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency
	socket poll
Date: Wed, 05 Jun 2013 08:39:20 -0700
Message-ID: <1370446760.24311.275.camel@edumazet-glaptop>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
	<20130605103421.11172.82925.stgit@ladj378.jer.intel.com>
	<1370445714.24311.268.camel@edumazet-glaptop>
	<51AF59B0.6080101@linux.intel.com>
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
In-Reply-To: <51AF59B0.6080101@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-05 at 18:30 +0300, Eliezer Tamir wrote:
> On 05/06/2013 18:21, Eric Dumazet wrote:
> > On Wed, 2013-06-05 at 13:34 +0300, Eliezer Tamir wrote:
> >
> >
> > This is probably too big to be inlined, and nonblock should be a bool
> 
> 
> > It would also make sense to give end_time as a parameter, so that the
> > polling() code could really give  a end_time for the whole duration of
> > poll().
> >
> > (You then should test can_poll_ll(end_time) _before_ call to
> > ndo_ll_poll())
> 
> how would you handle a nonblocking operation in that case?
> I guess if we have a socket option, then we don't need to handle none 
> blocking any diffrent, since the user specified exactly how much time to 
> waste polling. right?

If the thread already spent 50us in the poll() system call, it for sure
should not call any ndo_ll_poll(). This makes no more sense at this
point.




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
