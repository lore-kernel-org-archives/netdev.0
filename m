From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 14:39:02 -0700
Message-ID: <1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	 <20140422.235745.1219194947074686642.davem@davemloft.net>
	 <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	 <20140423.125043.100674358164503915.davem@davemloft.net>
	 <CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56597 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaDWVjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:39:05 -0400
Received: by mail-pd0-f169.google.com with SMTP id y13so256925pdi.14
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 14:39:04 -0700 (PDT)
In-Reply-To: <CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-23 at 13:38 -0700, Alexei Starovoitov wrote:

> In this particular case we can indeed make verifier smarter to the point
> that once it detects uninitialized A/X in a filter, it will add explicit init
> after conversion, so we don't have to pay the penalty at run time.
> It's a very good suggestion.
> 
> At the same time I think 'ret A' falls into category of the 20 year old bug.
> The filters that using undocumented behavior are destined to be
> broken sooner or later. tcpdump doesn't generate such filters.
> Valid filters will not be affected by strict checking, but I think users
> will be actually happy to see kernel rejecting their buggy filters.
> I think we can have a global flag for bpf verifier whether to reject
> such filters or accept them by adding explicit inits under
> 'bpf_permissive_loading' flag.
> Thoughts?


I do not really understand the concerns and this discussion over this
bug.

BPF JIT does basic checks and forces A=0 if first instruction doesn't
set A.

( arch/x86/net/bpf_jit_comp.c line 263 )

X is forced to 0 anyway if X is ever used in the JITed filter.
( line 227, and we have a typo in comment : s/leek/leak/ )

This is not a big deal. If you want to 'optimize', fine, but don't break
programs.

There is no way you add a 'flag' to break a user program, even
if _you_ believe its broken.

Maybe it assumed initial X / A contents were 0.

Even if not documented, we cannot break this 20 years after the facts.
