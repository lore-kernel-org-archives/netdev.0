From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 3/8] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Wed, 20 Feb 2008 17:27:39 +0100
Message-ID: <47BC54FB.2050508@trash.net>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi> <Pine.LNX.4.64.0802201651580.26109@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:59041 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934461AbYBTQ2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 11:28:02 -0500
In-Reply-To: <Pine.LNX.4.64.0802201651580.26109@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Feb 20 2008 15:47, Ilpo J=E4rvinen wrote:
>> -23668  392 funcs, 104 +, 23772 -, diff: -23668 --- dev_alloc_skb
>>
>> -static inline struct sk_buff *dev_alloc_skb(unsigned int length)
>> -{
>> -	return __dev_alloc_skb(length, GFP_ATOMIC);
>> -}
>> +extern struct sk_buff *dev_alloc_skb(unsigned int length);
>=20
> Striking. How can this even happen? A callsite which calls
>=20
> 	dev_alloc_skb(n)
>=20
> is just equivalent to
>=20
> 	__dev_alloc_skb(n, GFP_ATOMIC);
>=20
> which means there's like 4 (or 8 if it's long) bytes more on the
> stack. For a worst case, count in another 8 bytes for push and pop or=
 mov on
> the stack. But that still does not add up to 23 kb.


__dev_alloc_skb() is also an inline function which performs
some extra work. Which raises the question - if dev_alloc_skb()
is uninlined, shouldn't __dev_alloc_skb() be uninline as well?
