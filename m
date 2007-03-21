From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Thu, 22 Mar 2007 00:26:42 +0100
Message-ID: <4601BF32.5070300@cosmosbay.com>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu> <460064C6.5030302@cosmosbay.com> <4601A949.2000005@fw.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Zacco <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.cosmosbay.com ([86.65.150.131]:58881 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751480AbXCUX1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 19:27:13 -0400
In-Reply-To: <4601A949.2000005@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zacco a =E9crit :
> So, my worry is confirmed then. But how could that delay disappear wh=
en=20
> splitting the sender and receiver on distinct hosts? Even in that cas=
e=20
> the good socket must be found somehow.


When the receiver and sender are on the same machine, the sendto() pass=
 the=20
packet to loopback and enters the receiving side. With that many socket=
s, the=20
time to go through all sockets maybe 100 us. So your sendto() seems to =
be=20
slow, but the slow part is the receiver.

If you put two machines, the sender might send XX.XXX frames per second=
 (full=20
speed), but the receiver might handle 5% of them and drop 95%

This is all speculation, since you didnt gave us the exact setup you us=
e.

