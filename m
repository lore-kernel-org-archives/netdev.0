From: Ben Greear <greearb@candelatech.com>
Subject: Re: radvd and auto-ipv6 address regression from 2.6.31 to 2.6.34+
Date: Tue, 09 Nov 2010 10:07:38 -0800
Message-ID: <4CD98DEA.4090508@candelatech.com>
References: <4CD47622.5040507@candelatech.com> <4CD48FB4.2050903@candelatech.com> <alpine.DEB.1.10.1011060713290.2639@uplift.swm.pp.se> <4CD81D24.1040609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mikael Abrahamsson <swmike@swm.pp.se>,
	NetDev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41172 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664Ab0KISHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:07:47 -0500
In-Reply-To: <4CD81D24.1040609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2010 07:54 AM, Brian Haley wrote:
> On 11/06/2010 02:17 AM, Mikael Abrahamsson wrote:
>> I would not be surprised if the IPv6 stack on Linux would gain IPv6
>> addresses using SLAAC from any interface if it sees RAs on it,
>> regardless if these are locally generated or not.
>>
>> I guess any Linux device running radvd should turn off autoconf on those
>> interface that radvd is acting on?
>>
>> net.ipv6.conf.veth0.accept_ra=0 should do the trick?
>
> I believe radvd will turn-on IPv6 forwarding on all the interfaces, at
> least it does on Debian in /etc/init.d/radvd, which essentially disables
> the reception of RA's for address configuration purposes.  I'm curious
> what these values are set to, and if something just got missed.
>
> It might be something specific to veth too, not sure how packets are
> copied/looped-back on these devices from the stack.

Thanks for the hint.  I did not have ipv6 forwarding enabled for the
radvd interfaces.  Once I fixed that, it worked as expected with no
auto-created global IPv6 address.  I have been starting radvd manually,
so I wouldn't benefit from any OS specific start scripts.

Thanks,
Ben

>
> -Brian


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

