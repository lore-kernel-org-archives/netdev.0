From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 13:17:26 +0300
Message-ID: <20160928101726.GU1876@uranus.lan>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
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
In-Reply-To: <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2016 at 06:08:00AM -0400, Jamal Hadi Salim wrote:
...
> > @@ -38,7 +38,10 @@ struct inet_diag_req_v2 {
> >  	__u8	sdiag_family;
> >  	__u8	sdiag_protocol;
> >  	__u8	idiag_ext;
> > -	__u8	pad;
> > +	union {
> > +		__u8	pad;
> > +		__u8	sdiag_raw_protocol;	/* SOCK_RAW only, @pad for others */
> > +	};
> 
> 
> Above looks funny. Why is it a union? pad is for exposing a byte-hole
> for padding/alignment reasons and i doubt anybody is using it.

Someone may have set it to zero explicitly on source level, and the
compilation will fail on new kernel then. So no, keeping the name
is reasonable.

> Should you not just rename it?
> Also I notice when things like __raw_v4_lookup() are claiming it is unsigned
> short instead of a u8?

The protocol is still up to 255 for a while, is it expected that IPPROTO_MAX
will be increased in more-less near future? Of course I can drop the idea
of using @pad here and switch to some extended reauest but prefer to stick
with simplier solution. Hm?
