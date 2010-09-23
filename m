From: Christoph Lameter <cl@linux.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Thu, 23 Sep 2010 10:37:48 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231021080.32567@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <4C9A6D87.2000103@rincon.com>
 <alpine.DEB.2.00.1009221631520.32661@router.home> <OF5594D8AA.554725F5-ON882577A6.00768526-882577A6.00772BB2@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bob Arendt <rda@rincon.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.ac4.yahoo.com ([76.13.13.47]:43596 "HELO
	smtp108.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752760Ab0IWPhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:37:52 -0400
In-Reply-To: <OF5594D8AA.554725F5-ON882577A6.00768526-882577A6.00772BB2@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Sep 2010, David Stevens wrote:

> >
> > Also increment the frequency so that we get a 10 reports send over a
> > few seconds.
>
>         Except you want to conform and not conform at the same time. :-)
> IGMPv2 should be: default count 2, interval 10secs
> IGMPv3 should be: default count 2, interval 1sec

This is during the period of unsolicited igmp reports. We do not know if
this group is managed using V3 or V2 since no igmp query/report has been
received yet.

> ...and no way is it a good idea to send 10 unsolicited reports on an
> Ethernet.

Why would that be an issue?

The IGMPv2 RFC has no strict limit and RFC3376
mentions that the retransmission occurs "Robustness Variable" times
minus one. Choosing 10 for the "Robustness Variable" is certainly ok.

If we do not increase the number of reports but just limit the interval
then the chance of outages of a second or so during mc group creation
causing routers missing igmp reports is significantly increased.

