From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Tue, 19 Oct 2004 17:51:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098222676.23367.18.camel@krustophenia.net>
References: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: vda@port.imtp.ilyichevsk.odessa.ua,
        Linux Network Development <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-10-19 at 17:35, Herbert Xu wrote:
> Lee Revell <rlrevell@joe-job.com> wrote:
> > 
> > I looked at Robert Love's book and I am still unclear on the use of
> > do_softirq above.  To reiterate the question:  why does netif_rx_ni have
> > to manually flush any pending softirqs on the current proccessor after
> > doing the rx?  Is this just a performance hack?
> 
> Yes it allows the packet to be processed immediately.

Ok, here is the correct patch.  If this is really just a matter of
performance, and not required for correctness, disabling preemption is
broken, right?

Lee

--- include/linux/netdevice.h~	2004-10-15 20:19:33.000000000 -0400
+++ include/linux/netdevice.h	2004-10-19 17:47:03.000000000 -0400
@@ -697,8 +697,6 @@
 static inline int netif_rx_ni(struct sk_buff *skb)
 {
        int err = netif_rx(skb);
-       if (softirq_pending(smp_processor_id()))
-               do_softirq();
        return err;
 }
