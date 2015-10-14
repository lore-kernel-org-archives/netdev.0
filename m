From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next v5 01/10] qed: Add module with basic common
 support
Date: Wed, 14 Oct 2015 04:47:31 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E47ACC@avmb3.qlogic.org>
References: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>
 <20151012230750.GA7378@electric-eye.fr.zoreil.com>
 <B5657A6538887040AD3A81F1008BEC63E467D6@avmb3.qlogic.org>
 <20151013215429.GA4378@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46127 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbbJNErg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 00:47:36 -0400
In-Reply-To: <20151013215429.GA4378@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yuval Mintz <Yuval.Mintz@qlogic.com> :
> [...]
> > > > +struct qed_simd_fp_handler {
> > > > +     void    *token;
> > > > +     void    (*func)(void *);
> > > > +};
> > > Use union * ?
> > The token is a cookie to be used by a func, so union isn't appropriate.
> 
> Lets' reformulate: replace 'void * token' by 'union foobar *token'.
> 
> void * silents compiler. union * doesn't.

Not sure I get you here - this hander is used for registering interrupt handlers
in case INTa is used, and multiple modules [both QED and the appropriate
protocol driver] need to use it.
Turning this into an explicit union would require QED to be familiar with the
ISR cookies of all the various protocol drivers. While possible, it'll create
additional .h dependencies between those in a direction that currently doesn't
exist [I.e., QED would have to include protocol driver .h for it].

> 
> [...]
> > > > +             rc = -ENOMEM;
> > > > +             goto ilt_shadow_fail;
> > > > +     } else {
> > > > +             DP_VERBOSE(p_hwfn, QED_MSG_ILT,
> > > > +                        "Allocated 0x%x bytes for ilt shadow\n",
> > > > +                        (u32)(size * sizeof(struct qed_dma_mem)));
> > > > +     }
> > > The "else" branch after the "goto" isn't idiomatic.
> > Not that I mind, but is such a prefernce described in any style-guide?
> 
> Documentation/CodingStyle gives some hints in its "goto" section but it doesn't
> specifically go that far. Is there a reward if I can exhumate some message on
> netdev where it would had already been outlined ?

Depends. Do you consider wasted time to be a reward? ;-)
