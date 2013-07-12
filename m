From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Fri, 12 Jul 2013 14:04:45 +0200
Message-ID: <51DFF0DD.5050601@6wind.com>
References: <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org> <51DEC7E6.8000500@6wind.com> <20130712085113.GI12611@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:63236 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887Ab3GLMEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 08:04:49 -0400
Received: by mail-we0-f171.google.com with SMTP id m46so7982614wev.16
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 05:04:48 -0700 (PDT)
In-Reply-To: <20130712085113.GI12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/07/2013 10:51, Hannes Frederic Sowa a =C3=A9crit :
> Hello Nicolas,
>
> On Thu, Jul 11, 2013 at 04:57:42PM +0200, Nicolas Dichtel wrote:
>> Le 11/07/2013 16:46, Hannes Frederic Sowa a =C3=A9crit :
>>> On Thu, Jul 11, 2013 at 12:24:41PM +0200, Hannes Frederic Sowa wrot=
e:
>>>> I fear, I'll need to do a bit more research.
>>>
>>> My proposal is to take my patch and check for RTF_ADDRCONF plus
>>> RTF_DYNAMIC,
>>> too. The RTF_DYNAMIC check would prevent routes created from icmpv6
>>> redirects
>>> entering an ecmp route set.
>>>
>>> Do you agree?
>> Yes.
>
> There is still some window where things go wrong now, I fear. If we h=
ave ecmp
> routes active and we update the pmtu of that rt6_info, we might end u=
p with a
> route in the ecmp set, which might not get recountet if another ecmp =
route
> joins the set. I will have to think how to deal with this. Do you hav=
e an
> idea?
It's possible to add a glue to check this counter when we play with the=
se flags,=20
but it's ugly.

Maybe the check against RTF_EXPIRES is fundamentally wrong. Checking=20
RTF_ADDRCONF|RTF_DYNAMIC should be enough, what do you think?

In another hand, we can discuss about the initial assumption, that was =
"only=20
static routes are part of ECMP routes". I'm thinking of what are the co=
nsequence=20
if we accept to accept all routes, without checking any flags.


Regards,
Nicolas
