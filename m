From: Stephan Peijnik <stephan@peijnik.at>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
	firewalls"
Date: Wed, 21 Jan 2009 00:48:41 +0100
Message-ID: <1232495321.24943.149.camel@sp-laptop3.sp-local>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
	 <200901201547.44981.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200901201547.44981.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-01-20 at 15:47 -0500, Paul Moore wrote:
> Another option that was brought up (although perhaps not very clearly 
> since it isn't listed here) was the embedding of the personal firewall 
> hooks into the individual LSMs roughly similar to how capabilities are 
> handled with SELinux today (a separate security mechanism that has 
> explicit calls within SELinux).  This approach enables the use of 
> current LSMs (although minor modifications will be needed) and avoids 
> the need to add new hooks to the core network stack.

Sorry for not adding that one, I think you sent that email after I
finished writing the summary and that's why it wasn't included in the
first place.
This is another way of doing it, yes, but in the end we would probably
end up writing additional wrapper like code with the only purpose of
being called by <insert favorite LSM here> and then forwarding that call
to <insert favorite personal firewall here>.
To have multiple approaches working we would probably need
register/unregister functions for that wrapper and, to be honest, to me
this sounds like a more complicated version of doing the calls to the
wrapper directly from net/socket.c. The outcome is pretty much the same
though.

> > What has not been agreed on yet is whether only a way of hooking
> > these calls should be made available to implementations or whether
> > the whole in-kernel part should be developed together and allow
> > implementations of personal firewalls in userspace only, for example
> > using a netlink socket to communicate with the shared in-kernel code.
> 
> Since there will always be a significant userspace component to any 
> personal firewall approach it seems reasonable to push the decision 
> making into userspace and leave the kernel component relatively simple.  
> The basic idea behind Samir's "snet" concept where the kernel simply 
> passes messages to userspace and waits for a verdict seems like a 
> reasonable approach in that it can be made to support different 
> personal firewall implementations/designs without significant changes 
> to the kernel.

I can only agree on that. However, providing a single solution that
cannot be extended dynamically (think of adding support for additional
protocols, implementing some sort of policy caching, etc.) might be the
wrong way to go.
We would end up having a solution and whilst I really like the snet
approach we would lose some flexibility.
This very approach on the other hand seems to work very well for
netfilter and we would end up with keeping all those personal firewall
developers out of the kernel.

-- Stephan

