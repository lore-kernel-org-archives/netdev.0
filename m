From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 07 Dec 2012 08:54:29 -0800
Message-ID: <1354899269.26405.12.camel@edumazet-glaptop>
References: <1354892334.29937.14.camel@joe-AO722>
	 <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
	 <1354896346.29937.43.camel@joe-AO722>
	 <1354897144.26405.4.camel@edumazet-glaptop>
	 <1354897761.29937.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45648 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422904Ab2LGQyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:54:32 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so589712pad.19
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 08:54:32 -0800 (PST)
In-Reply-To: <1354897761.29937.45.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 08:29 -0800, Joe Perches wrote:

> Well Maybe Tom can provide some information as to why
> the limit variable was cacheline_aligned_in_smp and not
> the struct.
> 
> I didn't find any discussion about it.
> 

The struct _is_ cache line aligned, since it contains one field needing
cache line alignment. Its pretty clear to us.

There are two cache lines in it.

We don't one a single cache line, but two, for performance reasons.

If you believe its wrong, you have to provide the performance study, not
me, as I don't have time to spend cycles on this. We did this a long
time ago.

If you want to save few bytes on your kernel, redefine
__cacheline_aligned_on_smp to empty, and you'll be ok.
