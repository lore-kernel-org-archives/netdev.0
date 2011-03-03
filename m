From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 2 Mar 2011 17:16:00 -0800
Message-ID: <20110302171600.577a4548@nehalam>
References: <20110302164637.6651b34f@nehalam>
 <20110302.165009.200353108.davem@davemloft.net>
 <20110302165653.4b854489@nehalam>
 <20110302.170346.13723622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49512 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756628Ab1CCBQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 20:16:03 -0500
In-Reply-To: <20110302.170346.13723622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Mar 2011 17:03:46 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 2 Mar 2011 16:56:53 -0800
> 
> > On Wed, 02 Mar 2011 16:50:09 -0800 (PST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> From: Stephen Hemminger <shemminger@vyatta.com>
> >> Date: Wed, 2 Mar 2011 16:46:37 -0800
> >> 
> >> > The addresses (that matter) when VPN is up are:
> >> 
> >> I really need to know what addresses interfaces have the time of the
> >> __ip_dev_find() call which, if I'm not mistaken, is before the VPN is
> >> up.
> > 
> > 
> >     inet 127.0.0.1/8 scope host lo
> >     inet 192.168.1.11/24 brd 192.168.1.255 scope global eth0
> >     inet 192.168.100.1/24 brd 192.168.100.255 scope global virbr0
> >     inet 192.168.99.1/24 brd 192.168.99.255 scope global virbr1
> 
> I see nothing providing 10.0.whatever that __ip_dev_find() is being
> asked to resolve.
> 
> I think we were allowing the route lookup pptp is trying to do at
> connect time erroneously, and it should elide the explicit source
> address specification in the flow.
> 

The VPN connection comes up the problem is that no packets pass over
it successfully.  The 10.X address is the other side of the VPN.

 I tried this, but it didn't work.

--- a/drivers/net/pptp.c	2011-03-02 17:01:55.353313682 -0800
+++ b/drivers/net/pptp.c	2011-03-02 17:02:05.381146980 -0800
@@ -473,7 +473,6 @@ static int pptp_connect(struct socket *s
 			.nl_u = {
 				.ip4_u = {
 					.daddr = opt->dst_addr.sin_addr.s_addr,
-					.saddr = opt->src_addr.sin_addr.s_addr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			.proto = IPPROTO_GRE };
 		security_sk_classify_flow(sk, &fl);

