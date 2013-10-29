From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netback: allocate xenvif arrays using
 vzalloc.
Date: Tue, 29 Oct 2013 08:43:50 -0700
Message-ID: <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131029152628.GA3065@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org,
	andrew.bennieston@citrix.com, david.vrabel@citrix.com,
	malcolm.crossley@citrix.com
To: Joby Poriyath <joby.poriyath@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:38731 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab3J2PoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 11:44:04 -0400
Received: by mail-pb0-f45.google.com with SMTP id ma3so21599pbc.32
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 08:44:03 -0700 (PDT)
In-Reply-To: <20131029152628.GA3065@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 15:27 +0000, Joby Poriyath wrote:
> This will reduce memory pressure when allocating struct xenvif.
> 
> The size of xenvif struct has increased from 168 to 36632 bytes (on x86-32).
> See commit b3f980bd827e6e81a050c518d60ed7811a83061d. This resulted in
> occasional netdev allocation failure in dom0 with 752MiB RAM, due to
> fragmented memory.

This looks overkill. 

Replacing a single allocation of ~36 KB into 5 vmalloc() looks like you
did not really tried other things...

This should be done generically in alloc_netdev_mqs()

Take a look at commit 60877a32bce00041
("net: allow large number of tx queues")
