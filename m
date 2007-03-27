From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] netlink: no need to crash if table does not exist.
Date: Tue, 27 Mar 2007 16:41:54 -0700 (PDT)
Message-ID: <20070327.164154.48396509.davem@davemloft.net>
References: <20070321104456.GA2637@2ka.mipt.ru>
	<46010EF5.6010306@trash.net>
	<20070321105847.GA18221@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbXC0Xms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 19:42:48 -0400
In-Reply-To: <20070321105847.GA18221@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 21 Mar 2007 13:58:47 +0300

> On Wed, Mar 21, 2007 at 11:54:45AM +0100, Patrick McHardy (kaber@trash.net) wrote:
> > Evgeniy Polyakov wrote:
> > > We would already do that on init.
> > > Some things become very confused, when nl_table is not used to store
> > > netlink sockets.
> > 
> > 
> > Its unnecessary, but I don't understand what the problem is.
> > Why would it be NULL and what gets confused?
> 
> There is no problem as-is, but I implement unified cache for different
> sockets (currently tcp/udp/raw and netlink are supported), which does
> not use that table, so I currently wrap all access code into special
> ifdefs, this one can be wrapped too, but since it is not needed, it
> saves couple of lines of code.

It is needed.  It is there to make sure that a kernel netlink
socket is not created before the af_netlink init code runs.

We've had sequencing bugs like that in the initcall call chain
in the past, that's why the check is there.
