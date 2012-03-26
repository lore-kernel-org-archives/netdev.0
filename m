From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: socket option IP_MSFILTER questions and observations
Date: Mon, 26 Mar 2012 09:34:14 -0700
Message-ID: <OF4BDD6EDB.660350D9-ON882579CD.0059A093-882579CD.005B0615@us.ibm.com>
References: <4F708E08.7040500@softathome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Cedric Jehasse <cedric.jehasse@softathome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:53380 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738Ab2CZQgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 12:36:08 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 26 Mar 2012 10:36:07 -0600
In-Reply-To: <4F708E08.7040500@softathome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm trying to use source specific multicast by setting the IP_MSFILTER 
> socket option. I noticed i need to join the group with IP_ADD_MEMBERSHIP 

> before setting the source filter. This is not the behavior i expected 
> after reading RFC3678.
        RFC3678 doesn't say that an IP_MSFILTER will join a group
automatically. The model is that you join a group once and then
dynamically set the source filters as they change over time.

> A potential issue i'm thinking of with this approach: an IGMP report 
> could be sent after joining a group but before the filter is set.
> Is there a way to prevent this?

        Adding or changing the source filters triggers a new report
but you can use IP_ADD_SOURCE_MEMBERSHIP which does explicitly join
a group with a source filter. In the kernel, this is done with an
"any" join followed by setting a source filter which actually will result
in 2 reports too, if there are no other processes using that group.

                                                        +-DLS
