From: Willy Tarreau <w@1wt.eu>
Subject: Re: [ANNOUNCE] ndiv: line-rate network traffic processing
Date: Wed, 21 Sep 2016 20:06:59 +0200
Message-ID: <20160921180659.GC1640@1wt.eu>
References: <20160921112852.GA991@1wt.eu>
 <CALx6S34Oy6QeOxR45PuuX70hfm-TR=2mpDwwqr82c7tvpWLX+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:10651 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932340AbcIUSHC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 14:07:02 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S34Oy6QeOxR45PuuX70hfm-TR=2mpDwwqr82c7tvpWLX+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, Sep 21, 2016 at 10:16:45AM -0700, Tom Herbert wrote:
> This does seem interesting and indeed the driver datapath looks very
> much like XDP. It would be quite interesting if you could rebase and
> then maybe look at how this can work with XDP that would be helpful.

OK I'll assign some time to rebase it then.

> The return actions are identical,

I'm not surprized that the same needs lead to the same designs when
these designs are constrained by CPU cycle count :-)

> but processing descriptor meta data
> (like checksum, vlan) is not yet implemented in XDP-- maybe this is
> something we can leverage from ndiv?

Yes possibly. It's not a big work but it's absolutely mandatory if you
don't want to waste some smart devices' valuable performance improvements.
We changed our API when porting it to ixgbe to support what this NIC (and
many other ones) supports so that the application code doesn't have to
deal with checksums etc. By the way, VLAN is not yet implemented in the
mvneta driver. But this choice ensures that no application has to deal
nor to create bugs.

Cheers,
Willy
