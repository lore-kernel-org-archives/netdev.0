From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Fri, 1 May 2015 11:46:19 +0200
Message-ID: <20150501094619.GA22481@breakpoint.cc>
References: <5542CC25.8060501@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41091 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751604AbbEAJqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 05:46:21 -0400
Content-Disposition: inline
In-Reply-To: <5542CC25.8060501@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/30/15 17:16, Alexei Starovoitov wrote:
> >On Thu, Apr 30, 2015 at 12:12:00PM +0200, Florian Westphal wrote:
> >>Not used.
> >>
> >>pedit sets TC_MUNGED when packet content was altered, but all the core
> >>does is unset MUNGED again and then set OK2MUNGE.
> >>
> >>And the latter isn't tested anywhere. So lets remove both
> >>TC_MUNGED and TC_OK2MUNGE.
> >>
> >>Signed-off-by: Florian Westphal <fw@strlen.de>
> >
> >Wanted to do the same.
> >iproute2 doesn't use 'munge' flag either.
> >
> >Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> >
> 
> Florian,
> If you are going to take this path then fix pedit to do a pskb_expand.

Jamal, what about this:

- I'll wait for this patch to be accepted or rejected
- same for your suggested rttl removal patch to go in

After that I will then send out all my pending tc_verd patches.

As for pedit, my suggestion would be to use skb_make_writeable(),
something like.... (untested):

-                       ptr = skb_header_pointer(skb, off + offset, 4, &_data);
-                       if (!ptr)
+                       if (!skb_make_writable(skb, off + offset + 4))
                                goto bad;
+
+                       ptr = skb->data + off + offset;
+

Does that sound ok?  I can send a followup patch to take care of pedit.

[ I'd first move skb_make_writeable out of netfilter core, of course ]

> I think it would be better to fix the actions that do
> pskb_expand_head() and let them indicated they were munged.

I don't think 'i was munged' flag is needed, the helper should
do on-demand copy if needed to get us exclusive access.

Thanks Jamal.
