From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/5] tipc: align TIPC behaviours
	of waiting for events with other stacks
Date: Fri, 17 Jan 2014 09:50:02 +0800
Message-ID: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Comparing the current implementations of waiting for events in TIPC
socket layer with other stacks, TIPC's behaviour is very different
because wait_event_interruptible_timeout()/wait_event_interruptible()
are always used by TIPC to wait for events while relevant socket or
port variables are fed to them as their arguments. As socket lock has
to be released temporarily before the two routines of waiting for
events are called, their arguments associated with socket or port
structures are out of socket lock protection. This might cause
serious issues where the process of calling socket syscall such as
sendsmg(), connect(), accept(), and recvmsg(), cannot be waken up
at all even if proper event arrives or improperly be woken up
although the condition of waking up the process is not satisfied
in practice.

Therefore, aligning its behaviours with similar functions implemented
in other stacks, for instance, sk_stream_wait_connect() and
inet_csk_wait_for_connect() etc, can avoid above risks for us.

Ying Xue (5):
  tipc: standardize connect routine
  tipc: standardize accept routine
  tipc: standardize sendmsg routine of connectionless socket
  tipc: standardize sendmsg routine of connected socket
  tipc: standardize recvmsg routine

 net/tipc/socket.c |  296 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 186 insertions(+), 110 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
