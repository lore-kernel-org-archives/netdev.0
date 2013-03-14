From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Wed, 13 Mar 2013 21:36:52 -0700
Message-ID: <CAOaVG148gUzcb2qmg0B7kdWNzNzerMdXZzv2qamXq8ToUFsUyw@mail.gmail.com>
References: <20130307214211.GP7941@order.stressinduktion.org>
	<20130308055718.GA28531@order.stressinduktion.org>
	<20130308130433.GB28531@order.stressinduktion.org>
	<1362754386.15793.226.camel@edumazet-glaptop>
	<20130308150831.GD28531@order.stressinduktion.org>
	<1362756219.15793.240.camel@edumazet-glaptop>
	<20130313012715.GE14801@order.stressinduktion.org>
	<1363152568.13690.35.camel@edumazet-glaptop>
	<20130314013702.GA4129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:51782 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab3CNEgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 00:36:53 -0400
Received: by mail-vc0-f171.google.com with SMTP id ha11so77430vcb.2
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 21:36:52 -0700 (PDT)
In-Reply-To: <20130314013702.GA4129@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define INET_FRAG_FIND_CHECK(val)                                      \
> +       ({                                                              \
> +               static const char ___mem[] =                            \
> +                       KERN_ERR pr_fmt(                                \
> +                               "inet_frag_find: No memory left."       \
> +                               " Dropping fragment.\n");               \
> +               static const char ___limit[] =                          \
> +                       KERN_WARNING pr_fmt(                            \
> +                               "inet_frag_find: Fragment hash bucket"  \
> +                               " list length grew above limit "        \
> +                               __stringify(INETFRAGS_MAXDEPTH)         \
> +                               ". Dropping fragment.\n");              \
> +               bool ___b = true;                                       \
> +               if (IS_ERR_OR_NULL(val)) {                              \
> +                       ___b = false;                                   \
> +                       if (PTR_ERR(val) == -ENOBUFS)                   \
> +                               LIMIT_NETDEBUG(___limit);               \
> +                       else                                            \
> +                               LIMIT_NETDEBUG(___mem);                 \
> +               }                                                       \
> +               ___b;                                                   \
> +       })
> +

Big macros suck, write it as an inline function or better yet a real function.
