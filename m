From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: Re: [PATCH] TIPC: Fix infinite loop in netlink
	handler
Date: Wed, 20 Jun 2007 07:13:22 -0700
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0135AC94@ala-mail02.corp.ad.wrs.com>
References: <46784B7F.8050903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	per.liden@ericsson.com, tipc-discussion@lists.sourceforge.net
To: "Patrick McHardy" <kaber@trash.net>,
	"Florian Westphal" <fw-kernel@strlen.de>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <46784B7F.8050903@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
 
> Florian Westphal wrote:
> > From: Florian Westphal <fw@strlen.de>
> > 
> > The tipc netlink config handler uses the nlmsg_pid from the request 
> > header as destination for its reply. If the application initialized 
> > nlmsg_pid to 0, the reply is looped back to the kernel, causing 
> > hangup. Fix: use nlmsg_pid of the skb that triggered the request.
> > 
> > -		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
> > +		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
> 
> 
> This is the second time we're seeing this bug within a few 
> weeks, maybe we should rename NETLINK_CB(skb).pid to dst_pid 
> to avoid similar confusion in the future? We could even 
> rename nlmsg_pid to nlmsg_src within the kernel, which should 
> make it completely clear what is being refered to.

I'm assuming that Patrick's first suggestion should have read "rename
NETLINK_CB(skb).pid to src_pid", as there is already a "dst_pid" field
in the netlink_skb_parms structure type.

I agree that such a change would make things clearer to folks who are
relative novices when it comes to Netlink.

-- Al

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
