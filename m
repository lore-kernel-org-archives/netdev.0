From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: [PATCH] IPSec: IPv6 source address not set correctly in xfrm_state
Date: Fri, 21 Mar 2003 10:47:22 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF9166000.BEACA87E-ON86256CF0.005ABF8E-86256CF0.005C3A7A@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> >                      atomic_inc(&x0->refcnt);
> >          } else if (create && (x0 = xfrm_state_alloc()) != NULL) {
> > -                    memcpy(x0->sel.daddr.a6, daddr, sizeof(struct
in6_addr));
> > -                    memcpy(x0->sel.saddr.a6, saddr, sizeof(struct
in6_addr));
> > +                    memcpy(&x0->sel.daddr.a6, daddr, sizeof(struct
in6_addr));
> > +                    memcpy(&x0->sel.saddr.a6, saddr, sizeof(struct
in6_addr));
> >                      x0->sel.prefixlen_d = 128;
> >                      x0->sel.prefixlen_s = 128;
> > -                    memcpy(x0->props.saddr.a6, saddr, sizeof(struct
in6_addr));
> > +                    memcpy(&x0->props.saddr.a6, saddr, sizeof(struct
in6_addr));
> >                      x0->km.state = XFRM_STATE_ACQ;
> > -                    memcpy(x0->id.daddr.a6, daddr, sizeof(struct
in6_addr));
> > +                    memcpy(&x0->id.daddr.a6, daddr, sizeof(struct
in6_addr));
> >                      x0->id.proto = proto;
> >                      x0->props.family = AF_INET6;
> >                      x0->props.mode = mode;

> these are not correct.

Ok, I see, because "a6" is defined as an array.  Maybe all of the memcpy's
should be the same (include the .a6 or don't include the .a6) so that it is
consistent in the code?

David, would you like me to resubmit the patch or do you just want to
remove the last part of it?

Thanks,
Tom
