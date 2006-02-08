From: Grant Coady <gcoady@gmail.com>
Subject: Re: [Patch] 2.4.32 - Neighbour Cache (ARP) State machine bug Fixed
Date: Wed, 08 Feb 2006 13:13:09 +1100
Message-ID: <4skiu150r13a2a78i68bg28cvdb67a8qjb@4ax.com>
References: <9fda5f510511281257o364acb3gd634f8e412cd7301@mail.gmail.com> <9fda5f510602031806j2f9ef743t206c9ee2c3bef384@mail.gmail.com> <20060203.181839.104353534.davem@davemloft.net> <9fda5f510602062357n38292cebk3c5738ccdbee83@mail.gmail.com> <20060207215341.GC11380@w.ods.org> <9fda5f510602071750o53f76fc8gc94c280a9998343d@mail.gmail.com>
Reply-To: gcoady@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <willy@w.ods.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030448AbWBHCNN@vger.kernel.org>
To: Pradeep Vincent <pradeep.vincent@gmail.com>
In-Reply-To: <9fda5f510602071750o53f76fc8gc94c280a9998343d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Feb 2006 17:50:03 -0800, Pradeep Vincent <pradeep.vincent@gmail.com> wrote:

>One more attempt. Attaching the diff file as well.
>
>Signed off by: Pradeep Vincent <pradeep.vincent@gmail.com>
>
>--- old/net/core/neighbour.c    Wed Nov  9 16:48:10 2005
>+++ new/net/core/neighbour.c    Tue Feb  7 17:38:26 2006
>@@ -14,6 +14,7 @@
>  *     Vitaly E. Lavrov        releasing NULL neighbor in neigh_add.
>  *     Harald Welte            Add neighbour cache statistics like rtstat
>  *     Harald Welte            port neighbour cache rework from 2.6.9-rcX
>+ *     Pradeep Vincent         fix neighbour cache state machine
>  */
>
> #include <linux/config.h>
>@@ -705,6 +706,13 @@
>                        neigh_release(n);
>                        continue;
>                }
>+               /* Move to NUD_STALE state */
>+               if (n->nud_state&NUD_REACHABLE &&
>+                   now - n->confirmed > n->parms->reachable_time) {

Hmm, you're suffering tab -> space conversion syndrome :(

Grant.
