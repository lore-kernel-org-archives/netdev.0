From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next] bonding: do not pass link-local packets to master-interface
Date: Fri, 14 Apr 2017 22:26:36 +0200
Message-ID: <CAHo-OoxPWyYJ+Zn37S9+uQHiDksnE8KZNsCkHSPND4A8uqWU4g@mail.gmail.com>
References: <20170414180022.124453-1-chonggangli@google.com> <2810.1492198224@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chonggang Li <chonggangli@google.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33611 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753574AbdDNU0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 16:26:37 -0400
Received: by mail-yw0-f172.google.com with SMTP id l189so38851184ywb.0
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 13:26:37 -0700 (PDT)
In-Reply-To: <2810.1492198224@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         In what case is the current behavior a problem (my guess would
> be something related to LLDP)?

LLDP is indeed the case we're trying to solve here.
Listen on one socket and get LLDP for all interfaces in the system.

>  What if, e.g., the bond is a bridge
> port, will STP frames no longer propagate to the bridge?

That's an interesting question.
I don't actually know how this should work.

Should this change perhaps only apply to packets we would otherwise
RX_HANDLER_EXACT?

ie. only affect link local packets on inactive slaves?
but continue reparenting link local packets on active slaves?

That would seem a little inconsistent... but less of a change.
