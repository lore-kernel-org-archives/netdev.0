From: Michal Ludvig <michal@logix.cz>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 22:17:25 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410302207040.9742@maxipes.logix.cz>
References: <1099030958.4944.148.camel@uganda>
 <Xine.LNX.4.44.0410291342350.22168-100000@thoron.boston.redhat.com>
 <20041030091932.6a74bdae@zanzibar.2ka.mipt.ru> <Pine.LNX.4.61.0410301805360.14888@maxipes.logix.cz>
 <20041030214050.7e23d7b8@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20041030214050.7e23d7b8@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Evgeniy Polyakov wrote:

> On Sat, 30 Oct 2004 18:57:20 +0200 (CEST)
> Michal Ludvig <michal@logix.cz> wrote:
> 
> > I have compiled and booted with your patches. Not too much 
> > playing around so far. Anyway some quick observations:
> 
> I've wrote mega block device which can work(without hang) only 
> with 10mb "disks", but what did you expect from midnight hack after
> several Staropramen's :)

10MB is probably too small to get some reliable numbers. The testing 
should last for at least couple of seconds...

> Give me several minutes to complete async_provider.c and I will post
> numbers, which I expect will be the same for both sync and async
> driver since I do not have neither SMP(which should benefit I believe) 
> nor crypto card here.

At least try it with a SMP kernel (on UP machine) to catch the worst 
spindeadlocks etc. In the ideal case the acrypto core should know that 
there are two (four, ...) CPUs and all of them can encrypt in paralel.

> > - "rmmod simple_lb" hangs because:
> > | <6>You are removing crypto load balancer simple_lb which is current and 
> > | default.
> > | There is no other crypto load balancers. Removing is delayed untill new 
> > | load balancer is registered.
> > Of course I can't re-add it because the module is still there. In this 
> > case rmmod should fail with a gentle message (-EBUSY) instead of hang. Or 
> > let it go if not in use.
> 
> acrypto module has parameter force_lb_remove which if is set allows to remove
> last crypto load balancer.
> But ut has atricky moment - since any crypto_session_alloc() may occur 
> asyncronously then we can not say if there are any load balancer users
> without some locks. Currently if there is no any crypto load balancer, then
> acrypto will catch BUG_ON().

BUG_ON()? Shouldn't crypto_session_alloc() fail instead? BUG_ON() is for 
catching conditions that really shouldn't happen in normal operation. 
Missing module with a load balancer won't be that unusual...

Or should the acrypto.ko module prerequire a balancer to get it loaded 
automatically?

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal
