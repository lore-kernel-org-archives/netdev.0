From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] ipv6: Prevent ipv6_find_hdr() from returning ENOENT
 for valid non-first fragments
Date: Fri, 9 Jan 2015 01:05:46 +0100
Message-ID: <20150109000546.GA3488@salvia>
References: <CAFB3abzYNYqtzd_n+Ym0Lo=DYbV0HPU=Tqw=stALNnu188hMKQ@mail.gmail.com>
 <20150106224706.GA7416@salvia>
 <CAFB3abwKpR1VqZXUrsexqveAZrA2LTSmTe8a=-H7z2HjAptjwA@mail.gmail.com>
 <1420627396.26870.36.camel@stressinduktion.org>
 <20150108205328.GA3361@salvia>
 <1420756756.1755002.211556745.0418D128@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rahul Sharma <rsharma@arista.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41751 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543AbbAIADI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 19:03:08 -0500
Content-Disposition: inline
In-Reply-To: <1420756756.1755002.211556745.0418D128@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 11:39:16PM +0100, Hannes Frederic Sowa wrote:
> Hi Pablo,
> 
> On Thu, Jan 8, 2015, at 21:53, Pablo Neira Ayuso wrote:
> > I'm afraid we cannot just get rid of that !ipv6_ext_hdr() check. The
> > ipv6_find_hdr() function is designed to return the transport protocol.
> > After the proposed change, it will return extension header numbers.
> > This will break existing ip6tables rulesets since the `-p' option
> > relies on this function to match the transport protocol.
> >
> > Note that the AH header is skipped (see code a bit below this
> > problematic fragmentation handling) so the follow up header after the
> > AH header is returned as the transport header.
> > 
> > We can probably return the AH protocol number for non-1st fragments.
> > However, that would be something new to ip6tables since nobody has
> > ever seen packet matching `-p ah' rules. Thus, we restore control to
> > the user to allow this, but we would accept all kind of fragmented AH
> > traffic through the firewall since we cannot know what transport
> > protocol contains from non-1st fragments (unless I'm missing anything,
> > I need to have a closer look at this again tomorrow with fresher
> > mind).
> 
> The code in question is guarded by (_frag_off != 0), so we are
> definitely processing a non-1st fragment currently. The -p match would
> happen at the time when the packet is reassembled and thus ipv6_find_hdr
> will find the real transport (final) header at this point (I hope I
> followed the code correctly here).

Then, Rahul should get things working by modprobing nf_defrag_ipv6.
