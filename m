From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock
 contention
Date: Thu, 14 May 2015 09:24:46 -0700
Message-ID: <1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431614560-8866-1-git-send-email-willemb@google.com>
	 <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+FuTSfQ3xuTjJk-oSDvT0o67vY34Y68zVjuTByhNaGfaNPagg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35749 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679AbbENQYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 12:24:50 -0400
Received: by iebpz10 with SMTP id pz10so65168169ieb.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 09:24:50 -0700 (PDT)
In-Reply-To: <CA+FuTSfQ3xuTjJk-oSDvT0o67vY34Y68zVjuTByhNaGfaNPagg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 11:53 -0400, Willem de Bruijn wrote:

> I principally want to avoid the lock contention on sk_receive_queue.lock,
> which is held for a lot longer while probing frames. But yes, I'd prefer to
> avoid the cacheline contention as well.
> 
> The alternative is to keep the race and just replace the xchg with a
> straight assignment.

Please describe the race. It seems quite innocent at first look.

Clearly putting xchg() gives a false sense of security in this context.

Atomic ops should be reserved for cases we cannot avoid them,
not to give false hopes ;)
