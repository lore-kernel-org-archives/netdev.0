From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Thu, 21 Jan 2010 00:14:33 +0100
Message-ID: <4B578E59.8090203@trash.net>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com> <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid> <4B5773C2.2010000@simon.arlott.org.uk> <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr> <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47068 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab0ATXOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:14:37 -0500
In-Reply-To: <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Wednesday 2010-01-20 22:39, Jan Engelhardt wrote:
> 
>> On Wednesday 2010-01-20 22:21, Simon Arlott wrote:
>>
>>> The TCPMSS target is dropping SYN packets where:
>>>  1) There is data, or
>>>  2) The data offset makes the TCP header larger than
>>>  the packet.
>>>
>>> Both of these result in an error level printk.
>>>
>>> This change fixes the drop of SYN packets with data
>>> (because the MSS option can safely be modified) and
>>> passes packets with no MSS option instead of adding
>>> one (which is not valid).
>> Can you explain why the automatic addition of a MSS option is removed?
> 
> That is, of course, for the git log. If I followed the thread right, it 
> was that adding the option could exceed the MTU. Well, can't we check 
> for the outgoing MTU?

We certainly can, and in fact the packet would get fragmented
by the IP layer in case we would exceed the PMTU. Additionally
we currently check that the packet contains no data, even with
the first version of this patch, so there's no way the packet
could exceed the MTU.

This feature has been there from day one since the TCPMSS target
has been merged and people are using this with knowledge of their
MTUs to work around broken ISPs. I'm not apply this.

The first version seemed fine to me though :)
