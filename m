From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Fri, 31 Mar 2017 08:24:01 -0700
Message-ID: <1490973841.8750.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
         <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFFC37E0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36641 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933112AbdCaPYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 11:24:03 -0400
Received: by mail-pg0-f44.google.com with SMTP id g2so73273863pge.3
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 08:24:02 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFC37E0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 15:03 +0000, David Laight wrote:

> Is that really sensible on systems with large cache lines?

Yes it is.

We mostly do our perf analysis on x86, and it turns out that linux
networking on PowerPC is not great because of this.

struct dst_entry is showing problems, simply because we aligned __refcnt
on 64 byte boundary, which is not enough on PowerPC.

With bigger cache lines, you have bigger chances of false sharing.
