From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 09:01:25 -0700
Message-ID: <20160819160123.GA30210@ast-mbp.thefacebook.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35103 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbcHSQBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:01:31 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so1662623pfg.2
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:01:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160819091941.GA2113@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:19:41AM +0200, Pablo Neira Ayuso wrote:
> Hi Daniel,
> 
> On Wed, Aug 17, 2016 at 04:00:43PM +0200, Daniel Mack wrote:
> > I'd appreciate some feedback on this. Pablo has some remaining concerns
> > about this approach, and I'd like to continue the discussion we had
> > off-list in the light of this patchset.
> 
> OK, I'm going to summarize them here below:
> 
> * This new hook allows us to enforce an *administrative filtering
>   policy* that must be visible to anyone with CAP_NET_ADMIN. This is
>   easy to display in nf_tables as you can list the ruleset via the nft
>   userspace tool. Otherwise, in your approach if a misconfigured
>   filtering policy causes connectivity problems, I don't see how the
>   sysadmin is going to have an easy way to troubleshoot what is going on.
> 
> * Interaction with other software. As I could read from your patch,
>   what you propose will detach any previous existing filter. So I
>   don't see how you can attach multiple filtering policies from
>   different processes that don't cooperate each other. In nf_tables
>   this is easy since they can create their own tables so they keep their
>   ruleset in separate spaces. If the interaction is not OK, again the
>   sysadmin can very quickly debug this since the policies would be
>   visible via nf_tables ruleset listing.
> 
> * During the Netfilter Workshop, the main concern to add this new socket
>   ingress hook was that it is too specific. However this new hook in
>   the network stack looks way more specific more specific since *it only
>   works for cgroups*.
> 
> So what I'm proposing goes in the direction of using the nf_tables
> infrastructure instead:

Pablo, if you were proposing to do cgroups+nft as well as cgroups+bpf
we could have had much more productive discussion.
You were not participating in cgroup+bpf design and now bringing up
bogus points that make no sense to me. That's not helpful.
Please start another cgroups+nft thread and there we can discuss the
ways to do it cleanly without slowdown the stack.
netfilter hooks bloat the stack enough that some people compile them out.
If I were you, I'd focus on improving iptables/nft performance instead
of arguing about their coolness.

> Thanks for your patience on debating this!

I don't think you're sincere.
