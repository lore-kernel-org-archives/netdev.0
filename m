From: Tim Hansen <devtimhansen@gmail.com>
Subject: Re: [PATCH v2] net/sock: Update sk rcu iterator macro.
Date: Mon, 23 Oct 2017 15:37:04 -0400
Message-ID: <20171023193704.ekusped6ampujgqv@debian>
References: <20171023153922.orgvwmuvokv6xbi4@debian>
 <20171023184247.p54glyvdkgaxht2f@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171023184247.p54glyvdkgaxht2f@sasha-lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Oct 23, 2017 at 06:42:50PM +0000, Levin, Alexander (Sasha Levin) wrote:
> On Mon, Oct 23, 2017 at 11:39:22AM -0400, Tim Hansen wrote:
> >Mark hlist nodes in sk rcu iterator as protected by the rcu.
> >hlist_next_rcu accomplishes this and silences the warnings
> >sparse throws for net/ipv4/udp.c and net/ipv6/udp.c.
> >
> >Found with make C=1 net/ipv4/udp.o on linux-next tag
> >next-20171009.
> >
> >Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
> >---
> > include/net/sock.h | 4 ++--
> > 1 file changed, 2 insertions(+), 2 deletions(-)
> >
> >diff --git a/include/net/sock.h b/include/net/sock.h
> >index 64e5ac41b9cf..96cb7b7e4924 100644
> >--- a/include/net/sock.h
> >+++ b/include/net/sock.h
> >@@ -737,10 +737,10 @@ static inline void sk_add_bind_node(struct sock *sk,
> >  *
> >  */
> > #define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)		       \
> >-	for (pos = rcu_dereference((head)->first);			       \
> >+	for (pos = rcu_dereference(hlist_next_rcu((head)->first));	       \
> 
> See below.
> 
> > 	     pos != NULL &&						       \
> > 		({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
> >-	     pos = rcu_dereference(pos->next))
> >+	     pos = rcu_dereference(hlist_next_rcu(pos->next)))
> 
> This will return the next-next node instead of just the next one. You
> probably want just hlist_next_rcu(pos) here.
> 
> -- 
> 
> Thanks,
> Sasha

Thanks Sasha, dumb oversight on my part. Sent in v3 of this patch.
