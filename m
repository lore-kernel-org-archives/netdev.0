From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] net: ipv4: add support for ECMP hash policy
 choice
Date: Fri, 17 Mar 2017 12:06:29 +0200
Message-ID: <7c4dfadc-641c-11df-2dfd-b153b791f00f@cumulusnetworks.com>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
 <1489670880-12717-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170316094152.0ac70537@xeon-e3>
 <bfbac5ad-4b0d-0095-42b1-e8bdd7c46a23@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jkbs@redhat.com, edumazet@google.com, pch@ordbogen.com,
        nicolas.dichtel@6wind.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34714 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdCQKGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 06:06:33 -0400
Received: by mail-wr0-f169.google.com with SMTP id l37so48743945wrc.1
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 03:06:31 -0700 (PDT)
In-Reply-To: <bfbac5ad-4b0d-0095-42b1-e8bdd7c46a23@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/03/17 18:49, Nikolay Aleksandrov wrote:
> On 16/03/17 18:41, Stephen Hemminger wrote:
>> On Thu, 16 Mar 2017 15:28:00 +0200
>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>
>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>>> index d6880a6149ee..62c4f94923e5 100644
>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>> @@ -1004,6 +1004,15 @@ static struct ctl_table ipv4_net_table[] = {
>>>  		.extra1		= &zero,
>>>  		.extra2		= &one,
>>>  	},
>>> +	{
>>> +		.procname	= "fib_multipath_hash_policy",
>>> +		.data		= &init_net.ipv4.sysctl_fib_multipath_hash_policy,
>>> +		.maxlen		= sizeof(int),
>>> +		.mode		= 0644,
>>> +		.proc_handler	= proc_dointvec_minmax,
>>> +		.extra1		= &zero,
>>> +		.extra2		= &one,
>>> +	
>>
>> Rather than having magic integer values, it would be better to use
>> strings (like TCP congestion control).  Especially if you want to support
>> more values in the future.
> 
> With strings we'll need two sysctls - one to export the available ones, and one to set.
> I too am not happy with plain integers as I've said in v1 of this patch but if people
> are okay with having two new sysctls exported then I don't mind reworking it with strings.
> Or any other ideas are welcome.
> 
>>
>> Also what about IPv6?
>>
> 
> Patches are welcome, too. :-)
> We can update it at any time, IPv4 and 6 have been different for a very long time
> and it's not the point of this patch to bring them closer, though IPv6 already
> does L4 by default.

Just to clarify, we're interested in getting IPv4 and 6 on the same level and will
work towards that but let's take it a step at a time.

 
