From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: fix handling of throw routes
Date: Mon, 10 Sep 2012 09:15:48 +0200
Message-ID: <504D93A4.4090706@6wind.com>
References: <5048A374.60005@6wind.com> <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com> <20120907.141808.933339383624986735.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, markus.stenberg@iki.fi,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58725 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2IJHPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 03:15:53 -0400
Received: by eaac11 with SMTP id c11so706890eaa.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 00:15:52 -0700 (PDT)
In-Reply-To: <20120907.141808.933339383624986735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/09/2012 20:18, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu,  6 Sep 2012 11:53:35 -0400
>
>> It's the same problem that previous fix about blackhole and prohibit=
 routes.
>>
>> When adding a throw route, it was handled like a classic route.
>> Moreover, it was only possible to add this kind of routes by specify=
ing
>> an interface.
>>
>> Before the patch:
>>    $ ip route add throw 2001::2/128
>>    RTNETLINK answers: No such device
>>    $ ip route add throw 2001::2/128 dev eth0
>>    $ ip -6 route | grep 2001::2
>>    2001::2 dev eth0  metric 1024
>>
>> After:
>>    $ ip route add throw 2001::2/128
>>    $ ip -6 route | grep 2001::2
>>    throw 2001::2 dev lo  metric 1024  error -11
>>
>> Reported-by: Markus Stenberg <markus.stenberg@iki.fi>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied, thanks.
>
> See how easy this was to implement via ->rtm_type? :-)
>
Definitely!
