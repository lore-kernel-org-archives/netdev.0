From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Wed, 21 Aug 2013 08:39:35 -0700
Message-ID: <1377099575.4226.120.camel@edumazet-glaptop>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>
	 <1377011469-26151-2-git-send-email-mailings@hupie.com>
	 <5214D9F2.90900@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mailings@hupie.com, netdev@vger.kernel.org
To: Johannes Naab <jn@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42164 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab3HUPjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 11:39:39 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so946179pad.23
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 08:39:38 -0700 (PDT)
In-Reply-To: <5214D9F2.90900@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 17:17 +0200, Johannes Naab wrote:
> On 08/20/2013 05:11 PM, Ferry Huberts wrote:
> > From: Ferry Huberts <ferry.huberts@pelagic.nl>
> > 
> > Not doing this (current behaviour) introduces reordering.
> > 
> > The packet_len_2_sched_time call is the only thing that logically
> > depends on q->rate, so move the now/delay adjustment out of the if.
> > 
> > Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
> > ---
> 
> Hi,
> 
> The documentation for netem does explicitly mention the reordering with
> jitter, and gives instructions on how to avoid it. (I have not tested if
> it works as intended).


Yes.

The user specifically adds a random delay of 0 to 510 ms to packets,
and expect netem to not reorder packets sent every 100ms.

They see netem as a single medium between two endpoints with a guarantee
of no reordering, and cumulative delays.

So if you send a burst of 100 packets, they might expect the last packet
will be send after ~50 seconds.

This clearly needs a new option to netem, because this is not the
default behavior we want.
