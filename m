From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken. In 4.0.0-rc3
Date: Mon, 23 Mar 2015 11:22:13 +0300
Message-ID: <397281427098933@web12o.yandex.ru>
References: <390621425930628@web28o.yandex.ru>
	<3625951426018334@web26j.yandex.ru>
	<BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<726281426513068@web10o.yandex.ru>
	<BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<994171426532944@web7m.yandex.ru>
	<20150321205359.GM8656@n2100.arm.linux.org.uk>
	 <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com> <BLUPR03MB373FC71B9A8559E51084C26F50D0@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward12o.cmail.yandex.net ([37.9.109.179]:52392 "EHLO
	forward12o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbbCWIWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 04:22:18 -0400
In-Reply-To: <BLUPR03MB373FC71B9A8559E51084C26F50D0@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



23.03.2015, 05:42, "fugang.duan@freescale.com" <fugang.duan@freescale.c=
om>:
> From: Fabio Estevam <festevam@gmail.com> Sent: Sunday, March 22, 2015=
 6:36 AM
>> =9ATo: Russell King - ARM Linux
>> =9ACc: =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA; Duan Fugang-B38611; netde=
v@vger.kernel.org; linux-arm-
>> =9Akernel
>> =9ASubject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX=
 is
>> =9Abroken. In 4.0.0-rc3
>>
>> =9AHi Russell,
>>
>> =9AOn Sat, Mar 21, 2015 at 5:53 PM, Russell King - ARM Linux
>> =9A<linux@arm.linux.org.uk> wrote:
>>> =9AGiven that this bug can seriously screw data up in undetectable =
ways
>>> =9A(TCP checksums don't save you, because the FEC generates them on=
 the
>>> =9Adata which it read from memory, even if it happened to read the =
data
>>> =9Afrom the SoC's boot ROM) we do need to get this fixed ASAP.
>> =9ACurrent mainline has 2b995f63987013 reverted, so 4.0-rc5 will not=
 have
>> =9Athis corruption problem.
>>
>> =9ARegards,
>>
>> =9AFabio Estevam
>
> We cannot revert the commit 2b995f63987013, otherwise there introduce=
 other issue. The correct fix method is Russell King's fix in the previ=
ous mail.
> It is strange thing that I cannot reproduce the issue on i.MX6q sabre=
sd board. Anyway, we must consider TSO case that it's not a fragmented =
skb.

It is just DMA_API_DEBUG=3Dy error versus several data corruption error=
=2E DMA_API_DEBUG can be wrong too.
And did you do the check with that option enabled? This can cause delay=
s in kernel enough to do actually write to the network before code in c=
ommit freed non-send data blocks.
I have it disabled all the time.

And you can check it by compiling a kernel over NFS, or big git merges =
over NFS, or doing big ftp transfer, etc.

--
 =E1=CE=C4=D2=C5=CA
