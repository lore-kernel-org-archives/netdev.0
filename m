From: Daniel Axtens <dja@axtens.net>
Subject: Re: [PATCH] bnx2x: drop packets where gso_size is too big for hardware
Date: Fri, 01 Sep 2017 12:42:41 +1000
Message-ID: <87a82f3zry.fsf@linkitivity.dja.id.au>
References: <20170831054642.13721-1-dja@axtens.net> <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, jay.vosburgh@canonical.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36412 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdIACmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 22:42:46 -0400
Received: by mail-pf0-f181.google.com with SMTP id r187so4118625pfr.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 19:42:46 -0700 (PDT)
In-Reply-To: <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> If you had this test in bnx2x_features_check(), packet could be
> segmented by core networking stack before reaching bnx2x_start_xmit() by
> clearing NETIF_F_GSO_MASK
>
> -> No drop would be involved.

Thanks for the pointer - networking code is all a bit new to me.

I'm just struggling at the moment to figure out what the right way to
calculate the length. My original patch uses gso_size + hlen, but:

 - On reflection, while this solves the immediate bug, I'm not 100% sure
   this is the right thing to be calculating

 - If it is, then we have the problem that hlen is calculated in a bunch
   of weird and wonderful ways which make it a nightmare to extract.

Yuval (or anyone else who groks the driver properly) - what's the right
test to be doing here to make sure we don't write to much data to the
card?

Regards,
Daniel
