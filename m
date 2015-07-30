From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next 1/3] RDS-TCP: Make RDS-TCP work correctly
 when it is set up in a netns other than init_net
Date: Thu, 30 Jul 2015 19:58:57 +0200
Message-ID: <20150730175857.GA20426@oracle.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
 <89cdf26d7506a1d2d1a2d6cfda2fab9a5fc84ad6.1438245718.git.sowmini.varadhan@oracle.com>
 <55BA58D1.3050108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cwang@twopensource.com,
	ajaykumar.hotchandani@oracle.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18289 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689AbbG3R7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:59:06 -0400
Content-Disposition: inline
In-Reply-To: <55BA58D1.3050108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (07/30/15 11:03), David Ahern wrote:
> >+	write_pnet(&conn->c_net, net);
> 
> these are typically in wrappers like sock_net and sock_net_set
  :

> >+	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
> >+			       &rds_ib_transport, GFP_KERNEL);
> 
> I forget what connection this is -- control channel? 

this is IB. It should/will eventually also use any net than init_net,
but for the moment, I'd like to figure out the bigger  issue
of pernet vs per_subsys, which is harder to fix than the above
(and which I'll happily fix later).

I suspect that the right solution may be to have some notifier
callbacks in rds_tcp that listen for ifdown and tear down the sockets,
rather than wait for keepalive timeout.

> Ditto here.

yes, me too.

--Sowmini
