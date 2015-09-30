From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 4/6] xfrm: Add xfrm6 address translation function
Date: Wed, 30 Sep 2015 10:39:27 +0200
Message-ID: <20150930083927.GE7701@secunet.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
 <1443565043-1287886-5-git-send-email-tom@herbertland.com>
 <560B17A6.8040308@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43786 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027AbbI3Ijb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 04:39:31 -0400
Content-Disposition: inline
In-Reply-To: <560B17A6.8040308@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 04:58:46PM -0600, David Ahern wrote:
> Hi Tom:
> 
> On 9/29/15 4:17 PM, Tom Herbert wrote:
> >This patch adds xfrm6_xlat_addr which is called in the data path
> >to perform address translation (primarily for the receive path). Modules
> >may register their own callback to perform a translation-- this
> >registration is managed by xfrm6_xlat_addr_add and xfrm6_xlat_addr_del.
> >xfrm6_xlat_addr allows translation of addresses for an sk_buff.
> 
> 
> Seems like a stretch to lump this into xfrms. You have a separate
> genl based config as opposed to the netlink xfrm API and you are
> calling the xlat_addr function directly in ip6_rcv as opposed to via
> some policy with dst_ops driven redirection. Why call this a xfrm?

I have to agree here. We have policies and states to do the lookups
and to describe the transformation. Just adding a callback to do this
in a different way does not integrate well into xfrm.
