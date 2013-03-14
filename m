From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Thu, 14 Mar 2013 08:14:08 +0100
Message-ID: <20130314071408.GB4129@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130313012715.GE14801@order.stressinduktion.org> <1363152568.13690.35.camel@edumazet-glaptop> <20130314013702.GA4129@order.stressinduktion.org> <CAOaVG148gUzcb2qmg0B7kdWNzNzerMdXZzv2qamXq8ToUFsUyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, brouer@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34311 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab3CNHOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 03:14:10 -0400
Content-Disposition: inline
In-Reply-To: <CAOaVG148gUzcb2qmg0B7kdWNzNzerMdXZzv2qamXq8ToUFsUyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 09:36:52PM -0700, Stephen Hemminger wrote:
> > +#define INET_FRAG_FIND_CHECK(val)                                      \
> > +       ({                                                              \
> > +               static const char ___mem[] =                            \
> > +                       KERN_ERR pr_fmt(                                \
> > +                               "inet_frag_find: No memory left."       \
> > +                               " Dropping fragment.\n");               \
> > +               static const char ___limit[] =                          \
> > +                       KERN_WARNING pr_fmt(                            \
> > +                               "inet_frag_find: Fragment hash bucket"  \
> > +                               " list length grew above limit "        \
> > +                               __stringify(INETFRAGS_MAXDEPTH)         \
> > +                               ". Dropping fragment.\n");              \
> > +               bool ___b = true;                                       \
> > +               if (IS_ERR_OR_NULL(val)) {                              \
> > +                       ___b = false;                                   \
> > +                       if (PTR_ERR(val) == -ENOBUFS)                   \
> > +                               LIMIT_NETDEBUG(___limit);               \
> > +                       else                                            \
> > +                               LIMIT_NETDEBUG(___mem);                 \
> > +               }                                                       \
> > +               ___b;                                                   \
> > +       })
> > +
> 
> Big macros suck, write it as an inline function or better yet a real function.

I switched to the macro to have string expansion with pr_fmt. So it is visible
from the dmesg if IPv4, IPv6 or IPv6-nf did generate the message. This could
be done with a function, too, but would require a bit more string handling.
