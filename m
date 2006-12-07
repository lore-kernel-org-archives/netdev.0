From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 15:24:06 +1100
Message-ID: <1165465446.5469.189.camel@localhost.localdomain>
References: <1165465300.5469.187.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57849 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968735AbWLGEYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 23:24:14 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1165465300.5469.187.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> What Eugene does currently, which seems to me like it's actually the
> only proper solution, is to create a separate net_device structure for
> the DMA engine and thus have a single NAPI poll & weighting for all the
> EMACs sharing a given MAL (MAL is the name of that DMA engine). This
> means that Rx from any of the channels schedules the poll, and
> interrupts can be properly masked/unmasked globally based on the
> presence/absence of work on all the channels.

Actually, another solution would be to have one of the instances do the
NAPI poll for all of them instead of creating a separate net_device for
the DMA engine...

Ben.


