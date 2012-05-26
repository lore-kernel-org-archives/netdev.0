From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Sat, 26 May 2012 17:00:10 +0800
Message-ID: <4FC09B9A.6090806@cn.fujitsu.com>
References: <20120215104021.GC31660@secunet.com> <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com> <20120514130528.GA24733@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, lw@cn.fujitsu.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36156 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab2EZI7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2012 04:59:39 -0400
In-Reply-To: <20120514130528.GA24733@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8814=E6=97=A5 21:05, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Mon, May 14, 2012 at 11:21:00AM +0800, Gao feng wrote:
>> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem=
)
>> the fragment of ipsec transport mode packets is incorrect.
>> because tunnel mode needs IPsec headers and trailer for all fragment=
s,
>> while on transport mode it is sufficient to add the headers to the
>> first fragment and the trailer to the last.
>=20
> I mentioned this in an other thread some time ago,
> this is due to commit ad0081e43a
> "ipv6: Fragment locally generated tunnel-mode IPSec6 packets as neede=
d"
> changed tunnel mode to do fragmentation before the transformation
> while transport mode still does fragmentation after transformation.
> Now, tunnel mode needs IPsec headers and trailer for all fragments,
> while on transport mode it is sufficient to add the headers to the
> first fragment and the trailer to the last.
>=20
>>
>> so modify mtu and maxfraglen base on ipsec mode and if fragment is f=
irst
>> or last.
>=20
> There might be other opinions, but I don't like to see this IPsec mod=
e
> dependent stuff hacked into the generic ipv6 output path.
>=20
> Basically we have two cases. One where we have to add rt->dst.header_=
len
> to the first fragment and rt->dst.trailer_len to the last fragment,
> and the other where we have to add both to all fragments. So perhaps =
we
> could isolate this code and create two functions, one for each case.
>=20
>=20

I thought this problem carefully,I think the important and troubled thi=
ng is
how to deal with transport mode.

we have to use different mtu and maxfraglen for checking if the prev_sk=
b has
extra data or has free room. so mtu_prev and maxfraglen_prev have to be=
 used.

And I also think it's not very well to create two function for the two =
cases,
it will create a lot of redundant codes.

I will add a dst_entry flag DST_XFRM_TUNNEL to avoid ipsec mode depende=
nt stuff
hacked into the generic ipv6_output path, and send patch v2.
