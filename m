From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: support force_igmp_version=3 and force_mld_version=2 ?
Date: Thu, 25 Sep 2008 00:10:20 -0700
Message-ID: <OF447111C0.BCE492D0-ON882574CF.00250EFC-882574CF.00276685@us.ibm.com>
References: <alpine.LRH.2.00.0809250908590.21286@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:44699 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbYIYHKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 03:10:23 -0400
In-Reply-To: <alpine.LRH.2.00.0809250908590.21286@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2) only force_igmp_version=[12] is supported.  It might be useful to
>     support "force_igmp_version=3" as well, where the system will not
>     fall back to IGMPv1 or IGMPv2 compat mode even if it thinks it sees
>     or has seen an IGMPv1/v2 query.
> 

        IGMPv3 defines the interaction with IGMPv2-- there isn't any
choice about it, which is why v3 isn't in the force set. Forcing
earlier versions may be a requirement for switches, which is why
the knob is there, but forcing later versions, which all require
full knowledge of prior versions, doesn't make sense to me.
        Answering a v2 query with a v3 response wouldn't work, since
obviously v2 queriers don't know v3 packets, and ignoring them is
a technical violation of RFC 3376. Even 4604 doesn't suggest
these queries be ignored.
        Logging an error, as suggested in RFC 4604, is ok, but it
really is only a performance issue. Without the filter information,
the group memberships may be bigger than they need to be, but
the filters will still be applied on the receiver. Ignoring queries
or answering them with v3 are both broken, at least for the v2
querier.

        So, I don't think forcing IGMPv3 makes much sense. If you
really cared about it, you could always add an iptables entry to
drop them, right?

                                                        +-DLS

