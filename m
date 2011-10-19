From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use local function pointer
 of bond->recv_probe in bond_handle_frame
Date: Wed, 19 Oct 2011 00:14:47 -0400 (EDT)
Message-ID: <20111019.001447.91777553130308365.davem@davemloft.net>
References: <20111013020429.3554.78679.stgit@ltc219.sdl.hitachi.co.jp>
	<1318997127.19139.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mitsuo.hayasaka.hu@hitachi.com, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
	xiyou.wangcong@gmail.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318997127.19139.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 06:05:27 +0200

> Le jeudi 13 octobre 2011 =E0 11:04 +0900, Mitsuo Hayasaka a =E9crit :
>> The bond->recv_probe is called in bond_handle_frame() when
>> a packet is received, but bond_close() sets it to NULL. So,
>> a panic occurs when both functions work in parallel.
>>=20
>> Why this happen:
>> After null pointer check of bond->recv_probe, an sk_buff is
>> duplicated and bond->recv_probe is called in bond_handle_frame.
>> So, a panic occurs when bond_close() is called between the
>> check and call of bond->recv_probe.
>>=20
>> Patch:
>> This patch uses a local function pointer of bond->recv_probe
>> in bond_handle_frame(). So, it can avoid the null pointer
>> dereference.
>>=20
>>=20
>> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
 ...
> Sorry, I forgot to add my official ack. Even if not a perfect patch, =
its
> a step into right direction.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for reviewing Eric, applied.
