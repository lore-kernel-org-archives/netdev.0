From: David Miller <davem@davemloft.net>
Subject: Re: Case for reusing netlink PADs WAS(Re: [PATCH net-next 1/1] net
 sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 11:25:50 -0400 (EDT)
Message-ID: <20170418.112550.555367290414966782.davem@davemloft.net>
References: <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
        <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
        <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753721AbdDRPZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:25:55 -0400
In-Reply-To: <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 18 Apr 2017 08:48:57 -0400

> For the patches I posted, I will work on getting an attribute based
> variant of the patches out - but i wanted to have this discussion a
> little more if you bear with me.
> 
> Netlink is a wire protocol. When a protocol is defined with rules such
> as alignment (which lead to explicit padding) then those are
> equivalent
> to "reserved bits" in standard wire protocols. Good practise is:
> all sender zero those bits(MBZ); and all receivers must ignore them
> unless they wish to interpret them. Not everyone follows these rules
> (I remember the havoc ECN caused when TCP/IP started using the
> different
> reserved fields).
> 
> For our case it is _very sad_ that someone actually explicitly defined
> pads - in my opinion for no other purpose other than reuse and then
> we say we cant use them after.

Unless you define the field to have meaning from the beginning and
truly _ENFORCE_ that meaning from the start, you cannot reuse the
field later.

So, for example, if we enforced the padding fields to be zero from day
one, and the kernel rejected non-zero values, then you could start to
consider reusing them later.  Because you have %100 certainty that
existing applications fill the field in with zero.

But that is not the case here.

All of your "on the wire protocol" talk is meaningless because we
didn't do that.  On the wire protocols enforce undefined and reserved
fields to meet certain requirements.  We do not, in general, do that
with netlink.

This is why it is important to very carefully think ahead and define
the initial netlink operation structures fully.

If you don't get it right, and later need to add something, just take
the safe path and just add attributes and don't even think about
messing with the existing structure.

Thanks.
