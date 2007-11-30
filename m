From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY
	support
Date: Fri, 30 Nov 2007 19:03:30 +1100
Message-ID: <1196409810.13230.84.camel@pasglop>
References: <1196401223.5661.297518056501.qpush@grosgo>
	<20071130054126.39BDCDDE0A@ozlabs.org>
	<20071130075641.GA16650@infradead.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071130075641.GA16650@infradead.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-11-30 at 07:56 +0000, Christoph Hellwig wrote:
> > 
> > This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC
> driver.
> > These PHY chips are used on PowerPC 440EPx boards.
> > The PHY code is based on the previous work by Stefan Roese
> <sr@denx.de>
> 
> Is there a reason the emac driver isn't using the generic phy code?

Yes. First, the emac PHY code predates the generic one, and mostly,
in its current shape, the generic PHY code does too violent locking
for me.

I need to be able to use mutexes in the low level PHY read/write, and
the current phylib doesn't allow that as it uses spinlocks all over.

However, I do plan to fix that. I haven't had time yet, but I plan to
convert PHY lib to more task-level operations, which would be a good
thing anyway since PHY communication is fairly slow and some chips can
do it interrupt driven rather than polling loops (and even polling loops
could be preemptible).

So the answer is "not yet" basically.

Cheers,
Ben.
