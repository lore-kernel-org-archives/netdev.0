From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] doc: document MSG_ZEROCOPY
Date: Thu, 31 Aug 2017 19:10:09 -0700
Message-ID: <20170901021007.pkbb2gsipbprf4w7@ast-mbp>
References: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36329 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdIACKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 22:10:13 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so839769pgb.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 19:10:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 05:00:13PM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Documentation for this feature was missing from the patchset.
> Copied a lot from the netdev 2.1 paper, addressing some small
> interface changes since then.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
...
> +Notification Batching
> +~~~~~~~~~~~~~~~~~~~~~
> +
> +Multiple outstanding packets can be read at once using the recvmmsg
> +call. This is often not needed. In each message the kernel returns not
> +a single value, but a range. It coalesces consecutive notifications
> +while one is outstanding for reception on the error queue.
> +
> +When a new notification is about to be queued, it checks whether the
> +new value extends the range of the notification at the tail of the
> +queue. If so, it drops the new notification packet and instead increases
> +the range upper value of the outstanding notification.

Would it make sense to mention that max notification range is 32-bit?
So each 4Gbyte of xmit bytes there will be a notification.
In modern 40Gbps NICs it's not a lot. Means that there will be
at least one notification every second.
Or I misread the code?

Thanks for the doc!

Acked-by: Alexei Starovoitov <ast@kernel.org>
