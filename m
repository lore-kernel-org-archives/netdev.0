From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCHv3 9/9] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Mon, 3 Nov 2014 23:58:23 +0100 (CET)
Message-ID: <1415672191.1021851.1415055503664.JavaMail.open-xchange@oxbsltgw07.schlund.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de> <1414502584-10583-1-git-send-email-LW@KARO-electronics.de> <1414502584-10583-10-git-send-email-LW@KARO-electronics.de>
Reply-To: Stefan Wahren <stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org,
	=?UTF-8?Q?=22Lothar_Wa=C3=9Fmann=22?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-10-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Lothar,

> Lothar Wa=C3=9Fmann <LW@KARO-electronics.de> hat am 28. Oktober 2014 =
um 14:23
> geschrieben:
>
>
> commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx
> performance")
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

i think i experience the same problem with 3.18-rc2 on my mx28 board. I=
 get
strange warnings about unexpected bytes from ping on my mx28 board and =
ping to
my mx28 board fails because of no response.

After applying the complete patch series these problems disappear. I'm =
looking
forward to see V4.

Thanks Stefan
