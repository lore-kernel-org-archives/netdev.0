From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 19:07:39 +0200
Message-ID: <20160819170739.GF29430@pox.localdomain>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38559 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbcHSRHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 13:07:42 -0400
Received: by mail-wm0-f54.google.com with SMTP id o80so50249712wme.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 10:07:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160819162158.GA25083@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/16 at 06:21pm, Pablo Neira Ayuso wrote:
> On Fri, Aug 19, 2016 at 12:35:14PM +0200, Daniel Mack wrote:
> > Also true. A cgroup can currently only hold one bpf program for each
> > direction, and they are supposed to be set from one controlling instance
> > in the system. However, it is possible to create subcgroups, and install
> > own programs in them, which will then be effective instead of the one in
> > the parent. They will, however, replace each other in runtime behavior,
> > and not be stacked. This is a fundamentally different approach than how
> > nf_tables works of course.
> 
> I see, this looks problematic indeed, thanks for confirming this.

What exactly is problematic? I think the proposed mechanism is very
clean in allowing sub groups to provide the entire program. This
allows for delegation. Different orchestrators can manage different
cgroups. It's different as Daniel stated. I don't see how this is
problematic though.

You brought up multiple tables which reflect the cumulative approach.
This sometimes works but has its issues as well. Users must be aware
of each other and anticipate what rules other users might inject
before or after their own tables. The very existence of firewalld which
aims at democratizing this collaboration proves this point.

So in that sense I would very much like for both models to be made
available to users. nftables+cgroups for a cumulative approach as
well as BPF+cgroups for the delegation approach.  I don't see why the
cgroups based filtering capability should not be made available to both.
