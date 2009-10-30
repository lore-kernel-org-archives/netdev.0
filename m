From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 10:33:37 +0100
Message-ID: <4AEAB2F1.5070200@trash.net>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>	<1256861906-5059-5-git-send-email-ebiederm@xmission.com>	<4AEAA403.7080204@trash.net> <m1eiols0a4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39282 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003AbZJ3Jdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 05:33:43 -0400
In-Reply-To: <m1eiols0a4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> Eric W. Biederman wrote:
>>> +static struct rtnl_link_ops bond_link_ops __read_mostly = {
>>> +	.kind		= "bond",
>>> +	.setup		= bond_setup,
>>> +	.validate	= bond_validate,
>>> +};
>> One more thing - you need to initialize .priv_size here so
>> the devices created through rtnl_link have enough private
>> room allocated.
> 
> Wow and the code works when I test it without that ouch!
> 
> As for rtnl_link_register it always succeeds so let's just
> remove the return code and call it good.

You need unroll anyways for the other failure conditions, so
why not simply add an err1/2 and be safe for future changes?
