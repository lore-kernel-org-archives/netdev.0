From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 13:48:47 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329046C6E1A@orsmsx414.amr.corp.intel.com>
References: <20080129184726.GA29300@gateway.home> <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com> <1201640243.4431.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Erik Mouw" <mouw@nl.linux.org>, <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4473 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbYA2VwA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 16:52:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1201640243.4431.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Are you using any specific qdisc, or just the default pfifo_fast?  
> > Have you done any specific tuning on your qdisc as well?  
> The default 
> > qlen seems to have been changed.
> 
> The driver seems buggy. Make it return NETDEV_TX_BUSY instead 
> of -EIO in xircom_start_xmit() and the messages will go away.

Totally agree.  However, the driver is still getting entries when it
shouldn't (netif_queue_stopped() is true), hence it's returning a non-OK
value.  We can either re-add the check for netif_queue_stopped() to
qdisc_restart(), or update the drivers to use the newer API.  I'd rather
do the latter, which I can work on.

Thanks Jamal!

-PJ
