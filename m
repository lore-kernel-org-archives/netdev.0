From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v2] net: clean up locking in inet_frag_find()
Date: Tue, 27 Nov 2012 11:05:08 +0800
Message-ID: <1353985508.11455.19.camel@cr0>
References: <1353909184.11282.3.camel@cr0>
	 <1353914786-10426-1-git-send-email-amwang@redhat.com>
	 <1353942751.30446.1769.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933060Ab2K0DGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 22:06:14 -0500
In-Reply-To: <1353942751.30446.1769.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 07:12 -0800, Eric Dumazet wrote:
> On Mon, 2012-11-26 at 15:26 +0800, Cong Wang wrote:
> > It is weird to take the read lock outside of inet_frag_find()
> > but release it inside...  This can be improved by refactoring
> > the code, that is, introducing inet{4,6}_frag_find() which call
> > the their own hash function, inet{4,6}_hash_frag(), hiding the
> > details from their callers.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > ---
> >  include/net/inet_frag.h                 |   17 +++++-
> >  include/net/ipv6.h                      |    3 -
> >  net/ipv4/inet_fragment.c                |   82 +++++++++++++++++++++++++++++--
> >  net/ipv4/ip_fragment.c                  |   16 +-----
> >  net/ipv6/netfilter/nf_conntrack_reasm.c |    7 +--
> >  net/ipv6/reassembly.c                   |   34 +------------
> >  6 files changed, 97 insertions(+), 62 deletions(-)
> 
> 
> Not clear to me its a win, as it adds 35 LOC. Nobody really complained
> of this locking schem in the past.

Yeah, seems every people here is able to read any ugly code, except
me. :-)

> 
> Also Jesper is working on this stuff, so you dont really ease its work.
> 
> 

I will rebase his tree for him, no worry, handling conflicts is part of
my life everyday (I am a heavy `git rebase -i` user).
