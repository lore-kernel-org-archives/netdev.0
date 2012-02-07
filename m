From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Fix mem leak in bnx2x_tpa_stop() if build_skb()
 fails.
Date: Tue, 07 Feb 2012 13:14:13 -0500 (EST)
Message-ID: <20120207.131413.1550725807432901999.davem@davemloft.net>
References: <alpine.LNX.2.00.1202062224210.20532@swampdragon.chaosbits.net>
	<1328568833.2476.1.camel@edumazet-laptop>
	<1328597701.18349.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jj@chaosbits.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eliezert@broadcom.com
To: eilong@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328597701.18349.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 7 Feb 2012 08:55:01 +0200

> On Mon, 2012-02-06 at 23:53 +0100, Eric Dumazet wrote:
>> Le lundi 06 f=E9vrier 2012 =E0 22:28 +0100, Jesper Juhl a =E9crit :
>> > We allocate memory for 'new_data' with kmalloc(). If we get the me=
mory
>> > we then try to build_skb() and if that should fail (which it can) =
we
>> > do not enter 'if (likely(skb)) {' and actually use 'new_data' but
>> > instead fall through to the 'drop:' label and end up returning fro=
m
>> > the function without ever assigning 'new'data' to anything or free=
ing
>> > it. That leaks the memory allocated to 'new_data'.
>> >=20
>> > This patch fixes the memory leak by doing a kfree(new_data) in the
>> > case where build_skb() fails (or where allocation of 'new_data' it=
self
>> > fails, but in taht case it's just a harmless kfree(NULL)).
>> >=20
>> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
=2E..
>> Good catch, my bad.
>>=20
>> Thanks
>>=20
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Indeed - nice catch. Thanks Jesper.
>=20
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks everyone.
