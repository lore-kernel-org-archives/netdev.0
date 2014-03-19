From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 20:42:37 -0700
Message-ID: <1395200557.8649.20.camel@joe-AO722>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
	 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jean Sacren <sakiwit@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0046.hostedemail.com ([216.40.44.46]:41396 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933733AbaCSDmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 23:42:40 -0400
In-Reply-To: <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 20:32 -0700, Eric Dumazet wrote:
> On Tue, 2014-03-18 at 21:19 -0600, Jean Sacren wrote:
> 
> > 2) Fix the initializer by deleting the double logical negation
> >    operators as they don't serve any purpose.
> > 
> ...
> >  
> >  static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
> >  {
> > -	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
> 
> You do realize !!(a) is not equivalent to (a) ?

It is when the type it's assigned to also changes
from u8 to bool.

I don't think it's a great style though.
I think the !! doesn't hurt here.

I'd've preferred it to be

	bool on = nla_get_u8(...)

rather than separating the declaration from the assignment
by a few lines of code.
