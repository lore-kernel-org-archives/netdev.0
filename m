From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 14:01:44 +0100
Message-ID: <4D5927B8.2070704@gmail.com>
References: <1297680967-11893-1-git-send-email-segoon@openwall.com> <4D591D04.4050000@gmail.com> <20110214122313.GA10062@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54545 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647Ab1BNNBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 08:01:48 -0500
In-Reply-To: <20110214122313.GA10062@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/02/2011 13:23, Vasiliy Kulikov a =E9crit :
> Hi Nicolas,

Hi Vasiliy,

> On Mon, Feb 14, 2011 at 13:16 +0100, Nicolas de Peslo=FCan wrote:
>>> -	BUG_ON(strlen(name)>=3D sizeof(dev->name));
>>> +	if (strnlen(name, sizeof(dev->name))>=3D sizeof(dev->name)) {
>
> Ehh...  Space after ")" is needed :)

:-D

>> "size_t strnlen(const char *s, size_t maxlen) : The strnlen()
>> function returns strlen(s), if that is less than maxlen, or maxlen
>> if there is no '\0' character among the first maxlen characters
>> pointed to by s."
>>
>> How can strnlen(name, sizeof(dev->name)) be greater than sizeof(dev-=
>name)?
>>
>> Shouldn't it be "if (strnlen(name, sizeof(dev->name)) =3D=3D sizeof(=
dev->name))" instead?
>
> Not a big deal, but MO it's better to guard from everything that
> is not a good input by negating the check.  strnlen()<  sizeof() is O=
K,
> strnlen()>=3D sizeof() is bad.  Is "=3D=3D" more preferable for net/ =
coding style?

Agreed, both cannot cause any troubles. =3D=3D is supposed to be better=
 from the API point of view, but=20
 >=3D is probably more readable.

	Nicolas.
