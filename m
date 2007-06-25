From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 16:23:02 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031B5835@orsmsx414.amr.corp.intel.com>
References: <20070625.143248.73361950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <shemminger@linux-foundation.org>
To: "David Miller" <davem@davemloft.net>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38533 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930AbXFYXXF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 19:23:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070625.143248.73361950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 25 Jun 2007 23:08:09 +0200
> 
> > David Miller wrote:
> > >
> > >> I've been using this patch and the IPROUTE2 patches Patrick has 
> > >> proposed with no issues.  Can someone else look at these patches 
> > >> when they have time?  I'd be interested in seeing them 
> make it into 2.6.23.
> > >>     
> > >
> > > I've just put Patrick's patch into the net-2.6.23 tree.
> > >   
> > 
> > You seem to have added the netlink patch for the generic netlink 
> > attributes. Peter needs the rtnetlink attribute patch since qdiscs 
> > still use the old stuff.
> > 
> > Attached again to this mail.
> 
> Thanks for the clarification, I thought they were both the 
> same patch, resent for the sake of tgraf seeing it.
> 
> I've applied this one too, thanks Patrick.

It looks like the one Patrick resent was the older version that requires
a typecast.  This is the function prototype currently in the kernel:

+extern int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+				      struct rtattr *rta, void **data,
int len);

This is the newer version:

+extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int
maxattr,
+				        struct rtattr *rta, int len);
+#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
+({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
+	__rtattr_parse_nested_compat(tb, max, rta, len); })
+

I can send the update to what's in 2.6.23 as the first patch of my
series, or I can write my function calls using the older callback (which
isn't a problem).  Which would you prefer?

Thanks,
-PJ Waskiewicz
