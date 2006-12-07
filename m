From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 02:20:10 -0800 (PST)
Message-ID: <20061207.022010.120465413.davem@davemloft.net>
References: <20061207094502.GA19479@gate.ebshome.net>
	<20061207.015954.52181319.davem@davemloft.net>
	<20061207101555.GB19479@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031974AbWLGKT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 05:19:58 -0500
To: ebs@ebshome.net
In-Reply-To: <20061207101555.GB19479@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Surovegin <ebs@ebshome.net>
Date: Thu, 7 Dec 2006 02:15:55 -0800

> On Thu, Dec 07, 2006 at 01:59:54AM -0800, David Miller wrote:
> > From: Eugene Surovegin <ebs@ebshome.net>
> > Date: Thu, 7 Dec 2006 01:45:02 -0800
> > 
> > > I fail to see how this is not even more ugly and more complex than the 
> > > solution we have right now. Instead of trivial "orthogonal" polling 
> > > code you are suggesting adding additional complexity - handle 
> > > dynamic selection of that "master" EMAC and also handling situation 
> > > when this master device goes down and you have to switch to 
> > > another one without disturbing polling for other active devices. Why 
> > > all this? This hw is ugly enough as it is.
> > 
> > Don't do dynamic selection, that indeed would be dumb.
> > 
> > Instead, just pick one of them to act as the polling master.
> > Each EMAC has a backpointer to the master EMAC, and trigger
> > the poll via that indirection.
> 
> Well, dev_close() explicitly checks and modifies state bits related 
> to NAPI polling. From quick look I don't think it's safe to take down 
> "master" device and expect NAPI polling to still work.

Good point.

It also just occured to me that even if you use the dummy device
approach, it's the dummy device's quota that will be used by the
generic ->poll() downcall into the driver.
