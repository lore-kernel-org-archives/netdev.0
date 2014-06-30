From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Performance fix for process_backlog
Date: Mon, 30 Jun 2014 12:29:21 -0700
Message-ID: <1404156561.15139.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406291915560.4914@tomh.mtv.corp.google.com>
	 <1404108663.15139.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-yVFHQ7LNuE_S2Ot9EB_rWK_PyOGuRNo8RmYDEVg8gLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:62236 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757071AbaF3T3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 15:29:25 -0400
Received: by mail-wg0-f43.google.com with SMTP id b13so8602809wgh.14
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 12:29:24 -0700 (PDT)
In-Reply-To: <CA+mtBx-yVFHQ7LNuE_S2Ot9EB_rWK_PyOGuRNo8RmYDEVg8gLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-30 at 09:42 -0700, Tom Herbert wrote:

> Eliminating a couple of conditionals is a nice logic improvement, but
> is not material in the performance improvement. The improvement comes
> for the fact that we are staying in the the process_backlog loop and
> not clearing napi_state as long as there is still work to do. This can
> result in fewer IPIs which is shown in number of interrupts/sec.
> (1145382 vs. 1021674 in my test).
> 
> The cost of the change is one additional lock and check on qlen when
> the queue is empty, however in this case they should still be in the
> local cache so that's not overly expensive (far cheaper than more
> IPIs).

Great, thanks !
