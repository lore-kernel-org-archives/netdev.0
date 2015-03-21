From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Sat, 21 Mar 2015 20:53:59 +0000
Message-ID: <20150321205359.GM8656@n2100.arm.linux.org.uk>
References: <390621425930628@web28o.yandex.ru>
 <3625951426018334@web26j.yandex.ru>
 <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
 <726281426513068@web10o.yandex.ru>
 <BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
 <994171426532944@web7m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: =?utf-8?B?0J/QsNC90L7QsiDQkNC90LTRgNC10Lk=?= <rockford@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:33713 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbCUUyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 16:54:16 -0400
Content-Disposition: inline
In-Reply-To: <994171426532944@web7m.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 10:09:04PM +0300, =D0=9F=D0=B0=D0=BD=D0=BE=D0=B2=
 =D0=90=D0=BD=D0=B4=D1=80=D0=B5=D0=B9 wrote:
> apx@ct:~$ hd zeros   =20
> 00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |........=
=2E.......|
> *
> 001d4a80  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5  |........=
=2E.......|
> *
> 001d4aa0  1c f0 9f e5 74 fb 00 00  bc ff 93 00 c0 ff 93 00  |....t...=
=2E.......|
> 001d4ab0  c4 ff 93 00 c8 ff 93 00  cc ff 93 00 d0 ff 93 00  |........=
=2E.......|
> 001d4ac0  d4 ff 93 00 d8 ff 93 00  13 00 00 00 28 63 29 20  |........=
=2E...(c) |
> 001d4ad0  43 6f 70 79 72 69 67 68  74 20 32 30 30 37 2d 32  |Copyrigh=
t 2007-2|
> 001d4ae0  30 31 32 2c 20 46 72 65  65 73 63 61 6c 65 20 53  |012, Fre=
escale S|
> 001d4af0  65 6d 69 63 6f 6e 64 75  63 74 6f 72 2e 20 41 6c  |emicondu=
ctor. Al|
> 001d4b00  6c 20 72 69 67 68 74 73  20 72 65 73 65 72 76 65  |l rights=
 reserve|
> 001d4b10  64 2e 00 00 dd 00 2c 41  11 73 00 00 d3 74 00 00  |d.....,A=
=2Es...t..|
> 001d4b20  3d 75 00 00 a9 78 00 00  4f 78 00 00 75 77 00 00  |=3Du...x=
=2E.Ox..uw..|
> 001d4b30  07 76 00 00 c3 79 00 00  09 7a 00 00 75 7a 00 00  |.v...y..=
=2Ez..uz..|

I'm seeing this too with 4.0-rc4 _without_ net-next:

0000ba00  2d 20 d4 e5 80 00 52 e3  01 00 52 13 00 20 a0 03  |- ....R...=
R.. ..|
0000ba10  01 20 a0 13 a4 00 00 0a  1c f0 9f e5 1c f0 9f e5  |. ........=
=2E.....|
0000ba20  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5  |..........=
=2E.....|
0000ba30  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 74 fb 00 00  |..........=
=2E.t...|
0000ba40  bc ff 93 00 c0 ff 93 00  c4 ff 93 00 c8 ff 93 00  |..........=
=2E.....|
0000ba50  cc ff 93 00 d0 ff 93 00  d4 ff 93 00 d8 ff 93 00  |..........=
=2E.....|
0000ba60  13 00 00 00 28 63 29 20  43 6f 70 79 72 69 67 68  |....(c) Co=
pyrigh|
0000ba70  74 20 32 30 30 37 2d 32  30 31 32 2c 20 46 72 65  |t 2007-201=
2, Fre|
0000ba80  65 73 63 61 6c 65 20 53  65 6d 69 63 6f 6e 64 75  |escale Sem=
icondu|
0000ba90  63 74 6f 72 2e 20 41 6c  6c 20 72 69 67 68 74 73  |ctor. All =
rights|
0000baa0  20 72 65 73 65 72 76 65  64 2e 00 00 dd 00 2c 41  | reserved.=
=2E...,A|
0000bab0  11 73 00 00 d3 74 00 00  3d 75 00 00 a9 78 00 00  |.s...t..=3D=
u...x..|
0000bac0  4f 78 00 00 75 77 00 00  07 76 00 00 c3 79 00 00  |Ox..uw...v=
=2E..y..|
0000bad0  09 7a 00 00 75 7a 00 00  97 22 00 00 49 1f 00 00  |.z..uz..."=
=2E.I...|
0000bae0  b9 21 00 00 ff 70 00 00  90 21 90 00 23 4a 52 f8  |.!...p...!=
=2E.#JR.|
0000baf0  20 00 00 68 c8 40 00 f0  01 00 70 47 10 b5 01 23  | ..h.@....=
pG...#|
0000bb00  1e 4c 1c 3c 8b 40 54 f8  20 00 01 68 0a b1 19 43  |.L.<.@T. .=
=2Eh...C|

