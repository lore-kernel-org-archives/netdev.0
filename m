From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 06/21] RDS: Connection handling
Date: Tue, 27 Jan 2009 16:51:44 +0300
Message-ID: <20090127135144.GC18119@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-7-git-send-email-andy.grover@oracle.com> <20090127133418.GH2646@ioremap.net> <200901271447.29377.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Grover <andy.grover@oracle.com>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:43826 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857AbZA0Nvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:51:53 -0500
Content-Disposition: inline
In-Reply-To: <200901271447.29377.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 02:47:27PM +0100, Oliver Neukum (oliver@neukum.org) wrote:
> > > +static inline int rds_conn_is_sending(struct rds_connection *conn)
> > > +{
> > > +	int ret = 0;
> > > +
> > > +	if (!mutex_trylock(&conn->c_send_lock))
> > > +		ret = 1;
> > > +	else
> > > +		mutex_unlock(&conn->c_send_lock);
> > > +
> > > +	return ret;
> > > +}
> > > +
> > 
> > This one is eventually invoked under the spin_lock with turned off irqs,
> > which may freeze the machine:
> > rds_for_each_conn_info() -> spin_lock_irqsave(global lock) ->
> > rds_conn_info_visitor() -> rds_conn_info_set() -> rds_conn_is_sending()
> > -> boom.
> 
> Why? This is _trylock. It won't block.

Unlock may reschedule.

-- 
	Evgeniy Polyakov
