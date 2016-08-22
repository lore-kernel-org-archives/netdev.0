From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Mon, 22 Aug 2016 10:20:42 -0700
Message-ID: <20160822172040.GA22876@ircssh.c.rugged-nimbus-611.internal>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia>
 <20160819170739.GF29430@pox.localdomain>
 <20160822160610.GA32723@salvia>
 <05bfd5c4-4095-37ff-b7a6-85b8dca8ec70@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Thomas Graf <tgraf@suug.ch>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:37360 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752999AbcHVRVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:21:47 -0400
Received: by mail-it0-f50.google.com with SMTP id f6so90614186ith.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:20:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <05bfd5c4-4095-37ff-b7a6-85b8dca8ec70@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 06:22:20PM +0200, Daniel Mack wrote:
> On 08/22/2016 06:06 PM, Pablo Neira Ayuso wrote:
> > On Fri, Aug 19, 2016 at 07:07:39PM +0200, Thomas Graf wrote:
> 
> >> You brought up multiple tables which reflect the cumulative approach.
> >> This sometimes works but has its issues as well. Users must be aware
> >> of each other and anticipate what rules other users might inject
> >> before or after their own tables. The very existence of firewalld which
> >> aims at democratizing this collaboration proves this point.
> > 
> > Firewalld, was really required in the iptables predefined tables
> > model, in nft last time we talked about this during NFWS'15, future
> > plans for firewalld were not clear yet.
> > 
> > Moreover, in nft, different users can indeed dump the ruleset and it
> > would be possible to validate if one policy is being shadowed by
> > another coming later on. The bpf bytecode dump cannot be taken to the
> > original representation.
> 
> But as Thomas said - both things address different use-cases. For
> container setups, there is no administrator involved to use cli tools,
> so I don't think that's really much of an argument.
> 
> >> So in that sense I would very much like for both models to be made
> >> available to users. nftables+cgroups for a cumulative approach as
> >> well as BPF+cgroups for the delegation approach.  I don't see why the
> >> cgroups based filtering capability should not be made available to both.
> > 
> > This patchset also needs an extra egress hook, not yet known where to
> > be placed, so two hooks in the network stacks in the end, 
> 
> That should be solvable, I'm sure. I can as well leave egress out for
> the next version so it can be added later on.
> 
Any idea where you might put that yet? Does dev_xmit seems like a reasonable 
place?

> > and this only works for cgroups version 2.
> 
> I don't see a problem with that, as v1 and v2 hierarchies can peacefully
> coexist.
> 
If someone uses the netprio, or the net classid controllers, skcd matches
no longer work. Ideally, we should fix up these controllers to make them
more v2 friendly.

> > Last time we talked about this, main concerns were that this was too
> > specific, but this approach seems even more specific to me.
> 
> Hmm, I disagree - bpf programs that are associated with cgroups are
> rather something that can be extended a lot in the future, for instance
> for handling port binding permissions etc. Unlike the proposed network
> cgroup controller with all sorts of complicated knobs to control ranges
> of ports etc, a bpf program that take care of that in a much more
> versatile way.
> 
> I also strongly believe we can have both, a cgroup controller that has
> bpf programs for socket filtering and other things, _and_ a "post socket
> lookup netfilter" table type. Both will have their individual use-cases.
> 
> 
> Thanks,
> Daniel
> 
