From: Samir Bellabes <sam@synack.fr>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Wed, 21 Jan 2009 09:18:06 +0100
Message-ID: <m2sknd139d.fsf@ssh.synack.fr>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
	<200901201547.44981.paul.moore@hp.com>
	<1232495321.24943.149.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephan Peijnik <stephan@peijnik.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:46126 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbZAUISJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:18:09 -0500
In-Reply-To: <1232495321.24943.149.camel@sp-laptop3.sp-local> (Stephan
	Peijnik's message of "Wed, 21 Jan 2009 00:48:41 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Peijnik <stephan@peijnik.at> writes:

> On Tue, 2009-01-20 at 15:47 -0500, Paul Moore wrote:
>> Another option that was brought up (although perhaps not very clearly 
>> since it isn't listed here) was the embedding of the personal firewall 
>> hooks into the individual LSMs roughly similar to how capabilities are 
>> handled with SELinux today (a separate security mechanism that has 
>> explicit calls within SELinux).  This approach enables the use of 
>> current LSMs (although minor modifications will be needed) and avoids 
>> the need to add new hooks to the core network stack.
>
> Sorry for not adding that one, I think you sent that email after I
> finished writing the summary and that's why it wasn't included in the
> first place.
> This is another way of doing it, yes, but in the end we would probably
> end up writing additional wrapper like code with the only purpose of
> being called by <insert favorite LSM here> and then forwarding that call
> to <insert favorite personal firewall here>.
> To have multiple approaches working we would probably need
> register/unregister functions for that wrapper and, to be honest, to me
> this sounds like a more complicated version of doing the calls to the
> wrapper directly from net/socket.c. The outcome is pretty much the same
> though.

Please, again, this as nothing to do with personal firewall.
The same problem remain if I want to write the same tool related to
filesystem.
We should definitly stop using 'personal firewall' as a excuse.
We just want a simple way to enable another security model. And you
should known that we already have the "security=" boot param [1]

So now the good question is what are we going to do when using a
personal firewall based on LSM, for the others non-related network
syscalls ? 

>> > What has not been agreed on yet is whether only a way of hooking
>> > these calls should be made available to implementations or whether
>> > the whole in-kernel part should be developed together and allow
>> > implementations of personal firewalls in userspace only, for example
>> > using a netlink socket to communicate with the shared in-kernel code.
>> 
>> Since there will always be a significant userspace component to any 
>> personal firewall approach it seems reasonable to push the decision 
>> making into userspace and leave the kernel component relatively simple.  
>> The basic idea behind Samir's "snet" concept where the kernel simply 
>> passes messages to userspace and waits for a verdict seems like a 
>> reasonable approach in that it can be made to support different 
>> personal firewall implementations/designs without significant changes 
>> to the kernel.
>
> I can only agree on that. However, providing a single solution that
> cannot be extended dynamically (think of adding support for additional
> protocols, implementing some sort of policy caching, etc.) might be the
> wrong way to go.

Providing dynamical support for next unknown protocols ?.. hum I'm
losing myself, and I hope to misunderstand you thought.

anyway, you can propose patches on snet to do that.

I already thought about a policy caching, even a 'verdict to rules'
caching. But you can implement the policy caching from the userspace.
And this won't work:

1. syscall A on protocol Y
2. look inside cache for verdict -> found nothing
3. ask userspace
4. kernel get a verdict, apply the verdict, put the verdict on cache.
5. same syscall and protocol as in 1
6. look inside cache -> apply cache verdict

what if the user changes it's rules between 4 and 5 ?
Yes, I known we won't change rules every seconds. we can clear the
cache. 
But this are implementation details, and we can easy move snet to have
this feature.

Also, how will you build a cache for a such informations ?
We surely want to cache the rule we match.

But anyway caching is regarding only some syscalls (as connect(),
recvmsg(), sendmsg())

And here we start speaking about how to build a personal firewall. And
this is exactly what I don't want. snet is here to let you have all the
freedom for this question. What if someone else don't want a policy
cache ? we put some param to enable or disable it ? No, the best way is
to let userspace do what he wants. 

sam

[1] http://lwn.net/Articles/271585/
