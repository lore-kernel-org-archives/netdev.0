From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 19 Dec 2004 14:33:55 -0500
Message-ID: <1103484835.1050.160.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<528y7vobze.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <528y7vobze.fsf@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Sat, 2004-12-18 at 10:35, Roland Dreier wrote:

> By the way, am I correct in thinking that the use of xmit_lock_owner
> in qdisc_restart() is racy?

No.

>     if (!spin_trylock(&dev->xmit_lock)) {
>     /* get the lock */
> 
>                                             if (!spin_trylock(&dev->xmit_lock)) {
>                                             /* fail */
>                                                 if (dev->xmit_lock_owner == smp_processor_id()) {
>                                                 /* test the wrong value */
> 
>     /* set the value too late */
>     dev->xmit_lock_owner = smp_processor_id();
> 

The setting is protected by the queue lock. So no race.

cheers,
jamal
