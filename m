From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: ioctl send PID in netlink events
Date: Thu, 02 Jun 2005 21:37:35 -0400
Message-ID: <1117762655.6095.3.camel@localhost.localdomain>
References: <1117720349.6050.59.camel@localhost.localdomain>
	 <20050603010059.GU15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050603010059.GU15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-06 at 03:00 +0200, Thomas Graf wrote:
> > Index: net/ipv4/devinet.c
> > ===================================================================
> > --- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/ipv4/devinet.c  (mode:100644)
> > +++ uncommitted/net/ipv4/devinet.c  (mode:100644)
> > @@ -236,6 +236,7 @@
> >  	struct in_ifaddr *promote = NULL;
> >  	struct in_ifaddr *ifa1 = *ifap;
> >  
> > +	printk("inet_del_ifa: pid %d\n",current->pid);
> >  	ASSERT_RTNL();
> >  
> >  	/* 1. Deleting primary ifaddr forces deletion all secondaries 
> > @@ -305,6 +306,7 @@
> >  
> >  	ASSERT_RTNL();
> >  
> > +	printk("inet_insert_ifa: pid %d\n",current->pid);
> >  	if (!ifa->ifa_local) {
> >  		inet_free_ifa(ifa);
> >  		return 0;
> 
> Don't you want to remove these?
> 
> 

Yes, how did those get there? ;-> 

> > Index: net/ipv4/fib_semantics.c
> > ===================================================================
> > --- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/ipv4/fib_semantics.c  (mode:100644)
> > +++ uncommitted/net/ipv4/fib_semantics.c  (mode:100644)
> > @@ -276,7 +276,7 @@
> >  	       struct nlmsghdr *n, struct netlink_skb_parms *req)
> >  {
> >  	struct sk_buff *skb;
> > -	u32 pid = req ? req->pid : 0;
> > +	u32 pid = req ? req->pid : n->nlmsg_pid;
> >  	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
> >  
> >  	skb = alloc_skb(size, GFP_KERNEL);
> > @@ -1035,7 +1035,7 @@
> >  	}
> >  
> >  	nl->nlmsg_flags = NLM_F_REQUEST;
> > -	nl->nlmsg_pid = 0;
> > +	nl->nlmsg_pid = current->pid;
> >  	nl->nlmsg_seq = 0;
> >  	nl->nlmsg_len = NLMSG_LENGTH(sizeof(*rtm));
> >  	if (cmd == SIOCDELRT) {
> 
> Neat ;->


The second one could probably use the new macros.
Maybe i will wait until Dave puts this in his tree and send a small
change; else you could send it.

cheers,
jamal
