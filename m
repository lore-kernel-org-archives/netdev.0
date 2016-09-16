From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Disable forwarding per interface via sysctl
Date: Fri, 16 Sep 2016 17:25:38 +0100
Message-ID: <c4d02e08-12e9-dd0b-5ab2-70857b898e11@brocade.com>
References: <1474030076-24809-1-git-send-email-mmanning@brocade.com>
 <1474033192.22679.67.camel@edumazet-glaptop3.roam.corp.google.com>
 <188dbf56-c09c-259b-4e10-0e331c4be880@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41729 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935745AbcIPQ0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 12:26:51 -0400
In-Reply-To: <188dbf56-c09c-259b-4e10-0e331c4be880@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2016 04:46 PM, Hannes Frederic Sowa wrote:
> On 16.09.2016 15:39, Eric Dumazet wrote:
>> On Fri, 2016-09-16 at 13:47 +0100, Mike Manning wrote:
>>> Disabling forwarding per interface via sysctl continues to allow
>>> forwarding. This is contrary to the sysctl documentation stating that
>>> the forwarding sysctl is per interface, whereas currently it is only
>>> the sysctl for all interfaces that has an effect on forwarding. The
>>> solution is to drop any received packets instead of forwarding them
>>> if the ingress device has a per-device forwarding sysctl that is unset.
>>
>> Some archaeological research might be needed because
>> Documentation/networking/ip-sysctl.txt states :
>>
>> IPv4 and IPv6 work differently here; e.g. netfilter must be used
>> to control which interfaces may forward packets and which not.
>>
>> If this netfilter requirement is obsolete, then your patch would need to
>> change the doc as well.
>>
>> Hannes can probably comment on this ?
> 
> Yep, thanks.
> 
> This commit breaks a very common setup: people globally enabled
> forwarding but disabled the forwarding knob on one special interface to
> allow this interface to participate in auto configuration from their
> provider while still forwarding packets over this interface.
> 
> I fear this is so common that this would be a uapi violation.
> 
> Thanks,
> Hannes
> 
> 
Thanks for the use-case, I request to withdraw this patch then.
So configuring an interface on a router to be in host mode is not actually
disabling forwarding in the kernel, it is merely to allow SLAAC. Using ip6tables
for the purpose of disabling forwarding on an interface if one wants an interface
in host mode seems a heavyweight solution to work around this. If anyone has
any better suggestions, please let me know. 
