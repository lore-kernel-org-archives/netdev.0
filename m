From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: BUG: while bridging Ethernet and wireless device:
Date: Wed, 29 Dec 2010 18:12:16 +0200
Message-ID: <AANLkTi=XQ2DE==ggJHfokUE1=opDVOFxQNeqwY1xZN_8@mail.gmail.com>
References: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i@mail.gmail.com>
	<1293635067.3546.16.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35236 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab0L2QMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 11:12:18 -0500
In-Reply-To: <1293635067.3546.16.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/29 Johannes Berg <johannes@sipsolutions.net>:
> On Thu, 2010-12-16 at 14:11 +0200, Tomas Winkler wrote:
>> Will be happy if someone can give me some more insight. (kernel 2.6.=
37-rc5)
>
> Tomas looked into it a bit more and told me that it happens on IPv6
> packets. To recap, he gets
>
> kernel BUG at include/linux/skbuff.h:1178!
> with
> EIP: [<f83edd65>] br_multicast_rcv+0xc95/0xe1c [bridge]
>
> Also remember that the packets are almost fully nonlinear, when they =
get
> here they likely have almost no data in the skb header.
>
> I then looked at br_multicast_ipv6_rcv(), and it looks fishy:
>
> Up to:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0skb2 =3D skb_clone(skb, GFP_ATOMIC);
>
> everything's fine, since ipv6_skip_exthdr() will use
> skb_header_pointer(). At this point, offset is the result of
> ipv6_skip_exthdr(). Remember that skb_clone() is not skb_copy().

So far I can confirm that switching to sbk_copy fixes the crash.

Thanks
Tomas
