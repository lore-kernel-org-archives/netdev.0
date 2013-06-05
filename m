From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Wed, 5 Jun 2013 10:05:51 -0400
Message-ID: <OF0B8CEFF8.C94A266F-ON85257B81.004D331F-85257B81.004D7015@us.ibm.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org> <1370406254-6341-2-git-send-email-stephen@networkplumber.org> <komnlc$ma8$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51967 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3FEOGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 10:06:16 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 5 Jun 2013 08:06:14 -0600
In-Reply-To: <komnlc$ma8$2@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 06/05/2013 02:59:56 AM:

> From: Cong Wang <xiyou.wangcong@gmail.com>
> To: netdev@vger.kernel.org
> Date: 06/05/2013 03:00 AM
> Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
> Sent by: netdev-owner@vger.kernel.org
> 
> On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger 
> <stephen@networkplumber.org> wrote:
> >        skb1 = skb_clone(skb, GFP_ATOMIC);
> > -      rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> > -      if (rc == NETDEV_TX_OK)
> > -         rc = rc1;
> > +      if (skb1) {
> > +         rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> > +         if (rc == NETDEV_TX_OK)
> > +            rc = rc1;
> > +      }
> 
> If OOM, shouldn't we exit immediately instead of continue handle the
> next one?

It could be a temporary condition; trying again doesn't really hurt,
in case some do go through. So, I prefer this, but could live with
bailing for all destinations, too.

                                                        +-DLS
