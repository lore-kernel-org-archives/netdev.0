From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 27 Sep 2016 10:48:12 +0300
Message-ID: <20160927074812.GM1876@uranus.lan>
References: <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
 <20160916193927.GB18116@uranus.lan>
 <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
 <20160916195252.GC18116@uranus.lan>
 <6464ac16-a15b-384e-ffb1-3ee84cdce313@cumulusnetworks.com>
 <20160916200722.GA26044@uranus.lan>
 <20160920211343.GI26044@uranus.lan>
 <20160926223828.GL1876@uranus.lan>
 <fd77837c-433c-5010-7d07-68b0bf3e3d22@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36315 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbcI0HsQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:48:16 -0400
Content-Disposition: inline
In-Reply-To: <fd77837c-433c-5010-7d07-68b0bf3e3d22@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 07:54:37PM -0600, David Ahern wrote:
> On 9/26/16 4:38 PM, Cyrill Gorcunov wrote:
> > Something like
> > 
> > Index: linux-ml.git/include/uapi/linux/inet_diag.h
> > ===================================================================
> > --- linux-ml.git.orig/include/uapi/linux/inet_diag.h    2016-09-11 20:56:18.191584145 +0300
> > +++ linux-ml.git/include/uapi/linux/inet_diag.h 2016-09-27 01:34:08.413172394 +0300
> > @@ -38,7 +38,7 @@ struct inet_diag_req_v2 {
> >         __u8    sdiag_family;
> >         __u8    sdiag_protocol;
> >         __u8    idiag_ext;
> > -       __u8    pad;
> > +       __u8    sdiag_raw_protocol;     /* SOCK_RAW only, @pad for others */
> 
> Seems like that should be a union to keep the API.

Is anonymous union (which is not part of c99) are acceptable in uapi?
Initially I declared it as union but then scratched my head if this
would be acceptable.

> 
> 
> >         __u32   idiag_states;
> >         struct inet_diag_sockid id;
> >  };
> > 
> > and in raw-diag module we will use @sdiag_raw_protocol instead of
> > @sdiag_protocol field. Didn't cover ss tool source code yet but
> > I think the idea is seen. Still not sure if start using @pad here
> > is a good idea (it's uapi), maybe beter to ask nla attribute which would
> > come right afterh the inet_diag_req_v2 message?
> > 
> 
> seems reasonable to me since 2 protocols need to be sent to the kernel.
> 
> Alternatively, sdiag_protocol could be the actual protocol and the pad union be a flag field
> with say bit 0 = INET_DIAG_FLAG_SOCK_RAW. Allows other overrides in the future if needed.

The @sdiag_protocol used for matching in diag module handler, so no, I think
we should not change this semantics. I would stick with @pad usage and if
anonymous unions are acceptable this would be just great.

	Cyrill
