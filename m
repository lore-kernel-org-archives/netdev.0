From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 25 Mar 2014 17:17:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E8C78@AcuExch.aculab.com>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
 <17142825.cN9DfpvuLc@wuerfel>
 <CAGVrzcbNbc1fyq1cuox8SVZHq1ADNah3CfyXSR--4ZWkf2EtTw@mail.gmail.com>
 <21873900.AIOr1ryy37@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Zhangfei Gao <zhangfei.gao@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>
To: 'Arnd Bergmann' <arnd@arndb.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57348 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754481AbaCYRR7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 13:17:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13287-06 for <netdev@vger.kernel.org>;
 Tue, 25 Mar 2014 17:17:56 +0000 (GMT)
In-Reply-To: <21873900.AIOr1ryy37@wuerfel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann
> > Using a timer to ensure completion of TX packets is a trick that
> > worked in the past, but now that the networking stack got smarter,
> > this might artificially increase the processing time of packets in the
> > transmit path, and this will defeat features like TCP small queues
> > etc.. as could be seen with the mvneta driver [1]. The best way really
> > is to rely on TX completion interrupts when those exist as they cannot
> > lie about the hardware status (in theory) and they should provide the
> > fastest way to complete TX packets.
> 
> By as Zhangfei Gao pointed out, this hardware does not have a working
> TX completion interrupt. Using timers to do this has always just been
> a workaround for broken hardware IMHO.

I remember disabling the 'tx done' interrupt (unless the tx ring
was full) in order to get a significant increase in throughput
due to the reduced interrupt load.
The 'interrupt mitigation' logic on modern hardware probably makes
this less of a problem.

It might be possible to orphan the skb when they are put into the
tx ring, and to significantly limit the number of bytes in the
tx ring (BQL?).
That might upset TCP small queues less than delaying the actual
tx completions.

	David
