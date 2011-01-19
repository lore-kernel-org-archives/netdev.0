From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 18:42:13 +0100
Message-ID: <4D372275.3000104@netfilter.org>
References: <20110118.020702.115924992.davem@davemloft.net>	<20110118102437.GB7520@ff.dom.local>	<4D35F8A3.1010600@netfilter.org> <20110118.125051.260099262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56589 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab1ASRmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 12:42:21 -0500
In-Reply-To: <20110118.125051.260099262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/11 21:50, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 18 Jan 2011 21:31:31 +0100
> 
>> The combination that avahi uses makes no sense.
>>
>> I've been auditing user-space tools that may have problems with this change:
>>
>> * iw (it uses libnl)
>> * acpid (it uses a mangled version of libnetlink shipped in iproute)
>> * tstime, for taskstats, it uses libnl
>> * wimax-tools, it uses libnl
>> * quota-tools, it uses libnl
>> * keepalived, no libs used
>>
>> Well, I can keep looking for more, but I think that avahi is the only
>> one doing this incorrectly.
>>
>> Please, fix avahi instead.
> 
> That's a pretty compelling argument, so I'll hold off on the revert
> for now.

I've been reviewing user-space applications for a couple of hours (I've
got a big list here with no problems), unfortunately I found that:

ip route show cache

hangs after displaying the first line with the patch applied because it
uses:

        req.nlh.nlmsg_type = RTM_GETROUTE;
        req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_REQUEST;

to dump the routing cache.

We need something less agressive, some warning to be printed and accept
this flag combination for quite some time until it's removed as jamal
and jarek suggested.

Please, revert this patch until we find a better solution.
