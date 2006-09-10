From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Sun, 10 Sep 2006 05:48:02 -0600
Message-ID: <m14pvgeydp.fsf_-_@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060910024709.GA13157@MAIL.13thfloor.at>
	<m14pvggzgw.fsf@ebiederm.dsl.xmission.com>
	<200609101211.35834.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49794 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1750920AbWIJLtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 07:49:32 -0400
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200609101211.35834.dim@openvz.org> (Dmitry Mishin's message of
	"Sun, 10 Sep 2006 12:11:35 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Sunday 10 September 2006 07:41, Eric W. Biederman wrote:
>> I certainly agree that we are not at a point where a final decision
>> can be made.  A major piece of that is that a layer 2 approach has
>> not shown to be without a performance penalty.
> But it is required. Why to limit possible usages?

Wrong perspective.

The point is that we need to dig in and show that there is no
measurable penalty for the current cases.  Showing that there
is little penalty for the advanced configurations is a plus.

The practical question is, do we need to implement the grand unified
lookup before we can do this cheaply, or can we implement this without
needing that optimization?

To get a perspective, to get a good implementation of the pid namespace
I am having to refactor significant parts of the kernel so it uses
abstractions that can cleanly express what we are doing.  The
networking stack is in better shape but there is a lot of it. 

>> A practical question.  Do the IPs assigned to guests ever get used
>> by anything besides the guest?
> In case of level2 virtualization - no.

Actually that is one of the benefits of a layer 2 implementation
you can set up weird things like shared IPs, that various types
of fail over scenarios want.

My question was really about the layer 3 bind filtering techniques,
and how people are using them.

The basic attraction with layer 3 is that you can do a simple
implementation, and it will run very fast, and it doesn't need
to conflict with the layer 2 work at all.  If you can make that layer
3 implementation clean and generally mergeable  as well it is worth
pursuing.

Eric
