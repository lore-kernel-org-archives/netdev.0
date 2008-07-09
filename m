From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH v3 2/2] hfsc: add link layer overhead adaption
Date: Wed, 09 Jul 2008 20:42:48 +0300
Message-ID: <20080709204248.506775otd5me5pwc@naisho.dyndns.info>
References: <20080703220311.30053.63477.stgit@fate.lan>
	<20080703220317.30053.87947.stgit@fate.lan> <487203B4.4030701@trash.net>
	<20080708141135.174942dv1q2og4o4@hayate.ip6> <48738ECA.9050703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:52098 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbYGIRmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 13:42:51 -0400
In-Reply-To: <48738ECA.9050703@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Patrick McHardy" <kaber@trash.net>:

> Jussi Kivilinna wrote:
>> Quoting "Patrick McHardy" <kaber@trash.net>:
>>>
>>> This means HFSC will use other packet sizes as inner qdiscs, policers,
>>> statistics etc, which I don't like very much. My original patch used
>>> the size tables to calculate the size when enqueing to the root qdisc
>>> and stored it in the cb, so all qdiscs in the hierarchy can use the
>>> same size.
>>
>> With this patch I have tried to make HFSC support link layer   
>> emulation in same way as done in HTB with rate table, so that   
>> overhead is defined on leaf qdisc (if have understood right).
>
> The difference is that with this approach you are actually
> able to make the entire qdisc hierarchy use the same size
> for calculations/statistics/etc. The rate tables only work
> in TBF based qdiscs and policers (which was always one of
> my complaints).
>
>>
>> I have used this patch to have different overhead between qdisc   
>> leafs to account for extra overhead of ipv6-in-ipv4 tunnel   
>> (redirecting traffic to IMQ device and filtering ipv4&ipv6 to   
>> corresponding leafs). If overhead/linklayer is defined on root   
>> qdisc, this wouldn't be possible?
>
> You could override the size in inner classes and qdiscs.
> Having an optional size table per qdisc would make this
> consistent from a user perspective with the top-level
> size calculation. (And I agree that including tunnel
> overhead makes sense).
>

Ok, having one table for whole qdisc tree (with overrides) sounds better.

  - Jussi

