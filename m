From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Mon, 29 Oct 2012 17:21:46 -0700
Message-ID: <87a9v47qsl.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org>
	<87ip9zqqlv.fsf@xmission.com> <20121025143811.GH15034@kvack.org>
	<20121025092105.5119b8bf@nehalam.linuxnetplumber.net>
	<877gqb883y.fsf@xmission.com>
	<20121029072341.158e6412@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benjamin LaHaise <bcrl@kvack.org>, rsa <ravi.mlists@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45714 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab2J3AVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 20:21:53 -0400
Cc: James Chapman <jchapman@katalix.com>
In-Reply-To: <20121029072341.158e6412@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 29 Oct 2012 07:23:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Sat, 27 Oct 2012 22:43:13 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Stephen Hemminger <shemminger@vyatta.com> writes:
>> 
>> > I noticed that the L2TP sockets are not being moved to the correct name
>> > space.
>> >
>> > Something like this is probably needed.
>> 
>> This is almost right.
>> 
>> There needs to be a line in l2tp_tunnel_create that verifies
>> the network namespace of the socket derived from a file descriptor
>> and the passed in network namespace match.
>> 
>> For the l2tp_tunnel_sock_create case where we have a socket that is not
>> exported to userspace using sk_change_net seems appropriate to avoid
>> reference counting problems.  And it may be worth moving that work into
>> sk_create_kern.  But we need a network namespace hook that will lookup
>> all l2tp tunnel sockets when a network namespace is being destroyed and
>> remove them.  I think we can hit this bug with rmmod as well.
>
> Since I don't use netns or L2TP for real, someone else needs to take
> up the crusade here.

Let's see if James Chapman is interested.  I don't use L2TP for real either.

James are you at all interested in the network namespace bugs that have
been found in the l2tp code?

Eric
