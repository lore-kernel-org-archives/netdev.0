From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Mon, 22 Aug 2016 18:06:10 +0200
Message-ID: <20160822160610.GA32723@salvia>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia>
 <20160819170739.GF29430@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44472 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754533AbcHVQGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 12:06:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A563F1F18E7
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 18:06:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8B70C100A60
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 18:06:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5F552100A57
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 18:06:11 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160819170739.GF29430@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Fri, Aug 19, 2016 at 07:07:39PM +0200, Thomas Graf wrote:
> On 08/19/16 at 06:21pm, Pablo Neira Ayuso wrote:
> > On Fri, Aug 19, 2016 at 12:35:14PM +0200, Daniel Mack wrote:
> > > Also true. A cgroup can currently only hold one bpf program for each
> > > direction, and they are supposed to be set from one controlling instance
> > > in the system. However, it is possible to create subcgroups, and install
> > > own programs in them, which will then be effective instead of the one in
> > > the parent. They will, however, replace each other in runtime behavior,
> > > and not be stacked. This is a fundamentally different approach than how
> > > nf_tables works of course.
> > 
> > I see, this looks problematic indeed, thanks for confirming this.
> 
> What exactly is problematic? I think the proposed mechanism is very
> clean in allowing sub groups to provide the entire program. This
> allows for delegation. Different orchestrators can manage different
> cgroups. It's different as Daniel stated. I don't see how this is
> problematic though.
> 
> You brought up multiple tables which reflect the cumulative approach.
> This sometimes works but has its issues as well. Users must be aware
> of each other and anticipate what rules other users might inject
> before or after their own tables. The very existence of firewalld which
> aims at democratizing this collaboration proves this point.

Firewalld, was really required in the iptables predefined tables
model, in nft last time we talked about this during NFWS'15, future
plans for firewalld were not clear yet.

Moreover, in nft, different users can indeed dump the ruleset and it
would be possible to validate if one policy is being shadowed by
another coming later on. The bpf bytecode dump cannot be taken to the
original representation.

> So in that sense I would very much like for both models to be made
> available to users. nftables+cgroups for a cumulative approach as
> well as BPF+cgroups for the delegation approach.  I don't see why the
> cgroups based filtering capability should not be made available to both.

This patchset also needs an extra egress hook, not yet known where to
be placed, so two hooks in the network stacks in the end, and this
only works for cgroups version 2.

Last time we talked about this, main concerns were that this was too
specific, but this approach seems even more specific to me.
