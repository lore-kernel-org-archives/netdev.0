From: Paul Moore <paul.moore@hp.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Wed, 21 Jan 2009 09:49:41 -0500
Message-ID: <200901210949.42056.paul.moore@hp.com>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local> <200901201547.44981.paul.moore@hp.com> <1232495321.24943.149.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-security-module" <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephan Peijnik <stephan@peijnik.at>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1232495321.24943.149.camel@sp-laptop3.sp-local>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 January 2009 6:48:41 pm Stephan Peijnik wrote:
> On Tue, 2009-01-20 at 15:47 -0500, Paul Moore wrote:
> > Another option that was brought up (although perhaps not very
> > clearly since it isn't listed here) was the embedding of the
> > personal firewall hooks into the individual LSMs roughly similar to
> > how capabilities are handled with SELinux today (a separate
> > security mechanism that has explicit calls within SELinux).  This
> > approach enables the use of current LSMs (although minor
> > modifications will be needed) and avoids the need to add new hooks
> > to the core network stack.
>
> Sorry for not adding that one, I think you sent that email after I
> finished writing the summary and that's why it wasn't included in the
> first place.
> This is another way of doing it, yes, but in the end we would
> probably end up writing additional wrapper like code with the only
> purpose of being called by <insert favorite LSM here> and then
> forwarding that call to <insert favorite personal firewall here>.

That is pretty much my point.  Provide a personal firewall mechanism 
with a well defined API that LSMs can call as necessary.  The personal 
firewall code then notifies a userspace agent over another well defined 
API (netfilter, etc.) and waits for a verdict response.

I've mentioned this approach several times now (perhaps poorly?), if 
there is something you don't understand in my suggestion please let me 
know.  I'm also getting sick of typing "personal firewall" all the 
time, we need a shorter name and I'm going to start calling 
it "pfwall" :)

> To have multiple approaches working we would probably need
> register/unregister functions ...

Why?  You don't need to "register" with the LSM and you don't need 
to "register" with userspace.

> for that wrapper and, to be honest, to me this sounds like a more
> complicated version of doing the calls to the wrapper directly from
> net/socket.c ...

Personal preference I suppose, although I am very confident that the 
option described above (LSM calling the pfwall) has a much better 
chance of acceptance that an option which involves hooking the core 
network stack.

> > > What has not been agreed on yet is whether only a way of hooking
> > > these calls should be made available to implementations or
> > > whether the whole in-kernel part should be developed together and
> > > allow implementations of personal firewalls in userspace only,
> > > for example using a netlink socket to communicate with the shared
> > > in-kernel code.
> >
> > Since there will always be a significant userspace component to any
> > personal firewall approach it seems reasonable to push the decision
> > making into userspace and leave the kernel component relatively
> > simple. The basic idea behind Samir's "snet" concept where the
> > kernel simply passes messages to userspace and waits for a verdict
> > seems like a reasonable approach in that it can be made to support
> > different personal firewall implementations/designs without
> > significant changes to the kernel.
>
> I can only agree on that. However, providing a single solution that
> cannot be extended dynamically (think of adding support for
> additional protocols, implementing some sort of policy caching, etc.)
> might be the wrong way to go.

Explain what you mean by "dynamically" and give an example.

> We would end up having a solution and whilst I really like the snet
> approach we would lose some flexibility.

As I mentioned before in the previous thread, please list and explain 
all your requirements and we can work to arrive at a solution which 
meets those needs.  When possible we should work to develop solutions 
which are as flexible as possible, but flexibility for the sake of 
flexibility often results in unnecessary complexity which is rarely a 
good thing.

-- 
paul moore
linux @ hp
