From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] rds: rds_cong_queue_updates needs to defer the
 congestion update transmission
Date: Wed, 11 Feb 2015 14:36:10 -0800 (PST)
Message-ID: <20150211.143610.1232446952245428061.davem@davemloft.net>
References: <20150210183337.GX337@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150210183337.GX337@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 10 Feb 2015 13:33:37 -0500

> 
> When the RDS transport is TCP, we cannot inline the call to rds_send_xmit
> from rds_cong_queue_update because
> (a) we are already holding the sock_lock in the recv path, and
>     will deadlock when tcp_setsockopt/tcp_sendmsg try to get the sock
>     lock
> (b) cong_queue_update does an irqsave on the rds_cong_lock, and this
>     will trigger warnings (for a good reason) from functions called
>     out of sock_lock.
> 
> This patch reverts the change introduced by
> 2fa57129d ("RDS: Bypass workqueue when queueing cong updates").
> 
> The patch has been verified for both RDS/TCP as well as RDS/RDMA
> to ensure that there are not regressions for either transport:
>  - for verification of  RDS/TCP a client-server unit-test was used,
>    with the server blocked in gdb and thus unable to drain its rcvbuf,
>    eventually triggering a RDS congestion update.
>  - for RDS/RDMA, the standard IB regression tests were used
> 
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied.
