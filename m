From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 13:51:47 +0300
Message-ID: <20160928105147.GV1876@uranus.lan>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2016 at 06:43:01AM -0400, Jamal Hadi Salim wrote:
...
> > 
> > Someone may have set it to zero explicitly on source level, and the
> > compilation will fail on new kernel then. So no, keeping the name
> > is reasonable.
> > 
> 
> I dont know how compilation will fail but you may be right with note:
> that is not how pads have been used in the past. They are supposed to
> cosmetic annotation which indicates "here's a hole; use it in the
> future if you are looking to add something". And someone in the
> future can claim them. I am not sure if MBZ philosophy applies.

This structure is uapi, so anyone has complete rights to reference
@pad in the userspace programs. Sure it would be more clear to remove
the @pad completely, but if we choose so I think it's better to do
on top instead and then if someone complain we can easily revert
the single trivial commit instead of this big patch.

> 
> > > Should you not just rename it?
> > > Also I notice when things like __raw_v4_lookup() are claiming it is unsigned
> > > short instead of a u8?
> > 
> > The protocol is still up to 255 for a while, is it expected that IPPROTO_MAX
> > will be increased in more-less near future? Of course I can drop the idea
> > of using @pad here and switch to some extended reauest but prefer to stick
> > with simplier solution. Hm?
> > 
> 
> Ok. If i understood correctly it was already unsigned short before your
> patch -so i agree it doesnt matter. Maybe just put a comment to express
> that if ever protocol goes above 255 it wont be sufficient.

If protocol goes over u8 then complete inet_diag_req_v2 structure will
have to be reworked becaue @sdiag_protocol is u8 as well. IOW, once
someone liftup IPPROTO_MAX > 255, he will notice the problem immediately
because diag for such module simply stop working properly.
