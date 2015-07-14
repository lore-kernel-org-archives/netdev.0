From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 15:34:22 -0700 (PDT)
Message-ID: <20150714.153422.914759715820927338.davem@davemloft.net>
References: <55A41CE9.8050907@plumgrid.com>
	<55A425C4.60301@iogearbox.net>
	<55A43B26.1010009@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jhs@mojatatu.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbbGNWeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 18:34:23 -0400
In-Reply-To: <55A43B26.1010009@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 13 Jul 2015 15:26:46 -0700

> On 7/13/15 1:55 PM, Daniel Borkmann wrote:
>> On 07/13/2015 10:17 PM, Alexei Starovoitov wrote:
>> ...
>>> We cannot check tc actions from pktgen, since they can be added
>>> dynamically.
>>> So I see three options:
>>> 1 get rid of burst hack for both RX and TX in pktgen (kills
>>> performance)

#1 is a serious consideration if you don't come up with better ideas,
since an optimization is for nothing if it knowingly breaks things.

>>> 2 add unlikely(skb_shread) check to few tc actions
>>> 3 do nothing
> ...
>> pktgen case. :/ With regards to option 2, you could hide that behind
>> a static inline helper wrapped in IS_ENABLED(CONFIG_NET_PKTGEN), but
>> that is a veeeery ugly workaround/hack as well (and distros might
>> even ship it nevertheless).
> 
> naming such helper is a headache as well.
> static inline bool is_pktgen_shared_skb(struct sk_buff *skb)
> {
> #if IS_ENABLED(CONFIG_NET_PKTGEN)

As mentioned by others, this ifdef accomplishes nothing as indeed
every distribution turns pktgen on so %99.9999 of all users will not
benefit from this optimized check.
