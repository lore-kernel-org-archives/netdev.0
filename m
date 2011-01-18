From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 21:31:31 +0100
Message-ID: <4D35F8A3.1010600@netfilter.org>
References: <4D336050.9030602@netfilter.org> <20110118093811.GA7520@ff.dom.local> <20110118.020702.115924992.davem@davemloft.net> <20110118102437.GB7520@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39628 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753661Ab1ARUbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 15:31:35 -0500
In-Reply-To: <20110118102437.GB7520@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/11 11:24, Jarek Poplawski wrote:
> On Tue, Jan 18, 2011 at 02:07:02AM -0800, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Tue, 18 Jan 2011 09:38:11 +0000
>>
>>> Even if I'm wrong, this change added to stable will break many configs.
>>> My proposal is to revert commit 0ab03c2b147 until proper fix is found.
>>
>> The flag combination is, at best ambiguous, it has no proper
>> definition without the check we added.
> 
> Do you all expect all users manage to upgrade avahi app before
> changing their stable kernel? I mean "own distro" users especially.

The combination that avahi uses makes no sense.

I've been auditing user-space tools that may have problems with this change:

* iw (it uses libnl)
* acpid (it uses a mangled version of libnetlink shipped in iproute)
* tstime, for taskstats, it uses libnl
* wimax-tools, it uses libnl
* quota-tools, it uses libnl
* keepalived, no libs used

Well, I can keep looking for more, but I think that avahi is the only
one doing this incorrectly.

Please, fix avahi instead.
