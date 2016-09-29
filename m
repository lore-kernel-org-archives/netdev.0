From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Fri, 30 Sep 2016 01:28:18 +0200
Message-ID: <3897844.9kvF4Wy8aS@debian64>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com> <1475112246.28155.122.camel@edumazet-glaptop3.roam.corp.google.com> <CAA3=++_6O69hcutQ_FmaivrR3UV-uKScyX8+iHOBV9kraizOFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jay Smith <jay@kentik.com>, Alan Curry <rlwinm@sdf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35784 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752523AbcI2X2V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 19:28:21 -0400
Received: by mail-wm0-f67.google.com with SMTP id b4so971169wmb.2
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 16:28:20 -0700 (PDT)
In-Reply-To: <CAA3=++_6O69hcutQ_FmaivrR3UV-uKScyX8+iHOBV9kraizOFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, September 28, 2016 7:20:39 PM CEST Jay Smith wrote:
> Actually, on a little more searching of this list's archives, I think
> that this discussion:  https://patchwork.kernel.org/patch/9260733/ is
> about exactly the same issue I've found, except from the TCP side. I'm
> cc'ing a few of the participants from that discussion.
> 
> So is the patch proposed there (copying and restoring the entire
> iov_iter in skb_copy_and_csum_datagram_msg()) being considered as a
> fix?

>From Alan's post:

"My ugly patch fixes this in the most obvious way: make a local copy of
msg->msg_iter before the call to skb_copy_and_csum_datagram(), and copy
it back if the checksum is bad, just before goto csum_error;"

IMHO this meant that the patch is a proof of concept for his problem.

> If not, would an alternate one that concealed the save-and-restore logic
> inside iov_iter.c be more acceptable? I'd be happy to produce whatever's
> needed, or yield to someone with stronger feelings about where it should
> go...
Al Viro identified more inconsistencies within the error-paths that deal
with EFAULT in the whole area (in and around skb_copy_and_csum_datagram()).

As far as I can tell the original discussion about the data corruption
issue went off on a tangent and it is stuck in figuring out "How to handle
the errors in tcp_copy_to_iovec()".

As for fixing the issue: I'm happy to test and review patches. 
The trouble is that nobody seem to be able to produce them...

Regards,
Christian
