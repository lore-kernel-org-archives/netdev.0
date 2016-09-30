From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Thu, 29 Sep 2016 17:06:30 -0700
Message-ID: <1475193990.28155.192.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com>
         <1475112246.28155.122.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA3=++_6O69hcutQ_FmaivrR3UV-uKScyX8+iHOBV9kraizOFQ@mail.gmail.com>
         <3897844.9kvF4Wy8aS@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Smith <jay@kentik.com>, Alan Curry <rlwinm@sdf.org>,
        netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36701 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935165AbcI3AGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 20:06:33 -0400
Received: by mail-pf0-f176.google.com with SMTP id q2so33791241pfj.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 17:06:33 -0700 (PDT)
In-Reply-To: <3897844.9kvF4Wy8aS@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-30 at 01:28 +0200, Christian Lamparter wrote:
> On Wednesday, September 28, 2016 7:20:39 PM CEST Jay Smith wrote:
> > Actually, on a little more searching of this list's archives, I think
> > that this discussion:  https://patchwork.kernel.org/patch/9260733/ is
> > about exactly the same issue I've found, except from the TCP side. I'm
> > cc'ing a few of the participants from that discussion.
> > 
> > So is the patch proposed there (copying and restoring the entire
> > iov_iter in skb_copy_and_csum_datagram_msg()) being considered as a
> > fix?
> 
> From Alan's post:
> 
> "My ugly patch fixes this in the most obvious way: make a local copy of
> msg->msg_iter before the call to skb_copy_and_csum_datagram(), and copy
> it back if the checksum is bad, just before goto csum_error;"
> 
> IMHO this meant that the patch is a proof of concept for his problem.
> 
> > If not, would an alternate one that concealed the save-and-restore logic
> > inside iov_iter.c be more acceptable? I'd be happy to produce whatever's
> > needed, or yield to someone with stronger feelings about where it should
> > go...
> Al Viro identified more inconsistencies within the error-paths that deal
> with EFAULT in the whole area (in and around skb_copy_and_csum_datagram()).
> 
> As far as I can tell the original discussion about the data corruption
> issue went off on a tangent and it is stuck in figuring out "How to handle
> the errors in tcp_copy_to_iovec()".
> 
> As for fixing the issue: I'm happy to test and review patches. 
> The trouble is that nobody seem to be able to produce them...
> 

This is doable with a bit of fault injection I believe.

And "ethtool -K eth0 rx off gro off lro off"  to let the TCP receiver
compute the checksum itself.
