From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Wed, 01 Sep 2010 14:51:51 -0700 (PDT)
Message-ID: <20100901.145151.93454549.davem@davemloft.net>
References: <20100830.095012.233695092.davem@davemloft.net>
	<20100830105117.0f0cf140@nehalam>
	<20100830190900.GA3141@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753136Ab0IAVvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:51:35 -0400
In-Reply-To: <20100830190900.GA3141@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 30 Aug 2010 21:09:00 +0200

> On Mon, Aug 30, 2010 at 10:51:17AM -0700, Stephen Hemminger wrote:
>> 
>>  There's something very important I forgot to tell you.
>>  What?
>> 
>>  Don't cross the GRO streams.
>>  Why?
>> 
>>  It would be bad.
>>  I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?
>> 
>>  Try to imagine all the Internet as you know it stopping instantaneously
>>   and every bit in every packet swapping at the speed of light.
>>  Total packet reordering.
>>  Right. That's bad. Okay. All right. Important safety tip. Thanks, Hubert
> 
> Looks really bad to me, so... let's forget it! ;-) (At least until
> next next.)

I'm applying this patch.

Note that for us, devices act as domains, or a key for networking
traffic, whether we like it or not.  Yes, even for the same IP
addresses on the same host.

The reason is that we can do ingress packet editing and the realm of
those rules are per-ingress-qdisc, which are per-device.

The only scenerio you can guarentee that all packets for a given
flow key will be treated the same is the one where the input device
is the same as well.

When there is a single napi --> device mapping, it works, but without
that invariant it doesn't.


