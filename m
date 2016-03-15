From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 12:58:00 -0400
Message-ID: <20160315165800.GL11063@oracle.com>
References: <20160315151248.GJ11063@oracle.com>
 <56E83A6D.6060904@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38453 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933150AbcCOQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 12:58:07 -0400
Content-Disposition: inline
In-Reply-To: <56E83A6D.6060904@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/15/16 09:38), santosh shilimkar wrote:
> >+	if (rtn->sndbuf_size > 0) {
> So value of 1 is allowed as well. There should be some
> minimum default or multiple of it. Of course above check
> can remain as is as long as you validate the user input
> in handlers.

yes, just as user-space SO_SNDBUF allows ridiculous values
for buffer size..

> >@@ -309,6 +352,7 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
> >  {
> >  	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> >
> >+	unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
> >  	/* If rds_tcp_exit_net() is called as a result of netns deletion,
> >  	 * the rds_tcp_kill_sock() device notifier would already have cleaned
> >  	 * up the listen socket, thus there is no work to do in this function.
> You need to unregister it on rds_tcp_listen_init() failure.

Ok, good point.

> >+	rtn->sndbuf_size = user_atoi(buffer, *lenp);
> As mentioned above, you should make sure the buffer lengths are
> legitimate.

As above. We allow any values that the TCP socket itself allows.
If the user wants to shoot themself in the foot, we dont stop them.

I'll fix the nits and send out another patchset in a bit. 
