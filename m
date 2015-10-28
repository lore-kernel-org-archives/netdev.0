From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] RDS-TCP: Recover correctly from
 pskb_pull()/pksb_trim() failure in rds_tcp_data_recv
Date: Tue, 27 Oct 2015 19:47:04 -0700 (PDT)
Message-ID: <20151027.194704.863557122432415853.davem@davemloft.net>
References: <20151026164637.GK10039@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151026164637.GK10039@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 26 Oct 2015 12:46:37 -0400

> Either of pskb_pull() or pskb_trim() may fail under low memory conditions.
> If rds_tcp_data_recv() ignores such failures, the application will
> receive corrupted data because the skb has not been correctly
> carved to the RDS datagram size.
> 
> Avoid this by handling pskb_pull/pskb_trim failure in the same
> manner as the skb_clone failure: bail out of rds_tcp_data_recv(), and
> retry via the deferred call to rds_send_worker() that gets set up on
> ENOMEM from rds_tcp_read_sock()
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied and queued up for -stable, thanks.
