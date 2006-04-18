From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Mon, 17 Apr 2006 22:45:46 -0700 (PDT)
Message-ID: <20060417.224546.89269212.davem@davemloft.net>
References: <20060417171253.4e988afc@localhost.localdomain>
	<E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17872
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751125AbWDRFpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 01:45:54 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 18 Apr 2006 12:28:48 +1000

> Stephen Hemminger <shemminger@osdl.org> wrote:
> > +       /* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
> > +       skb->nh.iph->protocol = IPPROTO_ICMP;
> 
> Do we really need this? After all we can get completely bogus values
> coming in through the network too.

ip_mc_check() will return 1 if it happens to be IGMP, that's not
a good default for this netlink lookup case.
