From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
 to become free. Usage count = 1
Date: Sun, 22 Aug 2004 21:47:46 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040822214746.1efb3682.davem@redhat.com>
References: <E1BynUy-0007t1-00@gondolin.me.apana.org.au>
	<4128941D.9030000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nuno.silva@vgertech.com,
	linux-kernel@vger.kernel.org, master@sectorb.msk.ru,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267406AbUHWEtW@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4128941D.9030000@trash.net>
List-Id: netdev.vger.kernel.org

On Sun, 22 Aug 2004 14:39:57 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> 
> >Nuno Silva <nuno.silva@vgertech.com> wrote:
> >  
> >
> >>The problem is in the QoS code. If I start ppp whithout the 
> >>    
> >>
> >
> >OK, this appears to be due to the changeset titled
> >
> >[PKT_SCHED]: Refcount qdisc->dev for __qdisc_destroy rcu-callback
> >
> >It adds a reference to dev.
> >
> >I don't see any code that cleans up that reference when the dev goes
> >down.  So someone needs to add that similar to the code in net/core/dst.c.
> >
> >Patrick, could you please have a look at this?
> >  
> The reference is dropped in __qdisc_destroy. The problem lies in the CBQ
> qdisc, it doesn't destroy the root-class and leaks the inner qdisc. These
> two patches for 2.4 and 2.6 fix the problem.

Awesome, good detective work guys.

Patch applied, thanks.
