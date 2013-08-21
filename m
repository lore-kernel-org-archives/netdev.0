From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ip6_tunnel: ensure to always have a link local
 address
Date: Wed, 21 Aug 2013 09:40:25 +0200
Message-ID: <52146EE9.1060101@6wind.com>
References: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com> <20130820.234818.2230621827416764963.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:53480 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab3HUHk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 03:40:27 -0400
Received: by mail-we0-f172.google.com with SMTP id t60so73493wes.31
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 00:40:27 -0700 (PDT)
In-Reply-To: <20130820.234818.2230621827416764963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/08/2013 08:48, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 20 Aug 2013 12:16:06 +0200
>
>> When an Xin6 tunnel is set up, we check other netdevices to inherit =
the link-
>> local address. If none is available, the interface will not have any=
 link-local
>> address. RFC4862 expects that each interface has a link local addres=
s.
>>
>> Now than this kind of tunnels supports x-netns, it's easy to fall in=
 this case
>> (by creating the tunnel in a netns where ethernet interfaces stand a=
nd then
>> moving it to a other netns where no ethernet interface is available)=
=2E
>>
>> RFC4291, Appendix A suggests two methods: the first is the one curre=
ntly
>> implemented, the second is to generate a unique identifier, so that =
we can
>> always generate the link-local address. Let's use eth_random_addr() =
to generate
>> this interface indentifier.
>>
>> I remove completly the previous method, hence for the whole life of =
the
>> interface, the link-local address remains the same (previously, it d=
epends on
>> which ethernet interfaces were up when the tunnel interface was set =
up).
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied, but this brings up an issue I keep noticing.
>
> We talk about eth_random_addr() and "uniqueness" together all the
> time, but the former never implies the latter.
>
> And we're going to run into situations where any conflicts generated
> by this random address generater will cause reall failures.
>
> Therefore we'll have to create a system to prevent them.  Probably
> using some simple table that keeps track of the addresses we've
> generated.
>
Ok, I will look at this.
