From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next v2 1/6] tipc: allow connection shutdown callback
 to be invoked in advance
Date: Thu, 6 Mar 2014 10:06:34 +0100
Message-ID: <20140306090634.GA6630@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
 <1394006178-23966-2-git-send-email-erik.hugne@ericsson.com>
 <20140305.235618.31002872977881096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>,
	<ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:47026 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbaCFJGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 04:06:36 -0500
Content-Disposition: inline
In-Reply-To: <20140305.235618.31002872977881096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 11:56:18PM -0500, David Miller wrote:
> From: <erik.hugne@ericsson.com>
> Date: Wed, 5 Mar 2014 08:56:13 +0100
> 
> > @@ -413,8 +411,11 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
> >  	struct tipc_conn *con;
> >  
> >  	con = tipc_conn_lookup(s, conid);
> > -	if (!con)
> > +	if (!con) {
> > +		pr_err("Connection %d not found on server %s\n", conid,
> > +		       s->name);
> >  		return -EINVAL;
> > +	}
> >  
> >  	e = tipc_alloc_entry(data, len);
> >  	if (!e) {
> 
> You really don't want to add kernel log messages which might be easily
> triggerable by the user.  Please remove this.

Ok i'll remove it, but i'd anyway like to mention that this cannot be triggered
by users. This function is only invoked from the TIPC internal services
(subscriber and config) as a response from network events.

//E
