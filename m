From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [RFC PATCH 0/2] net: mvneta: Introduce RSS support
Date: Fri, 6 Nov 2015 20:37:38 +0100
Message-ID: <CAPv3WKcOLsjGj1iyEiPdPkdkNS2O1-RytNMZUCgUCv9QUdY6FA@mail.gmail.com>
References: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,


> I also choose to associate all the TX queues on the same CPU that the
> one associated to the RX queue. It allows to contain all the
> interrupts on the same CPU. I think that an improvement on this side
> would be the support of the XPS.
>

Did you make some tries? E.g. after mapping certain txqs to CPU1, when
using them was mvneta_tx() executing only on this CPU? Or it rather
means that the irq will hit according to the mapping? As far as I know
the HW, the latter should be true, which would mean the real XPS with
this controller is impossible and the maximum we can control is the
irq.

I think it may be worth to unmask TX irqs on all cpus, so all percpu
napi's would be able to read tx_cause and process sent packets. I'm
looking forward to your opinion.

Best regards,
Marcin
