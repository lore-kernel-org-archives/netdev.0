From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Mon, 17 Apr 2017 15:49:55 -0400 (EDT)
Message-ID: <20170417.154955.1624611510140672627.davem@davemloft.net>
References: <20170414153032.2b3e1a5c@cakuba.lan>
        <20170415004642.GA73685@ast-mbp.thefacebook.com>
        <20170416222601.671f037c@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752527AbdDQTt5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:49:57 -0400
In-Reply-To: <20170416222601.671f037c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Sun, 16 Apr 2017 22:26:01 +0200

> The bpf tail-call use-case is a very good example of why the
> verifier cannot deduct the needed HEADROOM upfront.

This brings up a very interesting question for me.

I notice that tail calls are implemented by JITs largely by skipping
over the prologue of that destination program.

However, many JITs preload cached SKB values into fixed registers in
the prologue.  But they only do this if the program being JITed needs
those values.

So how can it work properly if a program that does not need the SKB
values tail calls into one that does?

Daniel, Alexei?
