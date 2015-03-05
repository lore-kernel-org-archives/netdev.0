From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/7] mpls: Add a sysctl to control the size of the mpls label table
Date: Thu, 05 Mar 2015 07:22:46 -0600
Message-ID: <878ufbh93t.fsf@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<87egp5tvlz.fsf_-_@x220.int.ebiederm.org>
	<CAMs_D1-Ohar0CbgaB08jM0iGcORJxx_B9Ta778nd4m5unT6wMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: Vivek Venkatraman <vivek@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50126 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbbCEN0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 08:26:21 -0500
In-Reply-To: <CAMs_D1-Ohar0CbgaB08jM0iGcORJxx_B9Ta778nd4m5unT6wMg@mail.gmail.com>
	(Vivek Venkatraman's message of "Thu, 5 Mar 2015 01:45:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Venkatraman <vivek@cumulusnetworks.com> writes:

> On Tue, Mar 3, 2015 at 5:11 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>>
>> This sysctl gives two benefits.  By defaulting the table size to 0
>> mpls even when compiled in and enabled defaults to not forwarding
>> any packets.  This prevents unpleasant surprises for users.
>>
>> The other benefit is that as mpls labels are allocated locally a dense
>> table a small dense label table may be used which saves memory and
>> is extremely simple and efficient to implement.
>>
>
> The label space is often partitioned into multiple sets in MPLS and
> used for different purposes - for example, LSP labels, VPN labels,
> Segment labels. This in turn means that the table may no longer be
> dense. A sysctl allowing min and max label that spans the sets of
> labels may be useful. Or should the ILM be made a hash table?

Good question.

These kinds of labels are a local label management problem.

Given how nice it is to have a reasonably dense label space I am not
keen to abandon the notion of having a dense label space, as it makes
the code simple and fast for forwarding mpls packets.

That said my code is a starting point.  If you have a real world use
case and you can show a better way to deal with it.  Go for it.
Now is definitely time to evolve the API.

Eric
