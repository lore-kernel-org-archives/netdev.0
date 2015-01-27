From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add tipc
	support
Date: Tue, 27 Jan 2015 13:08:52 +0100
Message-ID: <20150127120852.GB11522@haze>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
	<1421943032-29924-2-git-send-email-erik.hugne@ericsson.com>
	<1421947751.3471.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150126.165749.913857343835846078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20150126.165749.913857343835846078.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2015 at 04:57:49PM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 Jan 2015 09:29:11 -0800
> 
> > On Thu, 2015-01-22 at 17:10 +0100, erik.hugne@ericsson.com wrote:
> >> From: Erik Hugne <erik.hugne@ericsson.com>
> >> 
> >> The flows are hashed on the sending node address, which allows us
> >> to spread out the TIPC link processing to RPS enabled cores. There
> >> is no point to include the destination address in the hash as that
> >> will always be the same for all inbound links. We have experimented
> >> with a 3-tuple hash over [srcnode, sport, dport], but this showed to
> >> give slightly lower performance because of increased lock contention
> >> when the same link was handled by multiple cores.
> >> 
> >> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> >> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> >> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> >> ---
> >>  net/core/flow_dissector.c | 14 ++++++++++++++
> >>  1 file changed, 14 insertions(+)
> >> 
> >> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> >> index 4508493..beb83d1 100644
> >> --- a/net/core/flow_dissector.c
> >> +++ b/net/core/flow_dissector.c
> >> @@ -178,6 +178,20 @@ ipv6:
> >>  			return false;
> >>  		}
> >>  	}
> >> +	case htons(ETH_P_TIPC): {
> >> +		struct {
> >> +			__be32 pre[3];
> >> +			__be32 srcnode;
> >> +		} *hdr, _hdr;
> > 
> > Is this header defined somewhere in an include file ?
> > 
> > This looks a bit ugly to locally define the format...
> 
> I'd like this situation improved but I plan to apply this as-is for
> now.

About time we do something about this.. I'll post a patch with proper header
definitions soon.

//E


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
