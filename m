From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 17:05:43 +0100
Message-ID: <1324483543.2301.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
	 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B5BC.5020103@monstr.eu>
	 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B7E4.4010602@monstr.eu>
	 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324465386.2728.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1BEA4.7080005@monstr.eu>
	 <1324466023.2728.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1C80B.4060701@monstr.eu>
	 <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1DF00.1090309@monstr.eu>
	 <1324474811.2728.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1EC28.90008@monstr.eu>
	 <1324481439.2301.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324482285.2301.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324483302.6471.3.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63049 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab1LUQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 11:05:47 -0500
Received: by werm1 with SMTP id m1so2765971wer.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 08:05:46 -0800 (PST)
In-Reply-To: <1324483302.6471.3.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 00:01 +0800, Jun Zhao a =C3=A9cri=
t :

> Why receive buffer size MUST bigger than the jumbo frames size even i=
f
> the packet size is small?

Thats the way it is in linux.

We count the memory size used by the packet.

If not, a malicious attacker could send 1-byte frames and exhaust your
kernel memory.

If you want to reduce it, you might use copybreak : Some drivers copy
the data into a small skb instead of providing a jumbo frame to upper
stack.

tg3 for example.
