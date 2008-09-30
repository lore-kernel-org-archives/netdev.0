From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 16:57:10 +0200
Message-ID: <20080930145710.GB2511@ami.dom.local>
References: <48E212FF.1060409@bull.net> <20080930144203.GA2511@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:57475 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbYI3O45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:56:57 -0400
Received: by gxk9 with SMTP id 9so11813584gxk.13
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 07:56:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080930144203.GA2511@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 04:42:04PM +0200, Jarek Poplawski wrote:
> Benjamin Thery wrote, On 09/30/2008 01:52 PM:
...
> > I'm still looking at why the first dst_free() on those particular routes 
> > doesn't call dst_destroy() immediately but defers it (another refcount
> > on the route itself).
> 
> Yes, finding/fixing this, if possible, in this place looks like the
> most consistent with the way netdev_wait_allrefs() is handling this.

Actually, I wonder, why we can't simply run this dst_gc_task() from
dst_dev_event() (after cancelling the work) when needed.

Jarek P.
