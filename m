From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Fri, 8 Oct 2010 16:52:57 +0200
Message-ID: <20101008145256.GB10393@redhat.com>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342Ab0JHOu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:50:59 -0400
Content-Disposition: inline
In-Reply-To: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 04:25:00PM +0200, Stanislaw Gruszka wrote:
> We have fedora bug report where driver fail to initialize after
> suspend/resume because of memory allocation errors:
> https://bugzilla.redhat.com/show_bug.cgi?id=629158

There is also one more thing to do regarding above. Calltraces from bug
reports, shows that order 3 allocation fail. On arch with 4kB pages,
order 3 mean 32kB allocation. We want to alloc 16kB, but there is also
internal sk_buff data what make that we exceed the boundary and take
32kB from allocator, getting almost 50% wastage.

To fix we can use similar method as in niu or iwlwifi drivers, alloc
pages directly form buddy allocator and attach them to skb (by
skb_add_rx_frag for example). I'm going to prepare such patch, but
I have one doubt, what happens if page size in system is bigger
than 16kB, should I care about such case? 

Stanislaw
