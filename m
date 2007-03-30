From: Thomas Graf <tgraf@suug.ch>
Subject: Re: tcp crash in net-2.6 tree
Date: Sat, 31 Mar 2007 00:10:54 +0200
Message-ID: <20070330221053.GR521@postel.suug.ch>
References: <20070329230917.63c3f79c.akpm@linux-foundation.org> <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi> <20070330.144347.68157619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51378 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932266AbXC3WKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 18:10:34 -0400
Content-Disposition: inline
In-Reply-To: <20070330.144347.68157619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-03-30 14:43
> Let's not speculate, let's find out for sure if snd_una is
> surpassing high_seq while we're in this state.
> 
> Andrew please give this debugging patch a spin, and also what
> is your workload?  I'd like to play with it too.
> 
> I've tried to code this patch so that if the bug triggers your
> machine shouldn't crash and burn completely, just spit out the
> log message.

I'm running into the same bug as Andew, i was able to reproduce
using Dave's patch within minutes:

TCP BUG: high_seq==NULL [c3c9cc54] q[c3c94edc] t[c3c9cc54]

The after(snd_una, high_seq) check is not triggered.
