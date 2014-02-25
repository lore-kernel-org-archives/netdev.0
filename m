From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Wed, 26 Feb 2014 00:48:57 +0200
Message-ID: <CAJZOPZ+C55GriKwhQ7Efa6cqDavZQP6FxfbJx4xmuCi-VZp-OQ@mail.gmail.com>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz>
	<CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
	<alpine.LNX.2.00.1402252307130.5180@pobox.suse.cz>
	<CAJZOPZJpRYKw7Dskr21QP_d6c7ySS+mi-g_19pNJYm0Gq=ZY+g@mail.gmail.com>
	<alpine.LNX.2.00.1402252338480.5180@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402252338480.5180@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 12:40 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Wed, 26 Feb 2014, Or Gerlitz wrote:
>
>>>> And what happens if you use IPoIB datagram mode, is/why the patch is
>>>> needed there?

>>> I admittedly am no infiniband expert, but my understanding is that in
>>> principle Connected/Datagram mode is about MTU and checksum
>>> offloading


>> yes, the differences between the mode relate to these aspects, however

> Thanks for confirming

Still, even if different, I still don't see why not use datagram mode
if the problem hits you only for connected mode. E.g datagram mode
supports LSO/GRO and TX/RX checksum offloads which should cover on the
smaller MTU vs. connected mode


>> > but the TX path is the same. Please correct me if I am wrong.

>> no, note that your patch only touched drivers/infiniband/ulp/ipoib/ipoib_cm.c
>> which is basically compiled out if you set CONFIG_INFINIBAND_IPOIB_CM,
>> so surely the TX path for the datagram vs. connected modes are
>> different.

> Yes, but for datagram mode, the tx_ring is allocated in a completely
> different way (not from kworker), so this might be a non-issue, right? I
> will have to look into it more deeply to be really sure; if you can
> provide your insight, that'd be helpful.


Note that even when operating in connected mode, the ipoib net-device
instance can speak in datagram mode with remote nodes who don't
support connected mor and/or when sending multicast -- specifically
ipoib_dev_init() does the setup of the TX ring. Maybe you can just try
this out and see if it works?
