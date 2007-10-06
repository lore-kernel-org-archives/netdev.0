From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 17:28:01 -0700
Message-ID: <20071005172801.7f657e81@freepuppy.rosehill>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005084317.52ee7efe@freepuppy.rosehill>
	<20071005.170428.68050176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49996 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752616AbXJFA2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:28:14 -0400
In-Reply-To: <20071005.170428.68050176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Oct 2007 17:04:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 5 Oct 2007 08:43:17 -0700
> 
> > Sparse warnings from new driver.
> >  CHECK   drivers/net/niu.c
> > drivers/net/niu.c:619:7: warning: symbol 'err' shadows an earlier one
> > drivers/net/niu.c:574:6: originally declared here
> > drivers/net/niu.c:4673:7: warning: symbol 'err' shadows an earlier one
> > drivers/net/niu.c:4668:12: originally declared here
> 
> I fixed these two, the first was harmless but the second
> one would cause error cases to return the wrong error
> status to the caller.
> 
> > drivers/net/niu.c:203:2: error: bad constant expression
> > drivers/net/niu.c:203:2: error: cannot size expression
> > drivers/net/niu.c:4214:2: error: bad constant expression
> > drivers/net/niu.c:4214:2: error: cannot size expression
> 
> I can't figure out what sparse doesn't like here.

Sparse doesn't like dynamically sized arrays, which is what BUILD_BUG_ON()
expands into.  Not sure why it is hostile to dynamic arrays,
probably just a Linus (or Viro) taste thing.
