From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Wed, 14 Sep 2016 11:03:49 +0200
Message-ID: <20160914090349.GA11841@pox.localdomain>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <20160914044217.GA44742@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37048 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcINJEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 05:04:15 -0400
Received: by mail-wm0-f45.google.com with SMTP id c131so17472213wmh.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 02:03:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160914044217.GA44742@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Sorry for the repost, gmail decided to start sending HTML crap along
 overnight for some reason]

On 09/13/16 at 09:42pm, Alexei Starovoitov wrote:
> On Tue, Sep 13, 2016 at 07:24:08PM +0200, Pablo Neira Ayuso wrote:
> > Then you have to explain me how can anyone else than systemd use this
> > infrastructure?
> 
> Jokes aside. I'm puzzled why systemd is even being mentioned here.
> Here we use tupperware (our internal container management system) that
> is heavily using cgroups and has nothing to do with systemd.

Just confirming that we are planning to use this decoupled from
systemd as well.  I fail to see how this is at all systemd specific.

> For us this cgroup+bpf is _not_ for filterting and _not_ for security.
> We run a ton of tasks in cgroups that launch all sorts of
> things on their own. We need to monitor what they do from networking
> point of view. Therefore bpf programs need to monitor the traffic in
> particular part of cgroup hierarchy. Not globally and no pass/drop decisions.

+10, although filtering/drop is a valid use case, the really strong
use case is definitely introspection at networking level. Statistics,
monitoring, verification of application correctness, etc. 

I don't see why this is at all an either or discussion. If nft wants
cgroups integration similar to this effort, I see no reason why that
should stop this effort.
