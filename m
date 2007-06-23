From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 11:55:09 -0600
Message-ID: <m1zm2q8sjm.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com>
	<20070623102640.6f111d7e@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36518 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbXFWSTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 14:19:08 -0400
In-Reply-To: <20070623102640.6f111d7e@oldman> (Stephen Hemminger's message of
	"Sat, 23 Jun 2007 10:26:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> On Sat, 23 Jun 2007 08:20:40 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>
>> Patrick McHardy wrote:
>> > Eric W. Biederman wrote:
>> >   
>> >> -- The basic design
>> >>
>> >> There will be a network namespace structure that holds the global
>> >> variables for a network namespace, making those global variables
>> >> per network namespace.
>> >>
>> >> One of those per network namespace global variables will be the
>> >> loopback device.  Which means the network namespace a packet resides
>> >> in can be found simply by examining the network device or the socket
>> >> the packet is traversing.
>> >>
>> >> Either a pointer to this global structure will be passed into
>> >> the functions that need to reference per network namespace variables
>> >> or a structure that is already passed in (such as the network device)
>> >> will be modified to contain a pointer to the network namespace
>> >> structure.
>> >>     
>> >
>> >
>> > I believe OpenVZ stores the current namespace somewhere global,
>> > which avoids passing the namespace around. Couldn't you do this
>> > as well?
>
> Maybe the current namespace should be attached to something else
> like sysfs root? Having multiple namespace indirection possiblities
> leads to interesting cases where current namespace is not correctly
> associated with current sysfs tree or current proc tree, ...

Yes.  There are some oddities there.  

In my current tree there is code that makes proc and sysfs match the inspecting
process.

I haven't quite solved the inspection problem where we want to look at
the namespace of a different process.  But as long as we have clean
code to do the basics that isn't a big leap when we come to it.

I'm not really seeing any problems along this line at this point.

The big problem at this point is code review and merging, and in
particular breaking this work up into small enough pieces that they
can be digested, successfully code reviewed and merged.

Eric
