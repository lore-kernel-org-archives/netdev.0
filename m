From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCHv4 1/1] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Fri, 7 Nov 2014 10:26:15 -0200
Message-ID: <CAOMZO5Cb1=Nvzu8EHqmV+K+W+ZJxzL1=5MnK6hDSstwh9ruweA@mail.gmail.com>
References: <1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
	<1415350967-2238-2-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Stefan Wahren <stefan.wahren@i2se.com>
To: =?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415350967-2238-2-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 7, 2014 at 7:02 AM, Lothar Wa=C3=9Fmann <LW@karo-electronic=
s.de> wrote:
> commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx =
performance")
> introduced a regression for i.MX28. The swap_buffer() function doing
> the endian conversion of the received data on i.MX28 may access memor=
y
> beyond the actual packet size in the DMA buffer. fec_enet_copybreak()
> does not copy those bytes, so that the last bytes of a packet may be
> filled with invalid data after swapping.
> This will likely lead to checksum errors on received packets.
> E.g. when trying to mount an NFS rootfs:
> UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 ule=
n 36
>
> Do the byte swapping and copying to the new skb in one go if
> necessary.
>
> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>

With this patch I am able to NFS mount on mx28 again. Thanks, Lothar!

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
