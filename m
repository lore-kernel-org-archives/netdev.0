From: Michal Ludvig <michal@logix.cz>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 18:57:20 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410301805360.14888@maxipes.logix.cz>
References: <1099030958.4944.148.camel@uganda>
 <Xine.LNX.4.44.0410291342350.22168-100000@thoron.boston.redhat.com>
 <20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Evgeniy Polyakov wrote:

> On Fri, 29 Oct 2004 13:44:24 -0400 (EDT)
> James Morris <jmorris@redhat.com> wrote:
> 
> > On Fri, 29 Oct 2004, Evgeniy Polyakov wrote:
> > 
> > > I'm pleased to announce asynchronous crypto layer for Linux kernel 2.6.
> > 
> > Could you please resend as a patch against the latest bk snapshot?
> > 
> > i.e. output of 'diff -purN tree-a tree-b'
> > 
> 
> Attached following patches:
> 
> Kconfig.connector.patch
> Kconfig.crypto.patch
> Makefile.connector.patch
> Makefile.crypto.patch
> acrypto.patch
> connector.patch

Hi Evgeniy,

I have compiled and booted with your patches. Not too much 
playing around so far. Anyway some quick observations:

- "rmmod simple_lb" hangs because:
| <6>You are removing crypto load balancer simple_lb which is current and 
| default.
| There is no other crypto load balancers. Removing is delayed untill new 
| load balancer is registered.
Of course I can't re-add it because the module is still there. In this 
case rmmod should fail with a gentle message (-EBUSY) instead of hang. Or 
let it go if not in use.

- In the kernel config ACRYPTO depends on CONNECTOR, but is above it in 
the menuconfig.

- I would choose a different directory strucrure. Instead of 
drivers/acrypto and drivers/connector I'd put the device-independent 
parrts info e.g. crypto/acrypto and the drivers (e.g. Fcrypt or PadLock) 
into drivers/crypto.

- For other interested: concatenated patch with some very minor tweaks is 
at http://www.logix.cz/michal/dl/acrypto/acrypto.diff
My changes are in mludvig.diff in the same directory.
It applies cleanly to BitKeeper tree as well.

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal
