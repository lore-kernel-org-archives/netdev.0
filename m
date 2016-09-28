From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:07:01 -0400 (EDT)
Message-ID: <20160928.080701.1194277590163223525.davem@davemloft.net>
References: <20160928105147.GV1876@uranus.lan>
        <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
        <20160928112703.GW1876@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: gorcunov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928112703.GW1876@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 28 Sep 2016 14:27:03 +0300

> On Wed, Sep 28, 2016 at 07:06:26AM -0400, Jamal Hadi Salim wrote:
>> > 
>> > This structure is uapi, so anyone has complete rights to reference
>> > @pad in the userspace programs. Sure it would be more clear to remove
>> > the @pad completely, but if we choose so I think it's better to do
>> > on top instead and then if someone complain we can easily revert
>> > the single trivial commit instead of this big patch.
>> 
>> I am conflicted.
>> A field labelled "pad" does not appear to be valid as "UAPI". It is
>> a cosmetic indicator. If you did sizeof() with or without it being
>> present the value doesnt change.
> 
> I think you miss the point what I'm trying to say: currently end-user
> may have reference to this member (for any reason) and his program
> will compile and run. If we change the name the compilation procedure
> fails and this will break API. Yes, referrning @pad is bad idea for
> userspace code, and yes (!) better to simply rename it but lets do
> that later, on top, so that if we break something in userspace
> we could easily revert the oneline change.

Right, it would be legal for an existing user to have code that
explicitly initializes every member of the structure, including 'pad'.
So we have to keep that member around, at a minimum, for their sake.

>> BTW: There is at least one major structure in inet diag has a hole
>> today and doesnt have a padding indicator.
>> 
>> > If protocol goes over u8 then complete inet_diag_req_v2 structure will
>> > have to be reworked becaue @sdiag_protocol is u8 as well. IOW, once
>> > someone liftup IPPROTO_MAX > 255, he will notice the problem immediately
>> > because diag for such module simply stop working properly.
>> > 
>> 
>> ok.

Indeed, we need a 16-bit value here.
