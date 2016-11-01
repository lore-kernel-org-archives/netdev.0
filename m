From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Wed, 2 Nov 2016 00:25:15 +0900
Message-ID: <CAKD1Yr02SCHvd-xZJL14d_Ta8Dk4evHZ60zytpU0h4r80FucwA@mail.gmail.com>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia> <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
 <CAKD1Yr2aRDNUxX8onReZyURufphxGoSTek=Fjk3Wswq9WOVp4w@mail.gmail.com>
 <20161029045107.GA61294@ast-mbp.thefacebook.com> <CAKD1Yr2pMk52h7BdRwTvGwnP5+ONmr4ac6cyUBoZ9P+Kt-B8jw@mail.gmail.com>
 <20161029062442.GA61550@ast-mbp.thefacebook.com> <CAKD1Yr3QfL-biSjQfFgzjMFNoLV7FP9DSB=KNbp+_KyxyQmVMg@mail.gmail.com>
 <581506C4.30902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Mack <daniel@zonque.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>, htejun@fb.com,
        ast@fb.com, David Miller <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>, harald@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>, cgroups@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35948 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbcKAPZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:25:38 -0400
Received: by mail-qt0-f182.google.com with SMTP id w33so54234905qtc.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:25:37 -0700 (PDT)
In-Reply-To: <581506C4.30902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 30, 2016 at 5:29 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Fwiw, not sure if swapping brings much, even after netfilter there could
> be complex processing that would potentially drop, mangle, redirect, etc
> from tc layer (egress or from qdisc itself). But also at even lower layers

I agree lots of stuff can still happen after the netfilter hooks have
finished. But it seems to me that netfilter hooks are more flexible
and have more access to more data (L2 headers, output devices,
conntrack state entries, etc. etc.) than this hook. So it seems to me
that this hook would be more useful if it ran after netfilter on
egress.

That way, if you want to modify the packet or do something
sophisticated in netfilter, you can still use the eBPF hook on the
results of that operation, and if you don't want to run netfilter, you
can write netfilter rules to skip the packet (and maybe still fix it
up later, perhaps in another netfilter chain).
