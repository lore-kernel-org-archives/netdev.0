From: Ben Greear <greearb@candelatech.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 16:25:17 -0700
Message-ID: <4AEB75DD.8050204@candelatech.com>
References: <20091030152054.GA7936@gondor.apana.org.au>	<4AEB06E6.6020206@gmail.com>	<fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com> <m1639wmq1f.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33487 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933006AbZJ3XZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 19:25:29 -0400
In-Reply-To: <m1639wmq1f.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2009 04:15 PM, Eric W. Biederman wrote:

>> If ip_conntrack does not consider vlans, it is possible that all 5
>> tuple are the same
>> and thus affect the connection tracking.
>>
>> I hope I have described the scenario well. If not I can explain in a
>> more detailed fashion.
>
> Unless you have multiple network namespaces linux assumes all packets are
> in the same ip space.  And 10.10.10.1 is the same machine no matter
> which interface you talk to it on.

It only takes a relatively small patch that lets conn-track hash on a
skb->foo_mark, and allow that mark to be set on incoming packets
based on netdevice or whatever, (before the conn-track lookup is
done).

This is logically somewhat similar to using multiple routing
tables and has been working well for me for several years....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

