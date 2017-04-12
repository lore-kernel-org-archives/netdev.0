From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 14:49:53 -0700
Message-ID: <1492033793.10587.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
         <20170412143037.5fd7a088@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34488 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdDLVt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 17:49:56 -0400
In-Reply-To: <20170412143037.5fd7a088@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 14:30 -0700, Stephen Hemminger wrote:
> On Wed, 12 Apr 2017 14:54:15 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index b0aa089..071a58b 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1891,9 +1891,17 @@ struct net_device {
> >  	struct lock_class_key	*qdisc_tx_busylock;
> >  	struct lock_class_key	*qdisc_running_key;
> >  	bool			proto_down;
> > +	struct bpf_prog __rcu	*xdp_prog;
> 
> It would be good if all devices could reuse this for the xdp_prog pointer.
> It would allow for could be used for introspection utility functions in future.

Problem is that some xdp usages were envisioning a per RX queue xdp
program.
