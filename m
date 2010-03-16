From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Tue, 16 Mar 2010 12:56:00 -0500
Message-ID: <1268762160.25503.2988.camel@calx>
References: <1268753394-17765-1-git-send-email-jslaby@suse.cz>
	 <1268759527.25503.2980.camel@calx>  <4B9FBE49.6010709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <danborkmann@googlemail.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:44532 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966159Ab0CPR4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 13:56:03 -0400
In-Reply-To: <4B9FBE49.6010709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-16 at 18:22 +0100, Jiri Slaby wrote:
> On 03/16/2010 06:12 PM, Matt Mackall wrote:
> > I don't get it. The source of the branch tests for !ndev->npinfo and the
> > original destination of the branch also tests for !ndev->npinfo. I don't
> > see how it gets dereferenced.
> 
> Let's look at more of the context:
>          if (!ndev->npinfo) {
>                  npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
>                  if (!npinfo) {         // npinfo is NULL
>                          err = -ENOMEM;
>                          goto release;
>                  }
> ...
> release:                           // npinfo is still NULL
>          if (!ndev->npinfo) {       // condition is the same (holds)
>               // dereference below: vvvvvvvvvvvvvvv
>                  spin_lock_irqsave(&npinfo->rx_lock, flags);
>                  list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx) {
>                          npe->dev = NULL;
>                  }
>                  spin_unlock_irqrestore(&npinfo->rx_lock, flags);
> 
>                  kfree(npinfo);
>          }

Ok, you're correct, I read the second test backwards.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


