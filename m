From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 12:31:41 +0200
Message-ID: <20080817103141.GC2907@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171235.46413.denys@visp.net.lb> <20080817095220.GB2907@ami.dom.local> <200808171301.56002.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:32692 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbYHQKbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 06:31:33 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1004426nfc.21
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 03:31:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171301.56002.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 01:01:55PM +0300, Denys Fedoryshchenko wrote:
> Ok, now things finally organized.
> fixing patch #1 was missing.
> 
> Rebooting system to this kernel. But strange thing, without fixing patch #1 it 
> didn't crash for whole night, and 1-3 hours now (with same options as 
> before).

The fixing patch #1 was intended to fix only one issue shown in the
warnings: qdisc_watchdog scheduled leaf qdiscs for qdisc_run(), so
they were dequeued directly (skipping root qdiscs) and with wrong
locks.

The fixing patch #2 changes qdisc locking generally, so it probably
fixed other locking issues btw. like this last oops seen after the
patch #1. But still there is this (not critical) issue of skipping
root qdiscs while dequeuing after qdisc_watchdog, which has to be done
by the fixing patch #1.

Jarek P.
