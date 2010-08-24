From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 11:43:34 +0300
Message-ID: <4C738636.4000107@fs.uni-ruse.bg>
References: <20100820193835.GA6025@del.dom.local>	 <20100821074742.GA2367@del.dom.local>	 <1282377058.2636.12.camel@edumazet-laptop>	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>	 <20100823124736.GA16966@ff.dom.local>	 <1282568443.2486.34.camel@edumazet-laptop>	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>	 <4C734FB5.1090702@fs.uni-ruse.bg> <1282626102.2378.1351.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:41888 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751805Ab0HXInh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 04:43:37 -0400
In-Reply-To: <1282626102.2378.1351.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 24.8.2010 =D0=B3. 08:01, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Le mardi 24 ao=C3=BBt 2010 =C3=A0 07:51 +0300, Plamen Petrov a =C3=A9=
crit :
>> So far - not so good. :(
=2E..
>
> Hmm... I was thinking adding a call __skb_linearize(), just in case..=
=2E
>
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index f5166dc..10928a2 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -1696,7 +1696,7 @@ static netdev_tx_t rtl8139_start_xmit (struct s=
k_buff *skb,
>   	entry =3D tp->cur_tx % NUM_TX_DESC;
>
>   	/* Note: the chip doesn't have auto-pad! */
> -	if (likely(len<  TX_BUF_SIZE)) {
> +	if (likely(len<  TX_BUF_SIZE&&  !__skb_linearize(skb))) {
>   		if (len<  ETH_ZLEN)
>   			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
>   		skb_copy_and_csum_dev(skb, tp->tx_buf[entry]);
>
>
Here is what I've got while running the kernel with the patch
I attached earlier plus the above one, after turning GRO on for
my tg3 nic:

[picture 10]
http://picpaste.com/37e37f9ff9504e3a003f49092f9b1be6.jpg

[picture 11]
http://picpaste.com/5663ca7c5041c0ed7a1f3e6a9aa17a9e.jpg

[picture 12]
http://picpaste.com/17f2ecaa409a1ebbf835a2e0519d3099.jpg

Now moving on to the second proposed patch from Jarek.

Thanks,
Plamen
