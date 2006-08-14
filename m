From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC 5/7] neighbour: convert lookup to sequence lock
Date: Tue, 15 Aug 2006 01:17:18 +0200
Message-ID: <20060814231718.GS14627@postel.suug.ch>
References: <20060814212004.606140865@localhost.localdomain> <20060814212143.845202090@localhost.localdomain> <20060814222220.GQ14627@postel.suug.ch> <20060814153743.0ab60955@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:30672 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965054AbWHNXQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 19:16:57 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060814153743.0ab60955@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@osdl.org> 2006-08-14 15:37
> On Tue, 15 Aug 2006 00:22:20 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> > Don't you need to pull in order to undo the push that probably
> > happened in dev->hard_header()?
> 
> Probably just record the headroom() and undo that?

That wouldn't work if hard_header() ever expands the head. Fortunately
hard_header() returns the length added even in case of an error so we
can undo the absolute value returned.
