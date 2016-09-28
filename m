From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 14:27:03 +0300
Message-ID: <20160928112703.GW1876@uranus.lan>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
 <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34705 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752809AbcI1L1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:27:07 -0400
Content-Disposition: inline
In-Reply-To: <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 07:06:26AM -0400, Jamal Hadi Salim wrote:
> > 
> > This structure is uapi, so anyone has complete rights to reference
> > @pad in the userspace programs. Sure it would be more clear to remove
> > the @pad completely, but if we choose so I think it's better to do
> > on top instead and then if someone complain we can easily revert
> > the single trivial commit instead of this big patch.
> 
> I am conflicted.
> A field labelled "pad" does not appear to be valid as "UAPI". It is
> a cosmetic indicator. If you did sizeof() with or without it being
> present the value doesnt change.

I think you miss the point what I'm trying to say: currently end-user
may have reference to this member (for any reason) and his program
will compile and run. If we change the name the compilation procedure
fails and this will break API. Yes, referrning @pad is bad idea for
userspace code, and yes (!) better to simply rename it but lets do
that later, on top, so that if we break something in userspace
we could easily revert the oneline change.

> BTW: There is at least one major structure in inet diag has a hole
> today and doesnt have a padding indicator.
> 
> > If protocol goes over u8 then complete inet_diag_req_v2 structure will
> > have to be reworked becaue @sdiag_protocol is u8 as well. IOW, once
> > someone liftup IPPROTO_MAX > 255, he will notice the problem immediately
> > because diag for such module simply stop working properly.
> > 
> 
> ok.
> 
> cheers,
> jamal
> 

	Cyrill
