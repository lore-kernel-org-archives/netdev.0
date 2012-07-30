From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/7] netpoll: make __netpoll_cleanup non-block
Date: Mon, 30 Jul 2012 09:42:01 +0800
Message-ID: <1343612521.1642.2.camel@cr0>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
	<1343403484-29347-3-git-send-email-amwang@redhat.com>
	<20120727184031.GB20938@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Joe Perches <joe@perches.com>, Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120727184031.GB20938@hmsreliant.think-freely.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-27 at 14:40 -0400, Neil Horman wrote:
> Here, and above I see you using an rcu_head to defer cleanup, until after all
> pointer uses are dropped, but I don't see any modification of code points that
> dereference any struct netpoll pointers to include
> rcu_read_lock()/rcu_read_unlock().  Without those using rcu to defer cleanup is
> pointless, as the rcu code won't know when its safe to run.  You're no better
> off that you would be just calling __netpoll_cleanup directly.

Hi, Neil,

Actually they are protected by rcu_read_lock_bh() which is implied by
local_irq_disable(), see:

commit f0f9deae9e7c421fa0c1c627beb8e174325e1ba7
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Sep 17 16:55:03 2010 -0700

    netpoll: Disable IRQ around RCU dereference in netpoll_rx
    
    We cannot use rcu_dereference_bh safely in netpoll_rx as we may
    be called with IRQs disabled.  We could however simply disable
    IRQs as that too causes BH to be disabled and is safe in either
    case.
    
    Thanks to John Linville for discovering this bug and providing
    a patch.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Thanks.
