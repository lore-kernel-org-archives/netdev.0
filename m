From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 6/17 net-2.6.26] [NETNS]: Default arp parameters lookup.
Date: Tue, 19 Feb 2008 13:05:49 +0300
Message-ID: <1203415549.27296.16.camel@iris.sw.ru>
References: <1203406116.27296.1.camel@iris.sw.ru>
	 <1203406297-32725-6-git-send-email-den@openvz.org>
	 <47BA9E0B.6080209@fr.ibm.com> <1203413980.27296.9.camel@iris.sw.ru>
	 <47BAA690.2010504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29307 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760007AbYBSKFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 05:05:45 -0500
In-Reply-To: <47BAA690.2010504@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-02-19 at 10:51 +0100, Daniel Lezcano wrote:
> Denis V. Lunev wrote:
> > On Tue, 2008-02-19 at 10:14 +0100, Daniel Lezcano wrote:
> >> Denis V. Lunev wrote:
> >>> Default ARP parameters should be findable regardless of the context.
> >>> Required to make inetdev_event working.
> >>>
> >>> Signed-off-by: Denis V. Lunev <den@openvz.org>
> >>> ---
> >>>  net/core/neighbour.c |    4 +---
> >>>  1 files changed, 1 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> >>> index c895ad4..45ed620 100644
> >>> --- a/net/core/neighbour.c
> >>> +++ b/net/core/neighbour.c
> >>> @@ -1275,9 +1275,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
> >>>  	struct neigh_parms *p;
> >>>
> >>>  	for (p = &tbl->parms; p; p = p->next) {
> >>> -		if (p->net != net)
> >>> -			continue;
> >>> -		if ((p->dev && p->dev->ifindex == ifindex) ||
> >>> +		if ((p->dev && p->dev->ifindex == ifindex && p->net == net) ||
> >>>  		    (!p->dev && !ifindex))
> >>>  			return p;
> >>>  	}
> >> If the values are:
> >> 	p->dev == NULL
> >> 	ifindex == 0
> >> 	p->net != net
> >>
> >> The parms should not be taken into account and the looping must 
> >> continue. But with this modification it is not the case, if we specify 
> >> parms ifindex == 0, the first parms with the dev field set to NULL will 
> >> be taken belonging or not to the right net.
> > 
> > They should be taken. In the other case inetdev_event will fail for sure
> > in the middle. You could check.
> > 
> > These are ARP defaults and I do not see a problem for now to get them.
> 
> Because there is a parms default per namespace. So several instances of 
> them per nd table. That was the initial approach with Eric's patchset.
> 

These changes are not in mainstream and I do not want to touch ARP as
this is not a simple thing. In reality ARP will be needed only when
we'll have a real device inside a namespace.

Right now I prefer to have minimal set of working changes to finish IP
and upper layers.

Regards,
	Den

