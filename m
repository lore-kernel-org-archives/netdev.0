From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 23:24:46 +0200
Message-ID: <200608162324.47235.arnd@arndb.de>
References: <44E34825.2020105@garzik.org> <44E38157.4070805@garzik.org>
	<20060816.134640.115912460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060816.134640.115912460.davem@davemloft.net>
Content-Disposition: inline
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

Am Wednesday 16 August 2006 22:46 schrieb David Miller:
> I'm not familiar with the spidernet TX side interrupt capabilities
> so I can't say whether that is something that can be directly
> implied. =A0In fact, I get the impression that spidernet is limited
> in some way and that's where all the strange approaches are coming
> from :)

Actually, the capabilities of the chip are quite powerful, it only
seems to be hard to make it go fast using any of them. That may
be the fault of strange locking rules and other bugs we had in
the driver before, so maybe you can recommend which one to use.

Cleaning up the TX queue only from ->poll() like all the others
sounds like the right approach to simplify the code.

The spider hardware offers at least these options:

- end of TX queue interrupt
- set a per-descriptor bit to fire an interrupt at a specific frame
- an interrupt for each frame (may be multiple descriptors)
- an interrupt for each descriptor
- timers implemented in the spidernet hardware

We first had an interrupt per descriptor, then got rid of all TX
interrupts and replaced them by timers to reduce the interrupt load,
but reducing throughput in the case where user space sleeps on a full
socket buffer.

The last patches that were suggested introduce marking a single descriptor
(not the last one, but somewhere near the end of the queue) so we fire
an interrupt just before the TX queue gets empty.

	Arnd <><
