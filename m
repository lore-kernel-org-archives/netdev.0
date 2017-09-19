From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6
 packets
Date: Tue, 19 Sep 2017 10:42:48 -0700 (PDT)
Message-ID: <20170919.104248.1540128186724107742.davem@davemloft.net>
References: <20170919003904.5124-8-tom@quantonium.net>
        <20170918.211908.2152170523885516973.davem@davemloft.net>
        <20170919121245.t555dqwndhewmdyw@nataraja>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdISRmt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:42:49 -0400
In-Reply-To: <20170919121245.t555dqwndhewmdyw@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@gnumonks.org>
Date: Tue, 19 Sep 2017 20:12:45 +0800

> Hi Dave,
> 
> On Mon, Sep 18, 2017 at 09:19:08PM -0700, David Miller wrote:
> 
>> > +static inline u32 ipv6_hashfn(const struct in6_addr *a)
>> > +{
>> > +	return __ipv6_addr_jhash(a, gtp_h_initval);
>> > +}
>> 
>> I know you are just following the pattern of the existing "ipv4_hashfn()" here
>> but this kind of stuff is not very global namespace friendly.  Even simply
>> adding a "gtp_" prefix to these hash functions would be a lot better.
> 
> I would agree if this was an inline function defined in a header file or
> a non-static function.  But where is the global namespace concern in
> case of static inline functions defined and used in the same .c file?

The problem is if we create a generic ipv6_hashfn() in linux/ipv6.h or
something like that, then this driver stops building.
