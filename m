From: Ben Greear <greearb@candelatech.com>
Subject: Re: netlink stats: Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 13:43:50 -0700
Message-ID: <4CC73D86.3070107@candelatech.com>
References: <4CC72C80.9010802@candelatech.com>	 <20101026.123811.13746869.davem@davemloft.net>	 <1288122986.2652.20.camel@edumazet-laptop>	 <4CC73A1E.5050605@candelatech.com> <1288125432.2652.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58076 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441Ab0JZUnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:43:53 -0400
In-Reply-To: <1288125432.2652.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 01:37 PM, Eric Dumazet wrote:
> Le mardi 26 octobre 2010 =C3=A0 13:29 -0700, Ben Greear a =C3=A9crit =
:
>
>> I'm trying to craft my own netlink message...basically:
>>
>>      memset(&snl, 0, sizeof(snl));
>>      snl.nl_family =3D AF_NETLINK;
>>      snl.nl_pid    =3D 0;
>>      snl.nl_groups =3D 0;
>>
>>      memset(&buffer, 0, sizeof(buffer));
>>      nlh->nlmsg_type =3D msg_type;
>>      nlh->nlmsg_flags =3D NLM_F_MATCH|NLM_F_REQUEST;
>
> dont use F_MATCH : check net/core/rtnetlink.c
>
> vi +1660 net/core/rtnetlink.c
>
> You _dont_ want to call 'dumpit' : so dont use a bit present in
> NLM_F_DUMP at all:

That was exactly my problem.  It works as expected with that NLM_F_MATC=
H
removed.

Thanks!
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

