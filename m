From: David Miller <davem@davemloft.net>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 15:15:01 -0700 (PDT)
Message-ID: <20070330.151501.98861701.davem@davemloft.net>
References: <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
	<20070330.144347.68157619.davem@davemloft.net>
	<20070330221053.GR521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932562AbXC3WPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 18:15:17 -0400
In-Reply-To: <20070330221053.GR521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 31 Mar 2007 00:10:54 +0200

> * David Miller <davem@davemloft.net> 2007-03-30 14:43
> > Let's not speculate, let's find out for sure if snd_una is
> > surpassing high_seq while we're in this state.
> > 
> > Andrew please give this debugging patch a spin, and also what
> > is your workload?  I'd like to play with it too.
> > 
> > I've tried to code this patch so that if the bug triggers your
> > machine shouldn't crash and burn completely, just spit out the
> > log message.
> 
> I'm running into the same bug as Andew, i was able to reproduce
> using Dave's patch within minutes:
> 
> TCP BUG: high_seq==NULL [c3c9cc54] q[c3c94edc] t[c3c9cc54]
> 
> The after(snd_una, high_seq) check is not triggered.

So tp->high_seq points to the tail packet end sequence.

Ilpo does this clear things up?