In my case, this appeared in the middle of the bluetooth.ko module.

If we look at physical memory at zero (I'll omit the devmem2 commands):

Value at address 0x00000000: 0xe59ff01c
Value at address 0x00000004: 0xe59ff01c
Value at address 0x00000008: 0xe59ff01c
Value at address 0x0000000c: 0xe59ff01c
Value at address 0x00000010: 0xe59ff01c
Value at address 0x00000014: 0xe59ff01c
Value at address 0x00000018: 0xe59ff01c
Value at address 0x0000001c: 0xe59ff01c
Value at address 0x00000020: 0xe59ff01c
Value at address 0x00000024: 0x0000fb74
Value at address 0x00000028: 0x0093ffbc
Value at address 0x0000002c: 0x0093ffc0
Value at address 0x00000030: 0x0093ffc4
Value at address 0x00000034: 0x0093ffc8
Value at address 0x00000038: 0x0093ffcc
Value at address 0x0000003c: 0x0093ffd0
Value at address 0x00000040: 0x0093ffd4
Value at address 0x00000044: 0x0093ffd8
Value at address 0x00000048: 0x00000013
Value at address 0x0000004c: 0x20296328 <=3D=3D start of (c) string.
Value at address 0x00000050: 0x79706f43
Value at address 0x00000054: 0x68676972
Value at address 0x00000058: 0x30322074
Value at address 0x0000005c: 0x322d3730
Value at address 0x00000060: 0x2c323130
Value at address 0x00000064: 0x65724620
Value at address 0x00000068: 0x61637365
Value at address 0x0000006c: 0x5320656c
Value at address 0x00000070: 0x63696d65
Value at address 0x00000074: 0x75646e6f
Value at address 0x00000078: 0x726f7463
Value at address 0x0000007c: 0x6c41202e
Value at address 0x00000080: 0x6972206c

This matches the "corruption".  So, the FEC driver is DMAing from
physical address zero.  There's only two ways this can happen - either
if dma_map_single() returns zero, or if the ring already contains a
zero address.

I've thrown into the FEC driver a load of WARN_ON_ONCE(addr =3D=3D 0) a=
fter
_every_ dma_map_single(), and I also have pre-standing detection of
highmem pages in fec_enet_txq_submit_frag_skb().  None of this is firin=
g.

We know that the ARM architecture can write to memory (which includes
memory allocated via dma_alloc_coherent()) with weak ordering, so to
rule that out, I tried adding a barrier between writing the address
and size, and writing the status field everywhere where we touch the
transmit ring.  That had no effect; I still see the corruption.

Next, I've tried setting free descriptors to have a physical address
of 0x40 - which should change the pattern of the corruption (in that
the "(c)" string should appear earlier in the corruption.)  The
reasoning is to prove whether the FEC TX DMA is reading from zero
because it's being instructed to in the transmit ring, or whether
there's something else going on.  The result is (in a different module)=
:

00001000  61 6c 5f 72 65 67 69 73  74 65 72 5f 64 72 69 76  |al_registe=
r_driv|
00001010  65 72 73 00 00 00 00 00  00 00 00 00 00 00 00 00  |ers.......=
=2E.....|
00001020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |..........=
=2E.....|
00001030  00 00 00 00 1d 84 2e 2b  75 73 62 5f 73 65 72 69  |.......+us=
b_seri|
00001040  61 6c 5f 67 65 6e 65 72  69 63 5f 6f 70 65 6e 00  |al_generic=
_open.|
00001050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |..........=
=2E.....|
00001060  00 00 00 00 00 00 00 00  d4 ff 93 00 d8 ff 93 00  |..........=
=2E.....|
00001070  13 00 00 00 28 63 29 20  43 6f 70 79 72 69 67 68  |....(c) Co=
pyrigh|
00001080  74 20 32 30 30 37 2d 32  30 31 32 2c 20 46 72 65  |t 2007-201=
2, Fre|
00001090  65 73 63 61 6c 65 20 53  65 6d 69 63 6f 6e 64 75  |escale Sem=
icondu|
000010a0  63 74 6f 72 2e 20 41 6c  6c 20 72 69 67 68 74 73  |ctor. All =
rights|
000010b0  20 72 65 73 65 72 76 65  64 2e 00 00 dd 00 2c 41  | reserved.=
=2E...,A|
000010c0  11 73 00 00 d3 74 00 00  3d 75 00 00 a9 78 00 00  |.s...t..=3D=
u...x..|
000010d0  4f 78 00 00 75 77 00 00  07 76 00 00 c3 79 00 00  |Ox..uw...v=
=2E..y..|

Here, the bytes which start at 0x1068 match what's in the iMX6 at addre=
ss
0x40, but the bytes which would've come before are missing.  So, the FE=
C
is transmitting from a descriptor in the ring which contains an address
which has been freed - and that's with my additional barriers in place
which should ensure that the descriptor gets the address and size updat=
es
_before_ it sees that it owns the descriptor.

The question is how, and this can be revealed by this bit of debugging =
in
fec_enet_tx_queue():

                for (i =3D 0; i < bdnum; i++) {
                        if (WARN_ON_ONCE(bdp->cbd_sc & BD_ENET_TX_READY=
))
                                fec_dump(ndev);
                        if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
                                dma_unmap_single(&fep->pdev->dev, bdp->=
cbd_bufaddr,
                                                 bdp->cbd_datlen, DMA_T=
O_DEVICE);
                        bdp->cbd_bufaddr =3D 0x40;
                        if (i < bdnum - 1)
                                bdp =3D fec_enet_get_nextdesc(bdp, fep,=
 queue_id);
                }
                txq->tx_skbuff[index] =3D NULL;

Sure enough, that WARN_ON_ONCE() triggers - and we get _soo_ many dumps
of the transmit ring from fec_dump() that it shows that the driver is v=
ery
buggy here.  Here's an illustration of the ring state (un-wrapped to sh=
ow
the order):

 460  H 0x1c00 0x00000040 1448   (null)
 461    0x1400 0x00000040   66   (null)
 462    0x1c00 0x391c0110 1448   (null)
 463    0x1400 0x8005e780   66   (null)
 464    0x1c00 0x3d120000 1448   (null)
 465    0x1400 0x8005e880   66   (null)
 466    0x1c00 0x391c0c60 1448   (null)
 467    0x1400 0x8005e980   66   (null)
 468    0x1c00 0x3d122000 1448   (null)
