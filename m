From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Tue, 23 Aug 2011 21:31:36 +0900
Message-ID: <4E539DA8.1070504@sfc.wide.ad.jp>
References: <4E5367CA.3090005@sfc.wide.ad.jp> <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:60286 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752273Ab1HWMbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 08:31:37 -0400
In-Reply-To: <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the blurb. I hope I've configured thunderbird properly to sen=
d in plain text. Hope you received my reply. I tried your patch on 3.0.=
3 and it didn't fix the problem.

Regards,
Ang

On 23/08/11 18:57, Eric Dumazet wrote:
> Le mardi 23 ao=C3=BBt 2011 =C3=A0 17:41 +0900, Ang Way Chuang a =C3=A9=
crit :
>> Hi all,
>>
>>      Sorry for cross-posting. I have a testbed setup on my VM
>> environment that needs to use MLDv2 report message. My PIM router
>> which is connected to a port on the bridge relies upon MLDv2 message
>> to work. However, the setup failed to work after 2.6.39-rc2 or later=
=2E
>> MLDv2 won't be forwarded to any slave ports bound to the bridge
>> interface. Specifically, I track the cause down to this commit id:
>>
>>        ff9a57a62afbbe2d0f3a09af321f1fd7645f38a5
>>
>>      However, as soon as I disable multicast snooping on sysfs, MLDv=
2
>> message can be forwarded again.
>>
>>      I am not knowledgeable on the subject of multicast snooping, bu=
t
>> is this right behaviour for multicast snooping? IPv4 doesn't seem to
>> suffer the same fate though, IGMP can be forwarded even if
>> multicast_snooping is enabled. Thank you in advance.
>>
> Thanks very much for the report and your tracking.
>
> Added some CC
>
> I wonder if the  ff9a57a62afb commit doesnt uncover a prior bug, coul=
d
> you try the following patch ?
>
> Thanks !
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2d85ca7..51e3b2d 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1520,6 +1520,7 @@ static int br_multicast_ipv6_rcv(struct net_bri=
dge *br,
>   		err =3D pskb_trim_rcsum(skb2, len);
>   		if (err)
>   			goto out;
> +		icmp6h =3D icmp6_hdr(skb2);
>   	}
>
>   	switch (skb2->ip_summed) {
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

