From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Sat, 27 Sep 2008 04:00:00 +0400
Message-ID: <20080927000000.GB10489@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913104515.GA7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:60987 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbYIZX5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 19:57:40 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1125078fkq.5
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2008 16:57:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080913104515.GA7440@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 02:45:15PM +0400, Alexey Dobriyan wrote:
> On Tue, Sep 09, 2008 at 09:51:56AM +0200, Patrick McHardy wrote:
> > Alexey Dobriyan wrote:
> >> On Tue, Sep 09, 2008 at 09:20:42AM +0200, Patrick McHardy wrote:
> >>> Having multiple of these net_eq checks per function (14 total) is
> >>> not a very nice way to do this.
> >>
> >> Yep, I was just afraid of some subtle ordering rules and to keep
> >> potential init_net breakage to minimum.
> >
> > Me too, but I still prefer to do it properly once.
> >
> >>> How about splitting the code into a netns and a global part instead?
> >>
> >> Prebably they aren't strict at all.
> >
> > Not particulary. For cleanup a three stage approach with
> >
> > 1. init_net deactivation (ip_ct_attach = NULL)
> > 2. generic netns cleanup
> > 3. init_net specific final cleanup (slab cache, nf_conntrack_cachep,
> >    accounting, helpers, protocols, ...)
> >
> > should work fine.
> >
> > The initialization should be OK with just a init_net part
> > and a generic netns part.
> 
> Ugh, I'm still finding the least ugly way to put init_net checks, and
> it's better to do it at the very end.
> 
> So, slight reordering.
> 
> See per-netns statistics, nf_conntrack_count, nf_conntrack_checksum,
> nf_conntrack_log_invalid and accounting.
> 
> The rest (SIP, H323, GRE, PPTP, per-netns NAT) remains the same and can
> be applied independently of init_net checks.

Ping!

I've just sent patch which adds init_net checks in somewhat nicer way.

Please, review and apply the rest.
