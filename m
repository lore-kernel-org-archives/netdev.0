From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 16:56:49 -0600
Message-ID: <m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
	<20070623.135737.22037347.davem@davemloft.net>
	<467D9B8F.2050403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	yoshfuji@linux-ipv6.org, containers@lists.osdl.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48945 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbXFWW5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 18:57:55 -0400
In-Reply-To: <467D9B8F.2050403@garzik.org> (Jeff Garzik's message of "Sat, 23
	Jun 2007 18:15:43 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> writes:

> David Miller wrote:
>> I don't accept that we have to add another function argument
>> to a bunch of core routines just to support this crap,
>> especially since you give no way to turn it off and get
>> that function argument slot back.
>>
>> To be honest I think this form of virtualization is a complete
>> waste of time, even the openvz approach.
>>
>> We're protecting the kernel from itself, and that's an endless
>> uphill battle that you will never win.  Let's do this kind of
>> stuff properly with a real minimal hypervisor, hopefully with
>> appropriate hardware level support and good virtualized device
>> interfaces, instead of this namespace stuff.
>
> Strongly seconded.  This containerized virtualization approach just bloats up
> the kernel for something that is inherently fragile and IMO less secure --
> protecting the kernel from itself.
>
> Plenty of other virt approaches don't stir the code like this, while
> simultaneously providing fewer, more-clean entry points for the virtualization
> to occur.

Wrong.  I really don't want to get into a my virtualization approach is better
then yours.  But this is flat out wrong.

99% of the changes I'm talking about introducing are just:
- variable 
+ ptr->variable

There are more pieces mostly with when we initialize those variables but
that is the essence of the change.

And as opposed to other virtualization approaches so far no one has been
able to measure the overhead.  I suspect there will be a few more cache
line misses somewhere but they haven't shown up yet.

If the only use was strong isolation which Dave complains about I would
concur that the namespace approach is inappropriate.  However there are
a lot other uses.

Eric
