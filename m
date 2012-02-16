From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Thu, 16 Feb 2012 20:28:38 +0200
Message-ID: <1329416919.30697.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
 <1329412840.2601.13.camel@bwh-desktop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2078 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab2BPS2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 13:28:53 -0500
In-Reply-To: <1329412840.2601.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 17:20 +0000, Ben Hutchings wrote:
> On Thu, 2012-02-16 at 16:05 +0200, Ariel Elior wrote:
> > In 57712 and 578xx the tx-switching module parameter allows the user to control
> > whether outgoing traffic can be loopbacked into the device in case there is a
> > relevant client for the data using the same device for rx.
> > A classic example where this is necessary is for virtualization purposes, where
> > one vm is transmitting data to another, while both use different pci functions of
> > the same port of the same nic.
> > 
> > In case there is a promiscuous client in the rx (which wants to receive all
> > data) or if the traffic is broadcast, traffic may be sent on both the loopback
> > channel and the physical wire.
> > 
> > The reason tx-switching is controlled by a module parameter is twofold:
> > 1. There is a certain performance penalty for tx-switching because:
> >    a. every packet must be compared against the receiver clients.
> >    b. duplicated traffic being loopbacked can consume a significant portion of
> >    the overall bandwidth, depending on the scenario.
> 
> So you really want the driver/firmware/hardware to know all the local
> addresses (as John Fastabend was proposing).

We need the HW to know the MAC addresses - L2 information only and each
PF is only configuring the addresses it owns (same addresses which are
used for Rx filtering anyway).

> > 2. Tx-switching doesn't make much sense as a per function parameter, but should
> > rather be controlled uniformly for the  entire device.
> [...]
> 
> What if there are multiple such cards in the same system, and this is
> only wanted for one of them?

Using this parameter is more likely in a physical device assignment in a
VM - having multiple devices that this rule apply to some but not all,
is possible - but less likely. It seem more convenient than using the
ethtool private flag and forcing the administrator to go over all PFs
(which sounds more common).
