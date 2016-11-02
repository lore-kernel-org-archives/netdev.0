From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Wed, 2 Nov 2016 18:29:00 +0300
Message-ID: <20161102152900.GC1852@uranus.lan>
References: <20161102123630.784612652@openvz.org>
 <2a540f59-4495-573c-7dda-0303f1810e6e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34779 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbcKBP3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:29:03 -0400
Received: by mail-lf0-f67.google.com with SMTP id i187so1179284lfe.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:29:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2a540f59-4495-573c-7dda-0303f1810e6e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 09:10:32AM -0600, David Ahern wrote:
> > @__dif != 0 the match may return socket where sk_bound_dev_if = 0
> > instead of completely matching one. Isn't it?
> 
> yes. I recently added an exact_dif to the lookup for listener sockets
> (see compute_score). Something like that could be added to INET_MATCH.

Seem so. I need to revisit this moment. Because with current lookup code
iproute2 patches I made and been testing do not kill all sockets bound
to particular device in one pass (because request from userspace asks
for index 15 in my case but kernel return one with index 0). At first
I thought I made a mistake in userspace code but once I added printk's
into kernel I found that here some strange results over lookup.

	Cyrill
