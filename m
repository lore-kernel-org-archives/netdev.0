From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Tue, 20 Aug 2013 23:14:07 -0700
Message-ID: <1377065647.4226.96.camel@edumazet-glaptop>
References: <1377030800.4226.89.camel@edumazet-glaptop>
	 <1377064785-12629-1-git-send-email-mailings@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferry Huberts <mailings@hupie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:51097 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab3HUGOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:14:09 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so3774pdj.32
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 23:14:08 -0700 (PDT)
In-Reply-To: <1377064785-12629-1-git-send-email-mailings@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 07:59 +0200, Ferry Huberts wrote:
> From: Ferry Huberts <ferry.huberts@pelagic.nl>
> 
> Not doing this (current behaviour) introduces reordering.
> 
> The packet_len_2_sched_time call is the only thing that logically
> depends on q->rate, so move the now/delay adjustment out of the if.
> 
> How to test:
> -----------

I ask again :

Did you test a config with both rate limiting and delay.

Netem primary use is to emulate say a 1Mbits link with a rtt of 50ms

netem rate 1Mbit delay 50ms


Because the "delay 10ms 500ms" is very strange : effective delay is in
the following range : -490 ms ... 510 ms

Its probably clamped to 0ms ... 510ms

I really doubt this is what you wanted.
