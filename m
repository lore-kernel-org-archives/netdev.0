From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 4/7] mpls: Basic support for adding and removing routes
Date: Thu, 05 Mar 2015 05:54:50 -0600
Message-ID: <87y4nbk6b9.fsf@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<878ufdtvjr.fsf_-_@x220.int.ebiederm.org>
	<54F6BEAA.2080708@cumulusnetworks.com>
	<87h9u0lctq.fsf@x220.int.ebiederm.org>
	<20150304215006.019f1eaffaf3e0bfa53aadcf@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:44488 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbCEL61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 06:58:27 -0500
In-Reply-To: <20150304215006.019f1eaffaf3e0bfa53aadcf@mindspring.com> (Bill
	Fink's message of "Wed, 4 Mar 2015 21:50:06 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink@mindspring.com> writes:

> On Wed, 04 Mar 2015, Eric W. Biederman wrote:
>
>> roopa <roopa@cumulusnetworks.com> writes:
>> 
>> > On 3/3/15, 5:12 PM, Eric W. Biederman wrote:
>> >> +	/* Append makes no sense with mpls */
>> >> +	err = -EINVAL;
>> >
>> > minor nit: should this be -ENOTSUPP in that case ? (NLM_F_REPLACE and NLM_F_APPEND are
>> > really operations. But, one can argue that they are an attribute of the msg and hence -EINVAL might be ok).
>> > I did not find any other such case for consistency check.
>> 
>> Yes.  IPv4 implements NLM_F_APPEND and IPv6 ignores it.
>> 
>> I will add a patch to change the error code.
>
> I believe the error -ENOTSUPP is deprecated and -EOPNOTSUPP should
> be used instead.

Ack.

In particular ENOTSUPP is not allowed to make it to user space while
EOPNOTSUPP is.

Which makes me a little leary when I grep the kernel code and I see so
may uses of ENOTSUPP in the kernel when I grep for it.

Eric
