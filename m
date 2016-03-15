From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 10:18:14 -0700
Message-ID: <1458062294.31401.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160315151248.GJ11063@oracle.com>
	 <56E83A6D.6060904@oracle.com> <20160315165800.GL11063@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: santosh shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35035 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934740AbcCORSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 13:18:16 -0400
Received: by mail-pf0-f177.google.com with SMTP id n5so36757870pfn.2
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 10:18:16 -0700 (PDT)
In-Reply-To: <20160315165800.GL11063@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-15 at 12:58 -0400, Sowmini Varadhan wrote:
> On (03/15/16 09:38), santosh shilimkar wrote:
> > >+	if (rtn->sndbuf_size > 0) {
> > So value of 1 is allowed as well. There should be some
> > minimum default or multiple of it. Of course above check
> > can remain as is as long as you validate the user input
> > in handlers.
> 
> yes, just as user-space SO_SNDBUF allows ridiculous values
> for buffer size..

Well... Not really.

> 
> > >@@ -309,6 +352,7 @@ static void __net_exit rds_tcp_exit_net(struct net *net)
> > >  {
> > >  	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
> > >
> > >+	unregister_net_sysctl_table(rtn->rds_tcp_sysctl);
> > >  	/* If rds_tcp_exit_net() is called as a result of netns deletion,
> > >  	 * the rds_tcp_kill_sock() device notifier would already have cleaned
> > >  	 * up the listen socket, thus there is no work to do in this function.
> > You need to unregister it on rds_tcp_listen_init() failure.
> 
> Ok, good point.
> 
> > >+	rtn->sndbuf_size = user_atoi(buffer, *lenp);
> > As mentioned above, you should make sure the buffer lengths are
> > legitimate.
> 
> As above. We allow any values that the TCP socket itself allows.
> If the user wants to shoot themself in the foot, we dont stop them.

Look at SO_SNDBUF and SO_RCVBUF implementation.

sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);

sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);

kernel definitely has some logic here.

If you believe SOCK_MIN_SNDBUF and/or SOCK_MIN_RCVBUF are wrong, please
elaborate.
