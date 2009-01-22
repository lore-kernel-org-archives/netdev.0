From: Jonathan Day <imipak@yahoo.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal  firewalls"
Date: Wed, 21 Jan 2009 16:50:42 -0800 (PST)
Message-ID: <504710.17436.qm@web31507.mail.mud.yahoo.com>
References: <e7d8f83e0901211528ue344783qb66e481902274961@mail.gmail.com>
Reply-To: imipak@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: rmeijer@xs4all.nl
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <e7d8f83e0901211528ue344783qb66e481902274961@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- On Wed, 1/21/09, Peter Dolding <oiaohm@gmail.com> wrote:
(snip)
> There are many ways though the Linux kernel.  This is part
> of the
> reason why I am asking why they are wanting LSM so much. 
> LSM was
> decided to be only one thing.   Not something to make more
> of if it
> can be avoided.   First rule should be seeing if API and
> Internal
> structs of Linux need fixing.  This case yes there are
> quite a few
> weaknesses in netfilter that could do with fixing.   If
> after fixing
> netfilter up it still turns out you need LSM support then
> you do have
> a valid reason.
(snip)

I agree with most of your argument (both what is quoted and what is snipped) but would be wary of any kernel-based solution for the reason I outlined in an earlier post - there are IPv4/6 stacks that sit in hardware and feed direct to userspace, and others that sit in userspace and use the zerocopy patches to minimize kernel entanglement. True, these are not the most common methods in use, and equally true, they would be just as complex to serve via LSM as by netfilter.

One of the first questions I would want answered is whether Socket-level MAC should be a generic solution (ie: be present regardless of what socket method the user code is using and be easily extendible across any protocol sockets support), a lightly-focussed solution (ie: be present for most socket methods and be moderately extendible across a fairly broad range of protocols) or be tightly-focussed (ie: be present on very specific types of sockets and protocols, perhaps be very tightly optimized for those, but ultimately be a royal pain to extend to anything else).

Which type of solution you want will determine where would be the appropriate place to put the code. It's no use putting the code where it can't do what you want, but the only way to know that is to decide what it is you want the code to do in the first place.

At present, I've seen a lot of discussion that basically agrees implementing IPv[46] for the standard case is a sensible first-pass. What I have not seen is any agreement that that should be the only pass. Linux' network stack supports a whole lot of LAN/WAN protocols besides those two and again that only covers what is supplied in the kernel as standard.

This is not a trivial or academic question, because you have interdependencies in there. No matter what you pick as the right solution, there will be scenarios that solution cannot solve. Those scenarios differ between the different solutions. The danger is ignoring important cases by making assumptions that might not be valid about what the code will be used for.

For example, the argument that desktop users would be the primary users of personal firewalls clearly goes against the dictum of server administration which states that servers should offer the least rights possible to get the job done, for security reasons. If servers are going to use the code as much (or more) than general users, then you are working in a completely different space with a different set of problems.

Orthogonal to that, are the firewalled accounts more likely to be concerned with low latency or high bandwidth? Each type of implementation has its own overheads and its own limitations, which will dictate what sort of service it can best support.

Then you have the corner-cases and peculiarities. These would definitely include patches like RTNet, but also weirdness like MobileIP, Anycasting (which is asymetric - multicast one way, unicast the other, thus a different set of filters applies), clustered environments (where the firewall rules on the machine the process is active on won't be guaranteed the same as the rules on the machine the process appears to be on), Infiniband (which is extending into WAN environments, acts a lot like IPv6 and is getting a fair bit of attention at the moment) and so on.

Some of these we can ignore, some we will need to take into consideration, but if we don't know what Socket MAC is going to be used for, how do we know which is which?

p.s. Which poster is going to be evil and start calling this Project MAC first?


      
