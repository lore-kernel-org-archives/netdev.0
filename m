From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 3/6] rds: check for excessive looping in rds_send_xmit
Date: Thu, 02 Apr 2015 14:08:50 -0400 (EDT)
Message-ID: <20150402.140850.1775436517754499795.davem@davemloft.net>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
	<cover.1427983908.git.sowmini.varadhan@oracle.com>
	<5f877b89716358c7a08272275979b5e039ca1c29.1427983908.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com, agrover@redhat.com,
	clm@fb.com, zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f877b89716358c7a08272275979b5e039ca1c29.1427983908.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu,  2 Apr 2015 10:19:37 -0400

> @@ -177,6 +178,18 @@ int rds_send_xmit(struct rds_connection *conn)
>  
>  		rm = conn->c_xmit_rm;
>  
> +		if (!rm) {
> +			same_rm = 0;
> +		} else {
> +			same_rm++;
> +			if (same_rm >= 4096) {
> +				printk_ratelimited(KERN_ERR "RDS: Stuck rm\n");
> +				cond_resched();
> +				ret = -EAGAIN;
> +				break;
> +			}
> +		}
> +

I'm not accepting junk like this.

I want to know exactly how this situation can occur, in detail, and
then and only then can we start to talk about more reasonable
solutions to this bug.

This looks like a minimal effort hack to make a hang go away, and
even more concerning is that a change like this is submitted with
a commit message that is essentially empty.

Sorry, this is not acceptable.
