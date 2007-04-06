From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH] 8139too: harden against TX ring
	overflow
Date: Fri, 6 Apr 2007 09:01:28 +0530
Message-ID: <200704060901.28628.amitkale@linsyssoft.com>
References: <E1HZdZ2-000620-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	Herbert Xu <herbert@gondor.apana.org.au>, mhuth@mvista.com
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <E1HZdZ2-000620-00@gondolin.me.apana.org.au>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Sender: kgdb-bugreport-bounces@lists.sourceforge.net
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Friday 06 April 2007 07:18, Herbert Xu wrote:
> Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:
> > This driver's 4-packet deep TX queue is too sensible to the "careless"
> > callers ignoring its state (like netpoll in trapped mode), so add "queue
> > full" check at the start of the hard_start_xmit() method (only under
> > #ifndef RTL8139_NDEBUG, otherwise the queue will get stuck once dirty
> > pointer gets out of sync); switch to using appropriate mnemonics for the
> > return values while at it.
>
> Could you please describe this netpoll scenario in more detail?
> More importantly, why wouldn't we fix netpoll instead?

We're trying to figure out a way of fixing netpoll. Don't know what the 
solution is yet.

Here is what happens: in KGDB we set netpoll trapped flag. This prevents 
stopping and starting of a netdev queue. Interfaces that have a small ring 
(8139) run into a problem because of this. When the ring goes full, it can't 
stop the queue. This doesn't make sense since in absence of ring descriptors, 
the device can't transmit any more packets. Sergie had posted one more patch 
last week that lets us start and stop queues in trapped state.

This patch fixes the 8139 side behavior in this context.
-Amit

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
