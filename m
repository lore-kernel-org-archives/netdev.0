From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 06/21] RDS: Connection handling
Date: Tue, 27 Jan 2009 14:47:27 +0100
Message-ID: <200901271447.29377.oliver@neukum.org>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-7-git-send-email-andy.grover@oracle.com> <20090127133418.GH2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:45959 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZA0NrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 08:47:00 -0500
In-Reply-To: <20090127133418.GH2646@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tuesday 27 January 2009 14:34:19 schrieb Evgeniy Polyakov:
> On Mon, Jan 26, 2009 at 06:17:43PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
> > +static inline int rds_conn_is_sending(struct rds_connection *conn)
> > +{
> > +	int ret = 0;
> > +
> > +	if (!mutex_trylock(&conn->c_send_lock))
> > +		ret = 1;
> > +	else
> > +		mutex_unlock(&conn->c_send_lock);
> > +
> > +	return ret;
> > +}
> > +
> 
> This one is eventually invoked under the spin_lock with turned off irqs,
> which may freeze the machine:
> rds_for_each_conn_info() -> spin_lock_irqsave(global lock) ->
> rds_conn_info_visitor() -> rds_conn_info_set() -> rds_conn_is_sending()
> -> boom.

Why? This is _trylock. It won't block.

	Regards
		Oliver
 


