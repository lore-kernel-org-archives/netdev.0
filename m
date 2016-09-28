From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 15:18:33 +0300
Message-ID: <20160928121833.GX1876@uranus.lan>
References: <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
 <20160928112703.GW1876@uranus.lan>
 <20160928.080701.1194277590163223525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160928.080701.1194277590163223525.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2016 at 08:07:01AM -0400, David Miller wrote:
...
> > 
> > I think you miss the point what I'm trying to say: currently end-user
> > may have reference to this member (for any reason) and his program
> > will compile and run. If we change the name the compilation procedure
> > fails and this will break API. Yes, referrning @pad is bad idea for
> > userspace code, and yes (!) better to simply rename it but lets do
> > that later, on top, so that if we break something in userspace
> > we could easily revert the oneline change.
> 
> Right, it would be legal for an existing user to have code that
> explicitly initializes every member of the structure, including 'pad'.
> So we have to keep that member around, at a minimum, for their sake.

+1

> 
> >> BTW: There is at least one major structure in inet diag has a hole
> >> today and doesnt have a padding indicator.
> >> 
> >> > If protocol goes over u8 then complete inet_diag_req_v2 structure will
> >> > have to be reworked becaue @sdiag_protocol is u8 as well. IOW, once
> >> > someone liftup IPPROTO_MAX > 255, he will notice the problem immediately
> >> > because diag for such module simply stop working properly.
> 
> Indeed, we need a 16-bit value here.

Yes, and we will need inet_diag_req_v3 for this sake ;) I think
we can even introduce it early and convert _v2 to _v3 transparently
inside kernel. I could start working on such change if people agreed
(but a bit latter, on the next week probably)
