From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] RDS: fix rds-ping deadlock over TCP
 transport
Date: Sun, 18 Oct 2015 22:46:27 -0700 (PDT)
Message-ID: <20151018.224627.1088014108100942192.davem@davemloft.net>
References: <1445048001-1086-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org, sowmini.varadhan@oracle.com
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445048001-1086-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Fri, 16 Oct 2015 22:13:21 -0400

> Sowmini found hang with rds-ping while testing RDS over TCP. Its
> a corner case and doesn't happen always. The issue is not reproducible
> with IB transport. Its clear from below dump why we see it with RDS TCP.
...
> This happens because rds_send_xmit() chain wants to take
> sock_lock which is already taken by tcp_v4_rcv() on its
> way to rds_tcp_data_ready(). Commit db6526dcb51b ("RDS: use
> rds_send_xmit() state instead of RDS_LL_SEND_FULL") which
> was trying to opportunistically finish the send request
> in same thread context.
> 
> But because of above recursive lock hang with RDS TCP,
> the send work from rds_send_pong() needs to deferred to
> worker to avoid lock up. Given RDS ping is more of connectivity
> test than performance critical path, its should be ok even
> for transport like IB.
> 
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by:  Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
> v2: Dropped the confusing SEND_LL_FULL check from v1

Applied, thank you.
