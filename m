From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: fix mss comparison
Date: Tue, 28 Feb 2012 17:55:41 +0800
Message-ID: <CAJFZqHwpyf093EC_wgZEiogfQ=hHqxH0FkhkktRr9MEypCkEtg@mail.gmail.com>
References: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
	<1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
	<20120228093426.GA17057@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:57367 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752081Ab2B1Jzm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 04:55:42 -0500
Received: by obcva7 with SMTP id va7so6568968obc.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 01:55:41 -0800 (PST)
In-Reply-To: <20120228093426.GA17057@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/28 Francois Romieu <romieu@fr.zoreil.com>:
> roy.qing.li@gmail.com <roy.qing.li@gmail.com> :
> [...]
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 0489ced..c72f765 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -1914,8 +1914,8 @@ static unsigned int ipv4_default_advmss(const =
struct dst_entry *dst)
>> =A0 =A0 =A0 if (advmss =3D=3D 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 advmss =3D max_t(unsigned int, dst->dev-=
>mtu - 40,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_rt_min=
_advmss);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (advmss > 65535 - 40)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 advmss =3D 65535 - 40;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (advmss > 65535 - sizeof(struct tcphdr)=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 advmss =3D 65535 - sizeof(=
struct tcphdr);
>
> What would prevent net/ipv4/tcp_output.c::tcp_advertise_mss returning
> a value beyond 65535 - 40 ?
>

You are right, Please ignore this patch.
The biggest MSS should be (Total Length of ipv4 header -
sizeof(iphdr)- sizeof(tcphdr))

I mix up the Total Length of ipv4 header and Payload Length of ipv6 hea=
der.

> --
> Ueimor
