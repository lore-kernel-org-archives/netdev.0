From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Thu, 17 Aug 2006 00:16:46 +0200
Message-ID: <200608170016.47072.arnd@arndb.de>
References: <44E38157.4070805@garzik.org> <200608162324.47235.arnd@arndb.de>
	<20060816.143203.11626235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com,
	David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060816.143203.11626235.davem@davemloft.net>
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

Am Wednesday 16 August 2006 23:32 schrieb David Miller:
> Can spidernet be told these kinds of parameters? =A0"N packets or
> X usecs"?

It can not do exactly this but probably we can get close to it by

1.) Setting a one-time interrupt to fire x*10=B5s after putting a
   packet into the TX queue.

and

2.a) Enabling end of TX queue interrupts whenever more than y frames
     have been queued for TX.

or

2.b) Marking frame number y in the TX to fire an interrupt when it
     has been transmitted, and move the mark whenever we clean up
     TX descriptors.

or

2.c) Marking frame number y to generate an interrupt, but counting
     y from the end of the queue, and update the mark whenever we
     add frames to the queue tail.

I'm not sure which version of 2. would give us the best approximation.

	Arnd <><
