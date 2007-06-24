From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 21:28:44 -0400
Message-ID: <467DC8CC.3020002@garzik.org>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>	<20070623.135737.22037347.davem@davemloft.net>	<467D9B8F.2050403@garzik.org> <m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	yoshfuji@linux-ipv6.org, containers@lists.osdl.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41440 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbXFXB2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 21:28:53 -0400
In-Reply-To: <m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Jeff Garzik <jeff@garzik.org> writes:
> 
>> David Miller wrote:
>>> I don't accept that we have to add another function argument
>>> to a bunch of core routines just to support this crap,
>>> especially since you give no way to turn it off and get
>>> that function argument slot back.
>>>
>>> To be honest I think this form of virtualization is a complete
>>> waste of time, even the openvz approach.
>>>
>>> We're protecting the kernel from itself, and that's an endless
>>> uphill battle that you will never win.  Let's do this kind of
>>> stuff properly with a real minimal hypervisor, hopefully with
>>> appropriate hardware level support and good virtualized device
>>> interfaces, instead of this namespace stuff.
>> Strongly seconded.  This containerized virtualization approach just bloats up
>> the kernel for something that is inherently fragile and IMO less secure --
>> protecting the kernel from itself.
>>
>> Plenty of other virt approaches don't stir the code like this, while
>> simultaneously providing fewer, more-clean entry points for the virtualization
>> to occur.
> 
> Wrong.  I really don't want to get into a my virtualization approach is better
> then yours.  But this is flat out wrong.

> 99% of the changes I'm talking about introducing are just:
> - variable 
> + ptr->variable
> 
> There are more pieces mostly with when we initialize those variables but
> that is the essence of the change.

You completely dodged the main objection.  Which is OK if you are 
selling something to marketing departments, but not OK

Containers introduce chroot-jail-like features that give one a false 
sense of security, while still requiring one to "poke holes" in the 
illusion to get hardware-specific tasks accomplished.

The capable/not-capable model (i.e. superuser / normal user) is _still_ 
being secured locally, even after decades of work and whitepapers and 
audits.

You are drinking Deep Kool-Aid if you think adding containers to the 
myriad kernel subsystems does anything besides increasing fragility, and 
decreasing security.  You are securing in-kernel subsystems against 
other in-kernel subsystems.  superuser/user model made that difficult 
enough... now containers add exponential audit complexity to that.  Who 
is to say that a local root does not also pierce the container model?


> And as opposed to other virtualization approaches so far no one has been
> able to measure the overhead.  I suspect there will be a few more cache
> line misses somewhere but they haven't shown up yet.
> 
> If the only use was strong isolation which Dave complains about I would
> concur that the namespace approach is inappropriate.  However there are
> a lot other uses.

Sure there are uses.  There are uses to putting the X server into the 
kernel, too.  At some point complexity and featuritis has to take a back 
seat to basic sanity.

	Jeff


