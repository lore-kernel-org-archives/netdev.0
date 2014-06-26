From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Thu, 26 Jun 2014 05:10:13 -0700
Message-ID: <87k383lvmi.fsf@x220.int.ebiederm.org>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
	<87d2dwsfh6.fsf@x220.int.ebiederm.org>
	<CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
	<87lhskpizv.fsf@x220.int.ebiederm.org>
	<20140626061438.GA2889@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47481 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbaFZMNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 08:13:31 -0400
In-Reply-To: <20140626061438.GA2889@unicorn.suse.cz> (Michal Kubecek's message
	of "Thu, 26 Jun 2014 08:14:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Kubecek <mkubecek@suse.cz> writes:

> On Wed, Jun 25, 2014 at 06:17:08PM -0700, Eric W. Biederman wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>> 
>> > On Wed, Jun 25, 2014 at 5:04 PM, Eric W. Biederman
>> > <ebiederm@xmission.com> wrote:
>> 
>> >> The only thing I see that you can gain by this work is getting around
>> >> global limits on neighbor table size.  Something that I think is most
>> >> unwise.
>> >
>> > Yes, this is one the benefits.
>> 
>> I disagree that removing a global DOS prevention check is a benefit.
>
> Network namespaces are often used for e.g. LXC containers. In such case,
> it would IMHO make sense if reaching the limits in one container didn't
> affect other containers or the host system.

I agree it would be good if one network namespace could not DOS
another.   It has even happened once or twice.  Probably the most
siginificant ways is when people create lots of network namespaces
(think 100s) and with just one or two neighbour tables per network
namespace exhaust the global neighbour limit.

However even in that case we don't want to remove the global limit and
allow ways to DOS the host that are not possible today.

I think there is some real potential in improving the neighbour cache.
We can DOS a system that is plugged into two networks by having an arp
flood of say 10,000 hosts on one interface that makes the other
interface useless.

Anyone who cares about ipv6 probably also wants to take a good hard look
at the neighbour table.  One documented attack on an ipv6 router is to
try to talk to each host in a /64 in turn.  To avoid that class of
problem ipv4 subnets are typically kept small, and that isn't a
realistic option in ipv6 for anyting except point to point links.

Which means there is a lot of room too improve how the neighbour table
behaves in a meaningful way.  I would be very happy to review patches
that make the neighbour cache better for everyone.  Figuring out how
to cleanly remove a lock sounds like one way.  Figuring out how to shape
the data structures and the limits so that a system stays performant and
is resistant to DOS attacks when a machine is connected to lots of
networks is another way.

Eric
