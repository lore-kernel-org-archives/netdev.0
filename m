From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to
	entering networked mode
Date: Tue, 23 Feb 2010 08:21:25 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA29430705EF62@ala-mail09.corp.ad.wrs.com>
	<20100223011116.GA2021@localhost.localdomain>
	<29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
	<20100223160936.GA16435@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20100223160936.GA16435@hmsreliant.think-freely.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Neil wrote: 

> I agree that you patch fixes the exact problem that I 
> reported here, but theres more to it than that.  A quick grep 
> of the tipc stack reveals the following
> symbols:
> tipc_bearers
> media_list
> tipc_local_nodes
> bcbearer
> bclink
> tipc_net.zones
> 
> All of these symbols:
> 
> 1) Are allocated dynamically in tipc_net_start, _after_ 
> tipc_mode is set to TIPC_NET_MODE
> 
> 2) dereferenced without NULL pointer checks in either the 
> send path or in the netlink configuration path, both of which 
> are reachable from user space.
> 
> So your patch fixes the last item on your list, but what 
> about the others?  In fact, I'll bet I can very quickly 
> change the application to trip over a null tipc_local_nodes 
> dereference by changing the destination address to be 
> something within zone 0, cluster 0.

The semantics of TIPC addressing don't allow a node address of the form
<0.0.N> where N != 0, so this kind of a send ateempt should be caught
and handled by TIPC.  However, you've already found one missing error
check, so it's certainly worth trying it out!

Regards,
Al

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
