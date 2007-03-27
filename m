From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] [NET] fib_rules: goto rule action
Date: Mon, 26 Mar 2007 21:13:07 -0700
Message-ID: <460899D3.60808@osdl.org>
References: <20070326235450.756924134@lsx.localdomain>	<20070326235713.478149847@lsx.localdomain> <20070326.171916.104032809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37528 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932817AbXC0EN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 00:13:29 -0400
In-Reply-To: <20070326.171916.104032809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 27 Mar 2007 01:54:51 +0200
>
>   
>> This patch adds a new rule action FR_ACT_GOTO which allows
>> to skip a set of rules by jumping to another rule. The rule
>> to jump to is specified via the FRA_GOTO attribute which
>> carries a rule preference.
>>
>> Referring to a rule which doesn't exists is explicitely allowed.
>> Such goto rules are marked with the flag FIB_RULE_UNRESOLVED
>> and will act like a rule with a non-matching selector. The rule
>> will become functional as soon as its target is present.
>>
>> The goto action enables performance optimizations by reducing
>> the average number of rules that have to be passed per lookup.
>>
>> Example:
>> 0:      from all lookup local 
>> 40:     not from all to 192.168.23.128 goto 32766
>> 41:     from all fwmark 0xa blackhole
>> 42:     from all fwmark 0xff blackhole
>> 32766:  from all lookup main 
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>>     
>
> This looks excellent, applied to net-2.6.22, thanks Thomas.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

Do we have to worry about self inflicted infinite loops?
Shouldn't there be some way to some basic validation?

