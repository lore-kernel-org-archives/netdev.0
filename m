From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 0/3] mvneta: Introduce RSS support
Date: Thu, 26 Nov 2015 20:04:43 +0100
Message-ID: <CAPv3WKczNwtm+dRn=ph4M4gSkTpdu7-5maw8ndJo8jCw8Cumkg@mail.gmail.com>
References: <1448463243-21057-1-git-send-email-gregory.clement@free-electrons.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36448 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbbKZTEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 14:04:44 -0500
Received: by oiww189 with SMTP id w189so51110921oiw.3
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 11:04:44 -0800 (PST)
In-Reply-To: <1448463243-21057-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

You can add:
Tested-by: Marcin Wojtas <mw@semihalf.com>

I checked different queues, the traffic passed through, and the irqs
came to proper CPU's. FYI, in my setup with A388-GP as a bridge, after
attaching two ports to different CPU's there was an increase of
~50kpps (almost 9%) for 64B packets.

Best regards,
Marcin

2015-11-25 15:54 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Hi,
>
> this series is the first step add RSS support on mvneta.
>
> It will allow associating an ethernet interface to a given CPU through
> RSS by using "ethtool -X ethX weight". Indeed, currently I only enable
> one entry in the RSS lookup table. Even if it is not really RSS, it
> allows to get back the irq affinity feature we lost by using the
> percpu interrupt.
>
> Compared to the RFC series I added a missing patch for the series, I
> rebased onto v4.4-rc1 and I fixed the mvneta_config_rss. Marcin
> pointed that making the interrupt should be done on all the CPUs.
>
> Th first patch make the default queue associate to each port and no
> more a global variable.
>
> The second patch really associates the RX queues with the CPUs instead
> of masking the percpu interrupts for doing it. All the RX queues are
> enabled and are statically associated with the CPUs by using a modulo
> of the number of present CPUs. But at this stage only one RX queue
> will receive the stream.
>
> I also choose to associate all the TX queues on the same CPU that the
> one associated to the RX queue. It allows to contain all the
> interrupts on the same CPU. I think that an improvement on this side
> would be the support of the XPS.
>
> The last patch introduces a first level of RSS support through the
> ethtool functions. As explained in the introduction there is only one
> entry in the RSS lookup table which permits at the end to associate an
> mvneta port to a CPU through the RX queues because the mapping is
> static.
>
> Thanks,
>
> Gregory CLEMENT (3):
>   net: mvneta: Make the default queue related for each port
>   net: mvneta: Associate RX queues with each CPU
>   net: mvneta: Add naive RSS support
>
>  drivers/net/ethernet/marvell/mvneta.c | 298 +++++++++++++++++++++++++++++-----
>  1 file changed, 253 insertions(+), 45 deletions(-)
>
> --
> 2.5.0
>
