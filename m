From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 03:00:56 -0700
Message-ID: <m1skd1qjzb.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<1256861906-5059-5-git-send-email-ebiederm@xmission.com>
	<4AEAA403.7080204@trash.net> <m1eiols0a4.fsf@fess.ebiederm.org>
	<4AEAB2F1.5070200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52620 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756816AbZJ3KAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 06:00:54 -0400
In-Reply-To: <4AEAB2F1.5070200@trash.net> (Patrick McHardy's message of "Fri\, 30 Oct 2009 10\:33\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>> 
>>> Eric W. Biederman wrote:
>>>> +static struct rtnl_link_ops bond_link_ops __read_mostly = {
>>>> +	.kind		= "bond",
>>>> +	.setup		= bond_setup,
>>>> +	.validate	= bond_validate,
>>>> +};
>>> One more thing - you need to initialize .priv_size here so
>>> the devices created through rtnl_link have enough private
>>> room allocated.
>> 
>> Wow and the code works when I test it without that ouch!
>> 
>> As for rtnl_link_register it always succeeds so let's just
>> remove the return code and call it good.
>
> You need unroll anyways for the other failure conditions, so
> why not simply add an err1/2 and be safe for future changes?

Not a real problem.  I was just thinking of things like the
dummy driver that have this same issue and the fact that since
rtnl_link_register never fails we never test the error path.
So it would be much less error prone and less code to remove
the possibility of rtnl_link_register failing.

Eric


