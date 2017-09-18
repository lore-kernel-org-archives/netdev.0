From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: drop packets where gso_size is too big for
 hardware
Date: Mon, 18 Sep 2017 07:42:55 -0700
Message-ID: <1505745775.29839.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831054642.13721-1-dja@axtens.net>
         <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <87fubkehyo.fsf@linkitivity.dja.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, jay.vosburgh@canonical.com
To: Daniel Axtens <dja@axtens.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:46325 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754600AbdIROnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 10:43:00 -0400
Received: by mail-pf0-f170.google.com with SMTP id e199so341787pfh.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 07:43:00 -0700 (PDT)
In-Reply-To: <87fubkehyo.fsf@linkitivity.dja.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-18 at 14:41 +1000, Daniel Axtens wrote:
> Hi Eric,
...
> So I've been experimenting with this and reading through the core
> networking code. If my understanding is correct, disabling GSO will
> cause the packet to be segmented, but it will be segemented into
> gso_size+header length packets. So in this case (~10kB gso_size) the
> resultant packets will still be too big - although at least they don't
> cause a crash in that case.

You describe a bug in core networking stack then.

When we perform software segmentation, we must do the check against
route mtu, and drop the offending frame, and send an ICMP back
eventually.
