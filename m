From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Wed, 22 Sep 2010 14:41:37 -0700
Message-ID: <OF5594D8AA.554725F5-ON882577A6.00768526-882577A6.00772BB2@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <4C9A6D87.2000103@rincon.com> <alpine.DEB.2.00.1009221631520.32661@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bob Arendt <rda@rincon.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:53610 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab0IVVlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 17:41:40 -0400
In-Reply-To: <alpine.DEB.2.00.1009221631520.32661@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux.com> wrote on 09/22/2010 02:33:14 PM:

 This can address issues where joins are slow because the initial join is
> frequently lost.
> 
> Also increment the frequency so that we get a 10 reports send over a
> few seconds.

        Except you want to conform and not conform at the same time. :-)
IGMPv2 should be: default count 2, interval 10secs
IGMPv3 should be: default count 2, interval 1sec

...and no way is it a good idea to send 10 unsolicited reports on an
Ethernet.

I think system-wide defaults must be as suggested (which allows for
v3 being shortened to 1sec, but not v2) and if you want to use longer
values, you should have either a *per-interface* tunable [ie, the default
value for your interface only] or make these per-interface variables and
have the IB code bump them up for IB interfaces only. An attached
Ethernet on the same system shouldn't be using larger values unless
bumped for some reason by an administrator.

There is no problem with current values on Ethernet; lets not create
one. :-)

                                                                +-DLS

