From: Peter Dolding <oiaohm@gmail.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
	firewalls"
Date: Thu, 22 Jan 2009 23:46:35 +1000
Message-ID: <e7d8f83e0901220546l90987a7ic3d7a7c98b14f07a@mail.gmail.com>
References: <e7d8f83e0901211528ue344783qb66e481902274961@mail.gmail.com>
	 <504710.17436.qm@web31507.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: rmeijer@xs4all.nl, Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: imipak@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f21.google.com ([209.85.217.21]:59904 "EHLO
	mail-gx0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbZAVNqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 08:46:37 -0500
In-Reply-To: <504710.17436.qm@web31507.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 10:50 AM, Jonathan Day <imipak@yahoo.com> wrote:
> --- On Wed, 1/21/09, Peter Dolding <oiaohm@gmail.com> wrote:
> (snip)
>> There are many ways though the Linux kernel.  This is part
>> of the
>> reason why I am asking why they are wanting LSM so much.
>> LSM was
>> decided to be only one thing.   Not something to make more
>> of if it
>> can be avoided.   First rule should be seeing if API and
>> Internal
>> structs of Linux need fixing.  This case yes there are
>> quite a few
>> weaknesses in netfilter that could do with fixing.   If
>> after fixing
>> netfilter up it still turns out you need LSM support then
>> you do have
>> a valid reason.
> (snip)
>
> I agree with most of your argument (both what is quoted and what is snipped) but would be wary of any kernel-based solution for the reason I outlined in an earlier post - there are IPv4/6 stacks that sit in hardware and feed direct to userspace, and others that sit in userspace and use the zerocopy patches to minimize kernel entanglement. True, these are not the most common methods in use, and equally true, they would be just as complex to serve via LSM as by netfilter.

Worked with IPv4/6 hardware stacks.   Most of ones I have handled have
had built in firewall processing.  Letting them feed directly into
userspace becomes very uncontrollable very quickly.  Netfilter can be
altered to operate like ALSA with hardware mixer.  Yes slower but you
can filter.   Doing it at LSM you still have to place it in middle.
Big issue with IPv4/6 hardware direct feeding into user space you have
to get in middle to apply any forms of filters anyhow.

Ok witch zerocopy.   The one that just changes ownship between kernel
and userspace without coping.   Because that does boost performance
but makes zero alteration to how Netfilter works.  Reason when
transfered to kernel space userspace no longer can edit it anyhow.
>
> One of the first questions I would want answered is whether Socket-level MAC should be a generic solution (ie: be present regardless of what socket method the user code is using and be easily extendible across any protocol sockets support), a lightly-focussed solution (ie: be present for most socket methods and be moderately extendible across a fairly broad range of protocols) or be tightly-focussed (ie: be present on very specific types of sockets and protocols, perhaps be very tightly optimized for those, but ultimately be a royal pain to extend to anything else).
>
> Which type of solution you want will determine where would be the appropriate place to put the code. It's no use putting the code where it can't do what you want, but the only way to know that is to decide what it is you want the code to do in the first place.
>
> At present, I've seen a lot of discussion that basically agrees implementing IPv[46] for the standard case is a sensible first-pass. What I have not seen is any agreement that that should be the only pass. Linux' network stack supports a whole lot of LAN/WAN protocols besides those two and again that only covers what is supplied in the kernel as standard.
>
> This is not a trivial or academic question, because you have interdependencies in there. No matter what you pick as the right solution, there will be scenarios that solution cannot solve. Those scenarios differ between the different solutions. The danger is ignoring important cases by making assumptions that might not be valid about what the code will be used for.
>
> For example, the argument that desktop users would be the primary users of personal firewalls clearly goes against the dictum of server administration which states that servers should offer the least rights possible to get the job done, for security reasons. If servers are going to use the code as much (or more) than general users, then you are working in a completely different space with a different set of problems.

Sorry history has shown Desktop users on windows run with high user
rights.   Desktop users on Mac and Linux don't.

Its not a completely different set of problems.   Please stop trying
to draw lines in the sand between different groups.   Most critical
thing for a firewall is that it works.

Its just like the old idea that realtime OS's have nothing the same
with supercomputers.   It turns out they have a lot in common lot of
alterations to improve realtime support in Linux has increased
supercomputer though put massively.

Desktop User needs a firewall that works correctly.    Server
Administrators need the same.   Server Administrators do want simple
to configure and be sure the firewall is right.   Same with Desktop
users.

When you get right down to it there is no much difference.
>
> Orthogonal to that, are the firewalled accounts more likely to be concerned with low latency or high bandwidth? Each type of implementation has its own overheads and its own limitations, which will dictate what sort of service it can best support.
>
> Then you have the corner-cases and peculiarities. These would definitely include patches like RTNet, but also weirdness like MobileIP, Anycasting (which is asymetric - multicast one way, unicast the other, thus a different set of filters applies), clustered environments (where the firewall rules on the machine the process is active on won't be guaranteed the same as the rules on the machine the process appears to be on), Infiniband (which is extending into WAN environments, acts a lot like IPv6 and is getting a fair bit of attention at the moment) and so on.

Linux network stack was very much designed with these evils in mind.
Its highly modular it is the only way you can take this problem on.
No matter what there will be events where you need to change the
processing path completely by being modular you can.   These
corner-cases are some of the reason why I keep on saying LSM is not
the place.  Worst nightmares of the some of the corner-cases where
some applications need treatment by a completely different processing
stack to everything else.  LSM does not allow loading two modules/more
safely without risking standing on the other LSM toes.

Basically if you cannot load multiable and assign them to different
applications the design is not going to cut it in some of the corner
cases.  Realtime vs Normal is fun enough.

With clusters and shipping applications between processes supporting
it gets a little pain in but.  Most likely putting the information in
task credentials would be the sane solution then have when application
is sent between machines its task credentials go with it.
>
> Some of these we can ignore, some we will need to take into consideration, but if we don't know what Socket MAC is going to be used for, how do we know which is which?
>
I am sorry you are making exactly the same kind of argument when
people said Linux kernel could not run on desktops servers and
supercomputers from the same kernel source.   Being modular is
critical.

Way Linux network stack works you can swap the QoS section and keep on
going.   Swap every module out of netfilter and keep on going.

Unless you can make a really good argument how in heck LSM firewall
version is going to have many of its type running side by side you are
in trouble when can see another path that will allow running many side
by side.

Peter Dolding
