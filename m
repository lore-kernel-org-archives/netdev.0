From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: use daddr to get inet_peer
Date: Fri, 14 Feb 2014 17:51:07 +0800
Message-ID: <52FDE70B.2020901@cn.fujitsu.com>
References: <52FDE10F.5010903@cn.fujitsu.com> <20140214094151.GA12549@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62223 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbaBNJwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:52:06 -0500
In-Reply-To: <20140214094151.GA12549@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B402=E6=9C=8814=E6=97=A5 17:41, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Fri, Feb 14, 2014 at 05:25:35PM +0800, Duan Jiong wrote:
>>
>> since commit 1d861aa4("inet: Minimize use of cached route inetpeer")=
,
>> ip_error() uses saddr to get inet_peer, so ip_error() and icmpv4_xrl=
im_allow()
>> use the same inet_peer to limit icmp error message twice.
>>
>> In ip_error(), peer->rate_tokens is set to ip_rt_error_burst, but in
>> inet_peer_xrlim_allow() peer->rate_tokens is set to XRLIM_BURST_FACT=
OR.
>> XRLIM_BURST_FACTOR is defined to 6, so user seting ip_rt_error_burst=
 makes
>> no sense.
>>
>> In my opinion, the ip_rt_error_burst is used to limit icmp error mes=
sages
>> for daddr instead of saddr.
>=20
> Hmmm...
>=20
> ip_error is a dst_input function, as such it gets called with the inc=
oming
> packet. saddr is the address we send the reply back (see
> icmp_send->icmp_route_lookup).
>=20

But if we still use saddr to get inet_peer, seting ip_rt_error_burst wi=
ll make
no sense, because it will be overwrited by XRLIM_BURST_FACTOR.

Thanks,
  Duan


> Sorry, I don't think the patch is correct.
>=20
> Bye,
>=20
>   Hannes
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
