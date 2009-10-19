From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Mon, 19 Oct 2009 22:01:15 +0200
Message-ID: <4ADCC58B.2060408@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli> <4AD84D8B.5020103@gmail.com> <Pine.LNX.4.58.0910171417260.7818@u.domain.uli> <4AD9B37A.3090606@gmail.com> <Pine.LNX.4.58.0910171709190.10440@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57629 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbZJSUBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:01:51 -0400
In-Reply-To: <Pine.LNX.4.58.0910171709190.10440@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
> 	Hello,
>=20
> On Sat, 17 Oct 2009, Eric Dumazet wrote:
>=20
>> I really like this, but please define helper functions out of do_tcp=
_setsockopt()
>>
>> /* Translate value in seconds to number of SYN-ACK retransmits */
>> static u8 secs_to_retrans(int seconds)
>> {
>> 	u8 res =3D 0;
>>
>> 	if (seconds > 0) {
>> 		int timeout =3D TCP_TIMEOUT_INIT / HZ;
>> 		int period =3D timeout;
>>
>> 		res =3D 1;
>> 		while (res < 255 && seconds > period) {
>> 			res++;
>> 			timeout <<=3D 1;
>> 			if (timeout > TCP_RTO_MAX / HZ)
>> 				timeout =3D TCP_RTO_MAX / HZ;
>> 			period +=3D timeout;
>> 		}
>> 	}
>> 	return res;
>> }
>>
>> You also need the reverse function for getsockopt()...
>=20
> 	Yes, I forgot that. Here is what I tested, should
> I split it later to 2 patches? May be it should go somewhere
> in net/core/sock.c as extern funcs with EXPORT_SYMBOL to
> allow other protocols one day to use it?
>=20

No need to EXPORT_SYMBOL it for the moment. We can add it later if real=
ly needed.

David, I think we should revert 6d01a026b7d3009a418326bdcf313503a314f1e=
a
(tcp: fix tcp_defer_accept to consider the timeout)=20
since we know its broken.


