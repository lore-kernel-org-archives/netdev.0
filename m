From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/rds: RDS-TCP: Always create a new rds_sock for
 an incoming connection.
Date: Mon, 04 May 2015 14:47:20 -0400 (EDT)
Message-ID: <20150504.144720.2228274897975931117.davem@davemloft.net>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
	<cover.1430421231.git.sowmini.varadhan@oracle.com>
	<c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat,  2 May 2015 07:55:08 -0400

> When running RDS over TCP, the active (client) side connects to the
> listening ("passive") side at the RDS_TCP_PORT.  After the connection
> is established, if the client side reboots (potentially without even
> sending a FIN) the server still has a TCP socket in the Established
> state.  If the server-side now gets a new SYN comes from the client
> with a different client port, TCP will create a new socket-pair, but
> the RDS layer will incorrectly pull up the old rds_connection (which
> is still associated with the stale t_sock and RDS socket state).
> 
> This patch corrects this behavior by having rds_tcp_accept_one()
> always create a new connection for an incoming TCP SYN.
> The rds and tcp state associated with the old socket-pair is cleaned
> up in rds_tcp_set_callbacks() (i.e., rds_conn_drop on the old
> connection)
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

I think adding 64K of data to this module just to solve this rare
issue is excessive.

Furthermore I don't see any locking protecting the hash table nor
the RDS socket linkage into that table.
