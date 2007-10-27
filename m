From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] QUESTION: How to fix race between .suspend routine
 and watchdog timer
Date: Sat, 27 Oct 2007 18:24:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0710271820240.2321-100000@netrider.rowland.org>
References: <200710272119.44574.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>,
	<linux-pm@lists.linux-foundation.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:3529 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750975AbXJ0WYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 18:24:11 -0400
In-Reply-To: <200710272119.44574.maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 Oct 2007, Maxim Levitsky wrote:

> > Use del_timer_sync().  It guarantees that when it returns, the timer 
> > will be stopped and the timer routine will no longer be running on any 
> > CPU.
> > 
> Even if the timer re-enables itself, are you sure?

Last time I looked at the source code, that's what it did.  I'll look
again...  Yep, it still does.  It checks to see if the timer routine is
currently running; if so then it waits a little while and tries again.

Alan Stern

