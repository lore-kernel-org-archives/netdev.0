From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
Date: Sun, 22 Aug 2004 18:14:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BynUy-0007t1-00@gondolin.me.apana.org.au>
References: <41280163.1050508@vgertech.com>
Cc: linux-kernel@vger.kernel.org, master@sectorb.msk.ru, netdev@oss.sgi.com,
        kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: nuno.silva@vgertech.com (Nuno Silva)
In-Reply-To: <41280163.1050508@vgertech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nuno Silva <nuno.silva@vgertech.com> wrote:
> 
> The problem is in the QoS code. If I start ppp whithout the 

OK, this appears to be due to the changeset titled

[PKT_SCHED]: Refcount qdisc->dev for __qdisc_destroy rcu-callback

It adds a reference to dev.

I don't see any code that cleans up that reference when the dev goes
down.  So someone needs to add that similar to the code in net/core/dst.c.

Patrick, could you please have a look at this?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
