From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: BROKEN Re: [PATCH] netlink: 2-clause nla_ok()
Date: Mon, 05 Dec 2016 16:09:13 +0100
Message-ID: <1480950553.31788.40.camel@sipsolutions.net>
References: <CACVxJT9Qc=vNexx4ooQVFo=SrGs4-oHeZrnL18vbiS+o0F_N1A@mail.gmail.com>
         (sfid-20161205_155731_995936_F14B01DF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43554 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbcLEPJS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 10:09:18 -0500
In-Reply-To: <CACVxJT9Qc=vNexx4ooQVFo=SrGs4-oHeZrnL18vbiS+o0F_N1A@mail.gmail.com> (sfid-20161205_155731_995936_F14B01DF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Maybe someone could vouch that other checks prevent
> this kind of situation from happening but not me.

No, now that you spell it out (and I see the patch) - this is
absolutely needed because nla_for_each_attr() [1] can be called on
arbitrary data coming from userspace in a message, e.g. by way
of nla_for_each_nested(). Even if it's not malformed, nla_ok() is the
only abort condition for that loop, so it would read at least one
nla_len after the real buffer without that condition.

johannes

[1] which seems to be the only significant user thereof
