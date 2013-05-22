From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Wed, 22 May 2013 07:30:39 -0400
Message-ID: <OF1A7F184A.4282AFE8-ON85257B73.003E82A8-85257B73.003F3B88@us.ibm.com>
References: <20130517032449.GA3595@obelix.rh> <20130518173105.GD29528@order.stressinduktion.org> <20130521150616.GA8513@obelix.rh> <20130522004027.GD32093@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36350 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab3EVLd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:33:56 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 22 May 2013 05:33:51 -0600
In-Reply-To: <20130522004027.GD32093@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, I wouldn't call this a "bug"; it is listed as a "SHOULD", not a 
"MUST",  so
it is not required for compliance, though it is a good feature to add.

Second, I think doing this on all LL addresses unconditionally isn't a 
good
idea. If some configuration is using thousands of LL addrs for reasons of 
their
own, they would suddenly be blasted with unexpected MLD reports where
they have none now. I don't see why tracking it would be such a problem --
if nothing else, you could simply add a counter for the number of valid LL 
addrs
incremented on DAD completion, and send these whenever it transitions from 
0 to 1.

                                                +-DLS
