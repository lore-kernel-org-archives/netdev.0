From: David Miller <davem@davemloft.net>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 18:02:25 -0800 (PST)
Message-ID: <20101115.180225.189678628.davem@davemloft.net>
References: <1289857936.2586.51.camel@bwh-desktop>
	<4CE1B8FD.3000007@garzik.org>
	<20101115233335.GB24292@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754847Ab0KPCCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 21:02:00 -0500
In-Reply-To: <20101115233335.GB24292@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Mon, 15 Nov 2010 18:33:35 -0500

> I tried to solve this by splitting the validate/change operation and
> thus be able to validate all requests before starting to commit
> them. This would mean changing all drivers though which I wasn't
> willing to do.

It isn't sufficient.  You can still get into unwindable failures.

Earlier operations can consume fixed resources like TCAM filter
slots or rx/tx queues, making a subsequent operation in the
sequence fail.

A validate/commit scheme cannot detect this effectively.
