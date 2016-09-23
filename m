From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 19:37:25 +0100
Message-ID: <20160923183725.GC1041@n2100.armlinux.org.uk>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <20160923173751.GA1041@n2100.armlinux.org.uk>
 <d0d6f333-c6fc-6572-0633-d7c2c29b8b3f@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        Simone <cjb.sw.nospam@gmail.com>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:53356 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035314AbcIWShf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 14:37:35 -0400
Content-Disposition: inline
In-Reply-To: <d0d6f333-c6fc-6572-0633-d7c2c29b8b3f@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 11:26:18AM -0700, Eric Nelson wrote:
> So the question is: should we just live with this and acknowledge a
> performance penalty of bad alignment or do something about it?

Well, I've no interest in trying to do anything with the FEC driver
anymore, as I'll just generate another big patch stack which won't
make it into the kernel in a timely fashion - my last attempt at
improving the FEC driver was dogged with conflicting changes and I
gave up with it in the end.  I ended up spending a full cycle
rebasing, re-testing, and re-evaluating their performance only to find
that I'd missed the merge window again, and other conflicting changes
got merged which meant that I had to start from the beginning again.

> I'm not sure the cost (or the details) of Eric's proposed fix of allocating
> and copying the header to another skb.

I had a quick look at this, and although Eric's idea may be a good
idea, it doesn't contain enough details for me to be able to
implement it - eg, I've no idea how to attach the 128-byte skb to the
beginning of a previously allocated skb containing the rest of the
packet.  I've just looked through linux/skbuff.h and I can't see
anything that takes two sk_buff's that would do the job.

However, I don't think that's necessary in this case, because the
iMX6 FEC supports the 16-bit alignment of the packet, if only it was
enabled in hardware and the driver caters for it.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
