From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] RDS: fix rds-ping deadlock over TCP transport
Date: Fri, 16 Oct 2015 21:45:34 -0400
Message-ID: <20151017014534.GH5464@oracle.com>
References: <1445041610-30133-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445041610-30133-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/16/15 20:26), Santosh Shilimkar wrote:
> 
> diff --git a/net/rds/send.c b/net/rds/send.c
> +	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
> +		queue_delayed_work(rds_wq, &conn->c_send_w, 0);

A minor note- it would help to add some comments here explaining 
that the pong has already been added to the sendq earlier.. 
in the case of IB, if RDS_LL_SEND_FULL has been set, it takes some
head-scratching to figure out how the pong gets sent, and a  few
comments could help clarify that.

but other than that, the contents look good to me, thus

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