=2E..
 508    0x1c00 0x3d136000 1448   (null)
 509    0x1400 0x8005fe80   66   (null)
 510    0x1c00 0x391c88d0 1448   (null)
 511    0x3400 0x8005ff80   66   (null)
   0    0x9c00 0x3d038000 1448   (null)
   1    0x9400 0x80050080   66   (null)
   2    0x9c00 0x391c9420 1448   (null)
   3    0x9400 0x80050180   66   (null)
=2E..
  17    0x9400 0x80050880   66   (null)
  18    0x9c00 0x391cc160 1448   (null)
  19    0x9400 0x80050980   66   (null)
  20    0x9c00 0x3d042000  704 ec6106b0
  21 S  0x1c00 0x00000040 1448   (null)

We hit entry 462, and found that it was still owned by the FEC, so we
triggered the dump - during the time it took to produce the dump,
packets from 462 up to 511 were transmitted, clearing their ownership
bit (bit 15 of the first word.)

How can this happen?  Well, if we're submitted a _huge_ unfragmented
TSO skbuff, then:

                index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp_t,=
 fep);
                skb =3D txq->tx_skbuff[index];
                while (!skb) {
                        bdp_t =3D fec_enet_get_nextdesc(bdp_t, fep, que=
ue_id);
                        index =3D fec_enet_get_bd_index(txq->tx_bd_base=
, bdp_t, fep);
                        skb =3D txq->tx_skbuff[index];
                        bdnum++;
                }
                if (skb_shinfo(skb)->nr_frags &&
                    (status =3D bdp_t->cbd_sc) & BD_ENET_TX_READY)
                        break;

skb_shinfo(skb)->nr_frags will be zero, and so we won't test whether th=
e
last entry in the submitted group has finished being transmitted - inst=
ead,
we will blindly continue on to the loop which frees all the descriptors=
,
trampling over those which haven't yet been transmitted.

I can see no reason to test for skb_shinfo(skb)->nr_frags here.  If the
last buffer descriptor for the submitted skb is marked as still being
busy, then the skb *can't* be reaped.  There's no question whether it's
a fragmented skb or not - that's completely irrelevant.

In fact, with that bogus test removed, the corruption goes away.  Patch
below for others to test - once I've finished removing the rest of my
debugging, I'll send it properly.

(It should be noted that calling fec_dump() as per above is enough to m=
ake
the bug go away - because it delays overwriting the buffer address long
enough that the FEC can transmit the packets before we stomp over the
still-to-be-transmitted entries.)

Given that this bug can seriously screw data up in undetectable ways (T=
CP
checksums don't save you, because the FEC generates them on the data wh=
ich
it read from memory, even if it happened to read the data from the SoC'=
s
boot ROM) we do need to get this fixed ASAP.

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index f9c0baea12ed..8bb2a811df3e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1227,8 +1227,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 qu=
eue_id)
 			skb =3D txq->tx_skbuff[index];
 			bdnum++;
 		}
-		if (skb_shinfo(skb)->nr_frags &&
-		    (status =3D bdp_t->cbd_sc) & BD_ENET_TX_READY)
+		if ((status =3D bdp_t->cbd_sc) & BD_ENET_TX_READY)
 			break;
=20
 		for (i =3D 0; i < bdnum; i++) {


--=20
=46TTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps u=
p
according to speedtest.net.
