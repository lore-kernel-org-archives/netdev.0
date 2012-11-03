From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [RFC] net: netlink -- Allow netlink_dump to return error code if
 protocol handler is missed
Date: Sat, 3 Nov 2012 23:16:17 +0400
Message-ID: <20121103191617.GD32458@moon>
References: <20121102173550.GH10877@moon>
 <509543AE.1020902@parallels.com>
 <20121103163958.GB6055@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62397 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab2KCTQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:16:21 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so3309754lbo.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 12:16:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121103163958.GB6055@moon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 03, 2012 at 08:39:58PM +0400, Cyrill Gorcunov wrote:
> On Sat, Nov 03, 2012 at 08:17:50PM +0400, Pavel Emelyanov wrote:
> > >  static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
> > > Index: linux-2.6.git/net/netlink/af_netlink.c
> > > ===================================================================
> > > --- linux-2.6.git.orig/net/netlink/af_netlink.c
> > > +++ linux-2.6.git/net/netlink/af_netlink.c
> > > @@ -1740,6 +1740,10 @@ static int netlink_dump(struct sock *sk)
> > >  		else
> > >  			__netlink_sendskb(sk, skb);
> > >  		return 0;
> > > +	} else if (len < 0) {
> > > +		err = len;
> > > +		nlk->cb = NULL;
> > > +		goto errout_skb;
> > 
> > When family-level handler is absent and sock_diag returns error this error
> > gets propagated back to user without this fix. Why do we need it in case
> > we return error from protocol-level handler?
> 
> Because as far as I can say the family-level handler already has such error
> returning code in __sock_diag_rcv_msg. Or you mean something else?

OK, it seems I got what you mean, cooking/testing new patch.
