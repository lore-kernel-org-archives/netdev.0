From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 13:22:09 -0700
Message-ID: <55AFFB71.5040307@cumulusnetworks.com>
References: <20150722.104926.1502608671575195516.davem@davemloft.net> <55AFEF4B.6070702@cumulusnetworks.com> <20150722195706.GA26717@pox.localdomain> <20150722.130444.1245167673786115378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33779 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbbGVUWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 16:22:11 -0400
Received: by pdbnt7 with SMTP id nt7so73037406pdb.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 13:22:11 -0700 (PDT)
In-Reply-To: <20150722.130444.1245167673786115378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/15, 1:04 PM, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 22 Jul 2015 21:57:06 +0200
>
>> On 07/22/15 at 12:30pm, roopa wrote:
>>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>>> index 5c467ef..2b28615 100644
>>> --- a/net/mpls/Kconfig
>>> +++ b/net/mpls/Kconfig
>>> @@ -24,6 +24,8 @@ config NET_MPLS_GSO
>>>
>>>   config MPLS_ROUTING
>>>          tristate "MPLS: routing support"
>>> +       depends on INET
>>> +       depends on IPV6
>>>          ---help---
>>>           Add support for forwarding of mpls packets.
>> This looks like a much better fix to me and resolves the
>> module/built-in dependency mess.
> It's only OK if we don't create a new hard dependency on IPV6,
> which this patch does.
>
> Consitently across the tree we give the user the option of
> using a bi-AF facility with or without IPV6.
yes, ack. I have been trying to avoid that ...also because
af_mpls does support a family AF_PACKET mode that should continue to 
work without CONFIG_INET and CONFIG_INET6
(Though I have not tried it).
