From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: 2.6.9-mm1: pc_debug multiple definitions
Date: Sun, 24 Oct 2004 06:05:57 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20041024100557.GC17506@ruslug.rutgers.edu>
References: <20041022032039.730eb226.akpm@osdl.org>
	<20041022133929.GA2831@stusta.de>
	<20041024034152.GB17506@ruslug.rutgers.edu>
	<20041024093340.GA4216@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	prism54-devel@prism54.org, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org,
	David Hinds <dahinds@users.sourceforge.net>, jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20041024093340.GA4216@stusta.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 24, 2004 at 11:33:40AM +0200, Adrian Bunk wrote:
> On Sat, Oct 23, 2004 at 11:41:52PM -0400, Luis R. Rodriguez wrote:
> > On Fri, Oct 22, 2004 at 03:39:29PM +0200, Adrian Bunk wrote:
> > > 
> > > The following compile error comes from Linus' tree:
> > > 
> > > 
> > > <--  snip  -->
> > > 
> > > ...
> > >   LD      drivers/built-in.o
> > > drivers/pcmcia/built-in.o(.bss+0xf20): multiple definition of `pc_debug'
> > > drivers/net/built-in.o(.data+0x24ae0): first defined here
> > > make[1]: *** [drivers/built-in.o] Error 1
> > > 
> > > <--  snip  -->
> > > 
> > > 
> > > The pc_debug in drivers/pcmcia/ds.c was made non-static in Linus' tree,
> > > but the global definition of a global variable with such a generic name 
> > > in drivers/net/wireless/prism54/islpci_mgt.c seems to be equally wrong.
> > 
> > Great, anyone know why this change was done on ds.c ? The pc_debug on
> > prism54 comes from the original Intersil driver. It is used to for
> > debugging but we should move away from our current debugging mechanism
> > to netif_msg.
> >...
> 
> pc_debug is a pretty generic name - it seems too generic in both files.
> 
> In prism54, couldn't it be called prism54_pc_debug?

Sure although that's doing a half ass job. It'll fix your compile
problems for sure but ideally we should move away from the old debug
mechanisms that came with the driver originally. We do this by moving to
to netif_msg.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
