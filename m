From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Sun, 20 Mar 2005 12:13:55 -0800
Message-ID: <200503202013.j2KKDtDD000198@guinness.s2io.com>
References: <1111326010.1093.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, <netdev@oss.sgi.com>, <jgarzik@pobox.com>
To: <hadi@cyberus.ca>
In-Reply-To: <1111326010.1093.32.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,
You are right on target, it's all about finding the best driver support
model - for the end users, not for a Neterion developer or even for a Linux
hacker.
At the moment, "s2io" driver is supported in exactly the way you suggest;
the model works well but we think it's possible to do better - again, for
the end user sake.

If we could write a driver, put it in the kernel and let it "heal itself",
then I'd agree that the current model would have been the best. We'd have
been happy to stay with it, rather than to go through with a considerable
extra effort - preserving the status quo is always easier.  

I'd argue that the vast majority of a 10GbE NICs will be initially developed
by a smaller company like Neterion, shipped by large server OEMs and
supported (from end-user prospective) by these two entities, as well as by
Linux community and major Linux distributors.

In our experience, even early adopters of 10GbE adapters in Linux space
rarely attempt to fix hardware-dependent bugs themselves - they ask for
support from one of the three entities above (a NIC vendor, a server vendor
an a Linux distributor), with a lion share of urgent level 2 and level 3
issues ending up with a NIC vendor. As 10GbE adoption accelerates, I expect
this trend will accelerate as well - I wish we could shift the support
burden to someone else, but the chances of that to happen are getting
slimmer over time :-).

BTW this is precisely the reason the NIC vendors favor HAL model. Software
teams are about the same size, no matter whether it's a big or small company
- and no NIC vendor likes spending 30% of their resources on one (out of 10)
device drivers.

So, at least from what we see in our space, open source is a great thing but
it doesn't make driver support (at least for the low level NIC code)
fundamentally different from other Operating Systems, at least not for a
foreseeable future. 
IMHO, nor should it - ability to have source and fix hw-dependent bugs is
great, but I'd argue that much bigger value of the open source model is in
the (more strategic) ability to timely identify and fix existing networking
bottlenecks that are common to most/all NIC drivers. 

An example - at present, there are no Linux UDP TSO APIs.  We see a customer
need for it and we have the ASIC support as well; from an end user (and
about everybody else) prospective it would be great to add these APIs by
people who know Linux best.
Whether the hw-dependent part of the UDP TSO is done by a hacker or it is an
existing and working HAL code from a Neterion developer, is not that
important to the end user - though the latter will be a more likely and more
efficient way to go. 

BTW all arguments above make sense only if a high-level part of the driver
is very much "Linux-like" - we are obviously motivated to make the high
level code suitable to the changes by the community, since this is where the
value for the end user is.

We could talk about some other points that you brought up (for example, the
statement about other OSes not changing is applicable only to a small subset
of "legacy" OSes - I suspect the rest of them will be changing NIC APIs
rather fast and HAL is actually a good way to deal with the change across
the board), but as you pointed out the support model is the key here...

Cheers, Leonid



> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of jamal
> Sent: Sunday, March 20, 2005 5:40 AM
> To: Leonid Grossman
> Cc: 'Andi Kleen'; netdev@oss.sgi.com; leonid@neterion.com;
> jgarzik@pobox.com
> Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE
> Adapters
> 
> On Sat, 2005-03-19 at 17:19, Leonid Grossman wrote:
> 
> > Sure. I was not asking for a promise to merge the code, only for a rough
> > consensus that a HAL-based approach by itself is not a showstopper.
> > Without such a consensus, it doesn't matter if we address other issues,
> > right?
> 
> Typically theres only one motivation for HALs - maintain the same code
> base for 20 OSes. Makes it easier for a small company (not sure if yours
> fits that category) to maintain. It doesnt matter how differently you
> position or spin it (no offense intended), that is the main if not only
> motivation.
> 
> OTOH, you shift the burden of the extra maintainance work to the people
> on the Linux side who know may have to understand what your layer does.
> This is why people hate it.
> I dont think it is sufficient to say your company will be updating the
> driver:
> - Years from now your company may not be around anymore but your
> hardware may still be. Who is going to fix the bugs then?
> - APIs, mechanisms etc change on Linux as well. You become a bottleneck
> if nobody understands your HAL because they have to wait for you to make
> the changes.
> Traditionaly whoever makes the changes on dirver schemes ensures all
> drivers are updated. Think positively that this is now offloaded from
> you.
> 
> My suggestion: have a dedicated resource just for Linux - it is big
> enough to justify; maintain HAL for other OSes that will never change, I
> bet you whatever works for NDIS probably will continue to work for
> vxworks for the next 10 years - not much innovation going on there;-> or
> you could claim (bah!) theres stability on those OSes.
> 
> cheers,
> jamal
> 
> 
