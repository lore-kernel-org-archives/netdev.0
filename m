From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 02:21:41 +0200
Message-ID: <488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
	<20060919184243.GL29167@austin.ibm.com>
	<45103C62.4080003@genesi-usa.com>
	<1158708269.6002.186.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1158708269.6002.186.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
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

> Nah. We have the basic rule that readl/writel are little endian.  
> PowerPC
> additionally provides arch specific low level in_{be,le}32 type
> accessors with explicit endianness. Or you can also use
> cpu_to_le32/le32_to_cpu kind of macros to convert between native and
> explicit endianness.

Sure, PCI busses are little-endian.  But is readX()/writeX() for PCI
only?  I sure hope not.

It would make a lot more sense if readX()/writeX() used the endianness
of the bus they are performed on.  PowerPC byteswaps are cheap -- for
16- and 32-bit accesses.  They're quite bad for 64-bit though; it would
be a pity to end up doing two of those for a 64-bit big-endian I/O  
access
(one on the access itself, one to convert the data back to CPU order).

This would happily solve the problem of the various variations of
byte-swapping bus bridges, too ("natural" swap, 32-bit swap, 64-bit  
swap,
perhaps others that I thankfully have never seen or cannot remember).

Now you can say, use readl_be() or something similar, but that's a)  
ugly,
b) error-prone, c) exponential interface explosion, d) ugly.


Segher
