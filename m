From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 1/1] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Fri, 07 Nov 2014 12:09:26 -0500 (EST)
Message-ID: <20141107.120926.297493918093719160.davem@davemloft.net>
References: <1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
	<1415350967-2238-2-git-send-email-LW@KARO-electronics.de>
	<CAOMZO5Cb1=Nvzu8EHqmV+K+W+ZJxzL1=5MnK6hDSstwh9ruweA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LW@karo-electronics.de, netdev@vger.kernel.org,
	fabio.estevam@freescale.com, Frank.Li@freescale.com,
	linux-kernel@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, stefan.wahren@i2se.com
To: festevam@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5Cb1=Nvzu8EHqmV+K+W+ZJxzL1=5MnK6hDSstwh9ruweA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Fabio Estevam <festevam@gmail.com>
Date: Fri, 7 Nov 2014 10:26:15 -0200

> On Fri, Nov 7, 2014 at 7:02 AM, Lothar Wa=DFmann <LW@karo-electronics=
=2Ede> wrote:
>> commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx=
 performance")
>> introduced a regression for i.MX28. The swap_buffer() function doing
>> the endian conversion of the received data on i.MX28 may access memo=
ry
>> beyond the actual packet size in the DMA buffer. fec_enet_copybreak(=
)
>> does not copy those bytes, so that the last bytes of a packet may be
>> filled with invalid data after swapping.
>> This will likely lead to checksum errors on received packets.
>> E.g. when trying to mount an NFS rootfs:
>> UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 ul=
en 36
>>
>> Do the byte swapping and copying to the new skb in one go if
>> necessary.
>>
>> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
>=20
> With this patch I am able to NFS mount on mx28 again. Thanks, Lothar!
>=20
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks everyone.
