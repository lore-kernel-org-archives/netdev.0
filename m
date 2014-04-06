From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH net IPv6]: Fix maximum IPv6 address limit violation
Date: Sun, 06 Apr 2014 11:57:02 +0530
Message-ID: <5340F3B6.2050105@gmail.com>
References: <533FEE9B.5090806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:46843 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbaDFG1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 02:27:06 -0400
In-Reply-To: <533FEE9B.5090806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

>> Kernel doesn't check with max IPv6 address limit before adding IPv6 temporary
>> address.
>>
>> Security fix CVE-2013-0343 removes max_addresses check from ipv6_create_tempaddr
>> function as this is handled before in addrconf_prefix_rcv function. But
>> addrconf_prefix_rcv does max_addresses check only before adding MAC based RA
>> address and if limit is already reached, it stops processing the prefix.
>>
>> When IPv6 privacy extension is enabled, two addresses will be created for a
>> new prefix received through RA. So if a machine has (max_addresses - 1) number
>> of  IPv6 addresses, after receiving an RA with new prefix the machine will have
>> (max_addresses + 1) number of IPv6 addresses.
>>
>> So it is better to use a new prefix only if two IPv6 address slots available
>> in case IPv6 privacy extension is enabled.
>
> When I removed the check I did not think about any reason why the
> max_addresses must count exact. It is merely there to prevent DoS attacks.
> Is there a reason to revisit this? We don't care about locally added
> addresses and I decided to do so for temporary addresses, too, because
> only some small number will ever be generated for an autoconfigured one.
>
> Actually when rolling over privacy addresses we generate new ones before
> the old ones expire, so there could be more of those. This depends on
> the setting of the timers.
>
> IMHO we don't need this additional check and complexity or this there
> a reason I don't currently see?
>
>Thanks for the submission,
>
>  Hannes

Thanks for the explanation. I agree with your argument that the reason behind
max_addresses is to avoid DOS attack. But my humble opinion is when we impose
some constrains, we must adhere to that. I don't think adding tolerance to an
integer limit is a good policy.

And before the security fix, there was an additional check while creating
temporary address. I thought this additional check is a better way and try to
make the code behave similar.

But anyway the impact of this is very minimal or no impact at all. Thats why I
kept the severity to less. I see this patch more policy oriented than technical. So
either accepting or rejecting this is depending on 'how we code' than 'what we
code'.

Once again thanks for the detailed explanation.

Regards,
K.Balakumaran
