From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] fq_codel: add per queue memory limit
Date: Wed, 01 Jun 2016 09:01:40 -0700
Message-ID: <1464796900.5939.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464791011.5939.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160601085340.4b3c84dc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33940 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbcFAQBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:01:44 -0400
Received: by mail-pf0-f175.google.com with SMTP id 62so17687389pfd.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:01:43 -0700 (PDT)
In-Reply-To: <20160601085340.4b3c84dc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-01 at 08:53 -0700, Stephen Hemminger wrote:
> On Wed, 01 Jun 2016 07:23:31 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +		} else if (strcmp(*argv, "memory_limit") == 0) {
> > +			NEXT_ARG();
> > +			if (get_size(&memory, *argv)) {
> > +				fprintf(stderr, "Illegal \"memory_limit\"\n");
> > +				return -1;
> > +			}
> 
> Do you really want to allow memory limit of 0?
> 

Why not ? If there is a kernel bug we need to fix it anyway ?

What would be the enforced 'minimum' ?

> 
> > +	if (tb[TCA_FQ_CODEL_MEMORY_LIMIT] &&
> > +	    RTA_PAYLOAD(tb[TCA_FQ_CODEL_MEMORY_LIMIT]) >= sizeof(__u32)) {
> > +		memory_limit = rta_getattr_u32(tb[TCA_FQ_CODEL_MEMORY_LIMIT]);
> > +
> > +		fprintf(f, "memory_limit %s ", sprint_size(memory_limit, b1));
> > +	}
> 
> Why the size check? other parameters don't do it?

Existing code style in tc/q_fq_codel.c

I really think all TLV consumers should never trust producers, even if
it is the kernel ;)
