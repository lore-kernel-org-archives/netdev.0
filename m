From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] add nl80211
Date: Fri, 25 Aug 2006 11:04:30 +0200
Message-ID: <1156496671.3893.6.camel@ux156>
References: <1156254768.3825.1.camel@ux156> <1156435624.10283.9.camel@ux156>
	 <20060824172717.GN3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32435 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751364AbWHYJER
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 05:04:17 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060824172717.GN3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-24 at 19:27 +0200, Thomas Graf wrote:

> I'd use normal u32 attributes here as well and simply
> enumerate their type 1..n.
> 
> 	int idx = 1
> 	list_for_each_entry(drv, &nl80211_drv_list, list)
> 		NLA_PUT_U32(msg, idx++, drv->wiphy);
> 
> The additional header seems waste but this way you stay flexible
> and can extend the protocol later on. Attribute lengths are
> checked with an open end in mind, i.e. you can put more stuff
> behind that u32 in the future and your old applications will
> still work.
> 
> You also might want to consider returning ifindex and
> the associated name.

That'd be a list of ifindexes again...

> > +static int nl80211_get_intfs(struct sk_buff *skb, struct genl_info *info)

> Try not to reuse the same attribute type for different purposes,
> it will force you to duplicate the validation policy for every
> single command and things become very error prone.

I completely reworked that now so it will:
 * create a nested NL80211_ATTR_INTERFACE_LIST with nested {
   * 1..N attributes, with nested {
     * ATTR_IFINDEX and
     * ATTR_IFNAME
   }
 }

how does that sound? Maybe I should do the same for the WIPHY list? i.e.
create a new type ATTR_WIPHY_LIST and within that nest numbered
attributes (array indexes) and in there put ATTR_WIPHY? So possibly I
could also put ATTR_INTERFACE_LIST in there as well later?

johannes
