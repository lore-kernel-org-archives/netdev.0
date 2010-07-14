From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Wed, 14 Jul 2010 13:48:04 +0200
Message-ID: <4C3DA3F4.1060807@trash.net>
References: <20100713001115.GA3751@sortiz-mobl>	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper> <4C3C9671.5090503@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luciano.coelho@nokia.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51368 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab0GNLsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 07:48:01 -0400
In-Reply-To: <4C3C9671.5090503@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.07.2010 18:38, Pablo Neira Ayuso wrote:
> On 13/07/10 12:23, Luciano Coelho wrote:
>> On Tue, 2010-07-13 at 10:50 +0200, ext Pablo Neira Ayuso wrote:
>>> On 13/07/10 08:18, Changli Gao wrote:
>>>> On Tue, Jul 13, 2010 at 8:11 AM, Samuel
>>>> Ortiz<sameo@linux.intel.com>  wrote:
>>>>>
>>>>> The userspace notification Xtables target sends a netlink notification
>>>>> whenever a packet hits the target. Notifications have a label
>>>>> attribute
>>>>> for userspace to match it against a previously set rule. The rules
>>>>> also
>>>>> take a --all option to switch between sending a notification for all
>>>>> packets or for the first one only.
>>>>> Userspace can also send a netlink message to toggle this switch
>>>>> while the
>>>>> target is in place. This target uses the nefilter netlink framework.
>>>>>
>>>>> This target combined with various matches (quota, rateest, etc..)
>>>>> allows
>>>>> userspace to make decisions on interfaces handling. One could for
>>>>> example
>>>>> decide to switch between power saving modes depending on estimated
>>>>> rate
>>>>> thresholds.
>>>>>
>>>>
>>>> It much like the following iptables rules.
>>>>
>>>> iptables -N log_and_drop
>>>> iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix
>>>> "log_and_drop"
>>>> iptables -A log_and_drop -j DROP
>>>>
>>>> ...
>>>> iptables ... -m quota --quota-bytes 20000 -j log_and_drop
>>>> ...
>>>
>>> Indeed, this looks to me like something that you can do with NFLOG and
>>> some combination of matches.
>>
>> Is it possible to have the NFLOG send only one notification to the
>> userspace?
> 
> Not possible, but you could easily extend NFLOG to implement this
> feature if it's not possible to do what you need with the existing
> matches/targets. This NOTIF infrastructure is redundant and it looks
> like a subset of NFLOG.

If you're using connection tracking, you can use conntrack marks
to avoid sending more than a single message:

iptables ... -m connmark --mark 0x1/0x1 -j RETURN
iptables ... -j NFLOG ...
iptables ... -j CONNMARK --set-mark 0x1/0x1
