From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Mon, 18 Nov 2013 10:09:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B742A@saturn3.aculab.com>
References: <8761s0cqhh.fsf@natisbad.org> <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu> <20131117141940.GA18569@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Cong Wang" <xiyou.wangcong@gmail.com>, <edumazet@google.com>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"Thomas Petazzoni" <thomas.petazzoni@free-electrons.com>
To: "Willy Tarreau" <w@1wt.eu>, "Arnaud Ebalard" <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47018 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751281Ab3KRKLc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 05:11:32 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07281-02 for <netdev@vger.kernel.org>;
 Mon, 18 Nov 2013 10:11:29 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131117141940.GA18569@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I wonder if we can call mvneta_txq_done() from the IRQ handler, which would
> cause some recycling of the Tx descriptors when receiving the corresponding
> ACKs.
> 
> Ideally we should enable the Tx IRQ, but I still have no access to this
> chip's datasheet despite having asked Marvell several times in one year
> (Thomas has it though).
> 
> So it is fairly possible that in your case you can't fill the link if you
> consume too many descriptors. For example, if your server uses TCP_NODELAY
> and sends incomplete segments (which is quite common), it's very easy to
> run out of descriptors before the link is full.

Or you have a significant number of active tcp connections.

Even if there were no requirement to free the skb quickly you still
need to take a 'tx done' interrupt when the link is transmit rate limited.
There are scenarios when there is no receive traffic - eg asymmetric
routing, but testable with netperf UDP transmits.

	David
