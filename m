From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 1/3] net/rds: Use a single TCP socket for both
 send and receive.
Date: Wed, 30 Sep 2015 12:09:08 -0400
Message-ID: <20150930160908.GC8111@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
 <603874beb1dedd0a989d84740d22565bfc568c97.1443569239.git.sowmini.varadhan@oracle.com>
 <560C04AA.4050201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560C04AA.4050201@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (09/30/15 08:50), santosh shilimkar wrote:
> >  	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
> >-	WARN_ON(!rs_tcp || rs_tcp->t_sock);
> >+	if (rs_tcp->t_sock && inet->inet_saddr < inet->inet_daddr) {
> >+		struct sock *nsk = new_sock->sk;
> >
> Any reason you dropped the WARN_ON. Note that till we got commit
> 74e98eb0 (" RDS: verify the underlying transport exists before creating
> a connection") merged, we had an issue. That guards it now.

That was done deliberately. Now that we have only one tcp socket,
we can run into an rds_tcp_connection for an outgoing connection
that we initiated, thus rs_tcp->t_sock can be non-null - which is
why a new check is added in the newly added line in the patch.
