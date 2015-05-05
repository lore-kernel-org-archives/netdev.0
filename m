From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH 1/2] net/rds: RDS-TCP: Always create a new rds_sock for
 an incoming connection.
Date: Tue, 5 May 2015 00:00:29 -0400
Message-ID: <20150505040029.GJ26844@oracle.com>
References: <c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
 <20150504.144720.2228274897975931117.davem@davemloft.net>
 <20150504192908.GC26844@oracle.com>
 <20150504.162134.1761886048618680717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42408 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbbEEEAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:00:36 -0400
Content-Disposition: inline
In-Reply-To: <20150504.162134.1761886048618680717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/04/15 16:21), David Miller wrote:
> 
> No table at all.
> 
> There has to be another way to notice this kind of situation, how
> for example does NFS or any other sunrpc using service handle this
> case?

NFS fixes up CLOSE_WAIT connections from xs_tcp_state_change,
so at the least, I can also do rds_conn_drop from rds_tcp_state_change,
that will avoid all the extra baggage around the new hash list.

But there's the case of the client disappearing without even sending
a FIN, and here NFS seems to recover using a notion of idle-timeout
(which applies to all idle peers, not merely the dead ones?) 

The closest analog of that would be to  set up a so_keepalive option on
the socket, but that brings in even more heuristics keepcnt, keepintvl,
keepidle. Maybe I could set these to be some very generous values
for now..

--Sowmini
