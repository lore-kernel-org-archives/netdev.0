From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 17:15:04 -0700 (PDT)
Message-ID: <20070625.171504.13046835.davem@davemloft.net>
References: <20070625.143248.73361950.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329031B5835@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754957AbXFZAOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 20:14:46 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031B5835@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 25 Jun 2007 16:23:02 -0700

> It looks like the one Patrick resent was the older version that requires
> a typecast.  This is the function prototype currently in the kernel:
> 
> +extern int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
> +				      struct rtattr *rta, void **data,
> int len);
> 
> This is the newer version:
> 
> +extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int
> maxattr,
> +				        struct rtattr *rta, int len);
> +#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
> +({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
> +	__rtattr_parse_nested_compat(tb, max, rta, len); })
> +
> 
> I can send the update to what's in 2.6.23 as the first patch of my
> series, or I can write my function calls using the older callback (which
> isn't a problem).  Which would you prefer?

Either way is fine with me, just use the interface in the tree
for now and we can fix it up if we add the prototype change.

Meanwhile, Patrick please clear up the situation :-)
