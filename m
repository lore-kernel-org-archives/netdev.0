From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/4] flow_keys: include thoff into flow_keys
 for later usage
Date: Tue, 19 Mar 2013 08:38:18 -0700
Message-ID: <1363707498.2558.16.camel@edumazet-glaptop>
References: <cover.1363702456.git.dborkman@redhat.com>
	 <cc0d2911a173be99651dc39e77286aab260c3c19.1363702456.git.dborkman@redhat.com>
	 <1363705390.2558.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:43983 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608Ab3CSPiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 11:38:22 -0400
Received: by mail-pb0-f48.google.com with SMTP id wy12so527386pbc.21
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 08:38:22 -0700 (PDT)
In-Reply-To: <1363705390.2558.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 08:03 -0700, Eric Dumazet wrote:
> On Tue, 2013-03-19 at 15:34 +0100, Daniel Borkmann wrote:
> > In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
> > doing the work here anyway, also store thoff for a later usage, e.g. in
> > the BPF filter. Also, by having thoff 16 Bit, we do not need to pack
> > flow_keys and reorder choke_skb_cb.
> > 
> > Suggested-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > ---
> >  This patch also needs to go into the net tree, since Eric or Jason will
> >  post a bug fix on top of this one.
> > 
> >  include/net/flow_keys.h   | 1 +
> >  net/core/flow_dissector.c | 5 ++++-
> >  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> Oh well, you left the choke_skb_cb description in changelog
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 

Actually this patch has a bug

the nhoff variable should stay as an int, or a malicious user could
trigger an infinite loop with a big packet, as nhoff could wrap.
