From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 01:59:54 -0800 (PST)
Message-ID: <20061207.015954.52181319.davem@davemloft.net>
References: <1165465446.5469.189.camel@localhost.localdomain>
	<20061207.011627.43485384.davem@davemloft.net>
	<20061207094502.GA19479@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031937AbWLGJ7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 04:59:42 -0500
To: ebs@ebshome.net
In-Reply-To: <20061207094502.GA19479@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Surovegin <ebs@ebshome.net>
Date: Thu, 7 Dec 2006 01:45:02 -0800

> I fail to see how this is not even more ugly and more complex than the 
> solution we have right now. Instead of trivial "orthogonal" polling 
> code you are suggesting adding additional complexity - handle 
> dynamic selection of that "master" EMAC and also handling situation 
> when this master device goes down and you have to switch to 
> another one without disturbing polling for other active devices. Why 
> all this? This hw is ugly enough as it is.

Don't do dynamic selection, that indeed would be dumb.

Instead, just pick one of them to act as the polling master.
Each EMAC has a backpointer to the master EMAC, and trigger
the poll via that indirection.

With this shared interrupt scheme and lack of hw interrupt
mitigation, how did the designers of this chip expect people
to do interrupt mitigation?  I suppose they expected you to
do it by standing on your head :-)

