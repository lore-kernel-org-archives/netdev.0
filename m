From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Thu, 1 Sep 2016 15:58:04 +0200
Message-ID: <bf16f236-174e-7d1b-2b93-071552840995@6wind.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
 <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be>
 <9a7b8a77-5832-1038-00f8-b24f8e7b8d4c@6wind.com>
 <57C828EC.60501@uclouvain.be>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Lebrun <david.lebrun@uclouvain.be>, netdev@vger.kernel.org,
        netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33404 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932942AbcIAN6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:58:08 -0400
Received: by mail-wm0-f47.google.com with SMTP id v143so3820306wmv.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 06:58:08 -0700 (PDT)
In-Reply-To: <57C828EC.60501@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/09/2016 à 15:11, David Lebrun a écrit :
> On 08/31/2016 04:51 PM, Nicolas Dichtel wrote:
[snip]
>>> +config IPV6_SEG6
>>> +	bool "IPv6: Segment Routing support"
>>> +	depends on IPV6
>>> +	---help---
>>> +	  Experimental support for IPv6 Segment Routing dataplane as defined
>>> +	  in IETF draft-ietf-6man-segment-routing-header-01. This option
>>> +	  enables the processing of SR-enabled packets allowing the kernel
>>> +	  to act as a segment endpoint (intermediate or egress).
>>> +
>>> +	  If unsure, say N.
>>> +
>> I don't think that the option is needed. At the end, every distributions will
>> turn it on.
>>
> 
> Are you sure ? This is a rather specific feature, used in specific
> environments. Not that I would mind removing the option if it makes sense.
Check default config file of a standard distributions (ubuntu, debian, ...), all
options are enabled (MIP6, SIT_6RD, PIMSM_v2, etc. ;-)).
Anyway, one option is enough. You add 3 or 4 options in your series.

[snip]

>>> +
>>> +	ip6_route_input(skb);
>> The destination address has now changed and the packet is routed again.
>> skb->nfct is not updated, it is intentional? I'm asking me if it's conceptually
>> right.
>>
> 
> I fail to see any usecase where conntrack would run on SR-enabled
> packets. Things such as NAT would just defeat the purpose.

I've added netfilter folks in CC, it would be good to have feedback from them.

For new people, here is the thread:
http://www.spinics.net/lists/netdev/msg392031.html


Regards,
Nicolas
