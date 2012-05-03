From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 PATCH 3/4] tcp: move stats merge to the end of
 tcp_try_coalesce
Date: Thu, 03 May 2012 09:52:45 +0200
Message-ID: <1336031565.3503.25.camel@edumazet-glaptop>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	 <20120503071909.13636.43086.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57088 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab2ECHws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 03:52:48 -0400
Received: by eekc41 with SMTP id c41so411574eek.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 00:52:47 -0700 (PDT)
In-Reply-To: <20120503071909.13636.43086.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-03 at 00:19 -0700, Alexander Duyck wrote:
> This change cleans up the last bits of tcp_try_coalesce so that we only
> need one goto which jumps to the end of the function.  The idea is to make
> the code more readable by putting things in a linear order so that we start
> execution at the top of the function, and end it at the bottom.
> 
> I also made a slight tweak to the code for handling frags when we are a
> clone.  Instead of making it an if (clone) loop else nr_frags = 0 I changed
> the logic so that if (!clone) we just set the number of frags to 0 which
> disables the for loop anyway.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  net/ipv4/tcp_input.c |   55 ++++++++++++++++++++++++++------------------------
>  1 files changed, 29 insertions(+), 26 deletions(-)


Thanks a lot Alex, this patch serie looks very good.

Acked-by: Eric Dumazet <edumazet@google.com>
