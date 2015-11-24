From: David Miller <davem@redhat.com>
Subject: Re: [Resend PATCH] RDS: fix race condition when sending a message
 on unbound socket
Date: Tue, 24 Nov 2015 17:20:56 -0500 (EST)
Message-ID: <20151124.172056.726395208871301533.davem@redhat.com>
References: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sasha.levin@oracle.com, ben@decadent.org.uk,
	quentin.casasnovas@oracle.com, stable@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Tue, 24 Nov 2015 17:13:21 -0500

> From: Quentin Casasnovas <quentin.casasnovas@oracle.com>
> 
> Sasha's found a NULL pointer dereference in the RDS connection code when
> sending a message to an apparently unbound socket.  The problem is caused
> by the code checking if the socket is bound in rds_sendmsg(), which checks
> the rs_bound_addr field without taking a lock on the socket.  This opens a
> race where rs_bound_addr is temporarily set but where the transport is not
> in rds_bind(), leading to a NULL pointer dereference when trying to
> dereference 'trans' in __rds_conn_create().
> 
> Vegard wrote a reproducer for this issue, so kindly ask him to share if
> you're interested.
> 
> I cannot reproduce the NULL pointer dereference using Vegard's reproducer
> with this patch, whereas I could without.
> 
> Complete earlier incomplete fix to CVE-2015-6937:
> 
>   74e98eb08588 ("RDS: verify the underlying transport exists before creating a connection")
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: stable@vger.kernel.org
> 
> Reviewed-by: Vegard Nossum <vegard.nossum@oracle.com>
> Reviewed-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Signed-off-by: Quentin Casasnovas <quentin.casasnovas@oracle.com>

Applied and queued up for -stable, thanks.
