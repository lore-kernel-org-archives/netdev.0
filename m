From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Thu, 16 Feb 2012 17:20:40 +0000
Message-ID: <1329412840.2601.13.camel@bwh-desktop>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39162 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753471Ab2BPRUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 12:20:43 -0500
In-Reply-To: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 16:05 +0200, Ariel Elior wrote:
> In 57712 and 578xx the tx-switching module parameter allows the user to control
> whether outgoing traffic can be loopbacked into the device in case there is a
> relevant client for the data using the same device for rx.
> A classic example where this is necessary is for virtualization purposes, where
> one vm is transmitting data to another, while both use different pci functions of
> the same port of the same nic.
> 
> In case there is a promiscuous client in the rx (which wants to receive all
> data) or if the traffic is broadcast, traffic may be sent on both the loopback
> channel and the physical wire.
> 
> The reason tx-switching is controlled by a module parameter is twofold:
> 1. There is a certain performance penalty for tx-switching because:
>    a. every packet must be compared against the receiver clients.
>    b. duplicated traffic being loopbacked can consume a significant portion of
>    the overall bandwidth, depending on the scenario.

So you really want the driver/firmware/hardware to know all the local
addresses (as John Fastabend was proposing).

> 2. Tx-switching doesn't make much sense as a per function parameter, but should
> rather be controlled uniformly for the  entire device.
[...]

What if there are multiple such cards in the same system, and this is
only wanted for one of them?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
