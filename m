From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: correct settings of
	broadcast link state
Date: Fri, 20 Nov 2015 14:09:11 -0500 (EST)
Message-ID: <20151120.140911.1260774272529972355.davem@davemloft.net>
References: <1447960370-8306-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: parthasarathy.xx.bhuvaragan@ericsson.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1447960370-8306-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 19 Nov 2015 14:12:50 -0500

> Since commit 5266698661401afc5e ("tipc: let broadcast packet
> reception use new link receive function") the broadcast send
> link state was meant to always be set to LINK_ESTABLISHED, since
> we don't need this link to follow the regular link FSM rules. It
> was also the intention that this state anyway shouldn't impact
> the run-time working state of the link, since the latter in
> reality is controlled by the number of registered peers.
> 
> We have now discovered that this assumption is not quite correct.
> If the broadcast link is reset because of too many retransmissions,
> its state will inadvertently go to LINK_RESETTING, and never go
> back to LINK_ESTABLISHED, because the LINK_FAILURE event was not
> anticipated. This will work well once, but if it happens a second
> time, the reset on a link in LINK_RESETTING has has no effect, and
> neither the broadcast link nor the unicast links will go down as
> they should.
> 
> Furthermore, it is confusing that the management tool shows that
> this link is in UP state when that obviously isn't the case.
> 
> We now ensure that this state strictly follows the true working
> state of the link. The state is set to LINK_ESTABLISHED when
> the number of peers is non-zero, and to LINK_RESET otherwise.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.

------------------------------------------------------------------------------
