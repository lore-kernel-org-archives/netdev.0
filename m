From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 22 Sep 2016 11:54:11 +0200
Message-ID: <20160922095411.GA5654@pox.localdomain>
References: <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia>
 <20160921184827.GA15732@pox.localdomain>
 <20160922092138.GA12108@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38870 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757107AbcIVJyO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:54:14 -0400
Received: by mail-wm0-f44.google.com with SMTP id l132so138322154wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 02:54:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160922092138.GA12108@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/16 at 11:21am, Pablo Neira Ayuso wrote:
> I have a hard time to buy this new specific hook, I think we should
> shift focus of this debate, this is my proposal to untangle this:
> 
> You add a net/netfilter/nft_bpf.c expression that allows you to run
> bpf programs from nf_tables. This expression can either run bpf
> programs in a similar fashion to tc+bpf or run the bpf program that
> you have attached to the cgroup.

So for every packet processed, you want to require the user to load
and run a (unJITed) nft program acting as a wrapper to run a JITed
BPF program? What it the benefit of this model compared to what Daniel
is proposing? The hooking point is the same. This only introduces
additional per packet overhead in the fast path. Am I missing something?
