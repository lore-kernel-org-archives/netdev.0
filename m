From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] rds: Make sure updates to cp_send_gen can be observed
Date: Thu, 20 Jul 2017 07:02:54 -0400
Message-ID: <20170720110254.GB14156@oracle.com>
References: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: H??kon Bugge <Haakon.Bugge@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (07/20/17 12:28), H??kon Bugge wrote:
> cp->cp_send_gen is treated as a normal variable, although it may be
> used by different threads.

I'm confused by that assertion. If you look at the comments right
above the change in your patch, there is a note that 
acquire_in_xmit/release_in_xmit are the synchronization/serialization 
points.

Can you please clarify?

> --- a/net/rds/send.c
> +++ b/net/rds/send.c
> @@ -170,8 +170,8 @@ int rds_send_xmit(struct rds_conn_path *cp)
>  	 * The acquire_in_xmit() check above ensures that only one
>  	 * caller can increment c_send_gen at any time.
>  	 */
> -	cp->cp_send_gen++;
> -	send_gen = cp->cp_send_gen;
> +	send_gen = READ_ONCE(cp->cp_send_gen) + 1;
> +	WRITE_ONCE(cp->cp_send_gen, send_gen);
>  

--Sowmini
