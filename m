From: "Balasaygun, Oray (Oray)" <oray@lucent.com>
Subject: RE: [Bugme-new] [Bug 4310] New: ppc 8260 fcc ethernet driver cann
	ot read LXT971 PHY id
Date: Wed, 9 Mar 2005 08:35:42 -0500
Message-ID: <B99995113B318D44BBE87DC50092EDA913E1BC8D@nj7460exch006u.ho.lucent.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_000_01C524AC.E3CA6D1A"
Cc: linuxppc-dev@ozlabs.org, netdev@oss.sgi.com,
        "Nikoonezhad, Danesh (Danesh)" <dnikoonezhad@lucent.com>
To: "'Andrew Morton'" <akpm@osdl.org>,
        "Balasaygun, Oray (Oray)"
	 <oray@lucent.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C524AC.E3CA6D1A
Content-Type: text/plain

Hi,

Attached please find the diff output of the fcc_enet.c that I am running with and the original 2.6.10 version of it.

There are 3 category of differences:

1. The fix for Bug 4310 that I reported: these are the last 6 lines of the diffout file.

2. The fcc_enet.c, as distributed in 2.6.10, does not compile.  Evidently the 2.6 kernel no longer supports the schedule_task() and "struct tq_struct" to go with it. Lines 73 through and including 96 of the diffout file show the changes I made to port schedule_task() into tasklet_schedule(). I should have reported this as a bug too but I forgot about it.

3. The rest of the lines in the diffout file are for the purpose of customizing fcc_enet.c to work with my custom board. These changes are conditional on CONFIG_EON8260 being defined.

Oray Balasaygun

-----Original Message-----
From: Andrew Morton [mailto:akpm@osdl.org]
Sent: Tuesday, March 08, 2005 2:49 PM
To: oray@lucent.com
Cc: linuxppc-dev@ozlabs.org; netdev@oss.sgi.com
Subject: Re: [Bugme-new] [Bug 4310] New: ppc 8260 fcc ethernet driver
cannot read LXT971 PHY id



I'm not sure that we have a maintainer for fcc_enet.c.  Could you
please send in a tested diff?

bugme-daemon@osdl.org wrote:
>
> http://bugme.osdl.org/show_bug.cgi?id=4310
> 
>            Summary: ppc 8260 fcc ethernet driver cannot read LXT971 PHY id
>     Kernel Version: 2.6.10
>             Status: NEW
>           Severity: normal
>              Owner: platform_ppc-32@kernel-bugs.osdl.org
>          Submitter: oray@lucent.com
> 
> 
> Distribution: www.kernel.org
> Hardware Environment: Target: PowerPC 8260 custom board
> Software Environment: Red Hat 9 cross development using ELDK 3.1 distribution.
> Problem Description: Fast ethernet driver (fcc_enet.c) initialization fails to
> read a valid id from registers 2 and 3 of the LXT971 PHY device and calls the
> panic routine. The bug is in the mii_send_receive() function. During the read
> phase, per LXT971 data sheet, the device starts driving the MDIO line after the
> rising edge of the MDC clock and it could take up to 150ns before the data
> settles. The driver reads the MDIO line before waiting for the data to settle
> down and thus reads in garbage. I fixed the problem by moving the sampling of
> the MDIO line to after the MDC clock is taken low. The code snippet follows:   
> 
> 
>                 for (i = 0, off = 15; i < 16; i++, off--)
>                 {
> #define FCC_8260_BUG
>                         FCC_PDATC_MDC(1);
>                         retval <<= 1;
> #ifndef FCC_8260_BUG
>                         if (io->iop_pdatc & fip->fc_mdio)
>                                 retval++;
>                         udelay(1);
>                         FCC_PDATC_MDC(0);
> #else
>                         udelay(1);
>                         FCC_PDATC_MDC(0);
>                         if (io->iop_pdatc & fip->fc_mdio)
>                                 retval++;
> #endif
>                         udelay(1);
> #undef FCC_8260_BUG
>                 }
> 
> 
> Steps to reproduce: Is likely to happen on an 8260 target with any kind of PHY,
> not just the LXT971, hooked up to the FCC port.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.


------_=_NextPart_000_01C524AC.E3CA6D1A
Content-Type: application/octet-stream;
	name="diffout"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="diffout"

180,227d179=0A=
< #ifdef CONFIG_EON8260=0A=
< =0A=
< #define MAKE_BITMASK(n) (1 << (31-n))=0A=
< =0A=
< #define PA8  MAKE_BITMASK(8)=0A=
< #define PA9  MAKE_BITMASK(9)=0A=
< =0A=
< #define PB18 MAKE_BITMASK(18)=0A=
< #define PB19 MAKE_BITMASK(19)=0A=
< #define PB20 MAKE_BITMASK(20)=0A=
< #define PB21 MAKE_BITMASK(21)=0A=
< #define PB22 MAKE_BITMASK(22)=0A=
< #define PB23 MAKE_BITMASK(23)=0A=
< #define PB24 MAKE_BITMASK(24)=0A=
< #define PB25 MAKE_BITMASK(25)=0A=
< #define PB26 MAKE_BITMASK(26)=0A=
< #define PB27 MAKE_BITMASK(27)=0A=
< #define PB28 MAKE_BITMASK(28)=0A=
< #define PB29 MAKE_BITMASK(29)=0A=
< #define PB30 MAKE_BITMASK(30)=0A=
< #define PB31 MAKE_BITMASK(31)=0A=
< =0A=
< #define PB2_TXER        PB31=0A=
< #define PB2_RXDV        PB30=0A=
< #define PB2_TXEN        PB29=0A=
< #define PB2_RXER        PB28=0A=
< #define PB2_COL         PB27=0A=
< #define PB2_CRS         PB26=0A=
< #define PB2_TXDAT       (PB22 | PB23 | PB24 | PB25)=0A=
< #define PB2_RXDAT       (PB18 | PB19 | PB20 | PB21)=0A=
< #define PB2_PSORB0      (PB2_RXDAT | PB2_TXDAT | PB2_CRS | PB2_COL | =
\=0A=
<                                 PB2_RXER | PB2_RXDV | PB2_TXER)=0A=
< #define PB2_PSORB1      (PB2_TXEN)=0A=
< #define PB2_DIRB0       (PB2_RXDAT | PB2_CRS | PB2_COL | PB2_RXER | =
PB2_RXDV)=0A=
< #define PB2_DIRB1       (PB2_TXDAT | PB2_TXEN | PB2_TXER)=0A=
< =0A=
< /* CLK16 (PC16) is receive, CLK15 (PC17) is transmit */=0A=
< =0A=
< #define PC_F2RXCLK      ((uint)0x00008000)=0A=
< #define PC_F2TXCLK      ((uint)0x00004000)=0A=
< =0A=
< #define CMXFCR_TF2CS_CLK15 0x00060000   /* Transmit FCC2 Clock Source =
is CLK15 */=0A=
< #define CMXFCR_RF2CS_CLK16 0x00380000   /*  Receive FCC2 Clock Source =
is CLK16 */=0A=
< #define CMX2_CLK_ROUTE  (CMXFCR_RF2CS_CLK16 | CMXFCR_TF2CS_CLK15)=0A=
< #define CMX2_CLK_MASK   ((uint)0x00ff0000)=0A=
< =0A=
< #else /* #ifdef CONFIG_EON8260 */=0A=
< =0A=
259,260d210=0A=
< #endif /* #ifdef CONFIG_EON8260 */=0A=
< =0A=
287,291c237=0A=
< #if defined (CONFIG_EON8260)=0A=
< /* EON8260 has MDIO and MDCK on PC31 and PC30 respectively */=0A=
< #define PC_MDIO         ((uint)0x00000001)=0A=
< #define PC_MDCK         ((uint)0x00000002)=0A=
< #elif defined (CONFIG_TQM8260)=0A=
---=0A=
> #ifdef	CONFIG_TQM8260=0A=
325c271=0A=
< # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || =
defined(CONFIG_EON8260)=0A=
---=0A=
> # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)=0A=
334c280=0A=
< # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || =
defined(CONFIG_EON8260)=0A=
---=0A=
> # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)=0A=
345c291=0A=
< # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || =
defined(CONFIG_EON8260)=0A=
---=0A=
> # if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)=0A=
386c332=0A=
< 	struct tasklet_struct phy_task;=0A=
---=0A=
> 	struct tq_struct phy_task;=0A=
1303c1249=0A=
< 	fep->phy_task.func =3D (void *)mii_relink;=0A=
---=0A=
> 	fep->phy_task.routine =3D (void *)mii_relink;=0A=
1305c1251=0A=
< 	tasklet_schedule(&fep->phy_task);=0A=
---=0A=
> 	schedule_task(&fep->phy_task);=0A=
1312c1258=0A=
< 	fep->phy_task.func =3D (void *)mii_display_config;=0A=
---=0A=
> 	fep->phy_task.routine =3D (void *)mii_display_config;=0A=
1314c1260=0A=
< 	tasklet_schedule(&fep->phy_task);=0A=
---=0A=
> 	schedule_task(&fep->phy_task);=0A=
1521,1523d1466=0A=
< 		cep->phy_task.next =3D NULL;=0A=
< 		cep->phy_task.state =3D 0;=0A=
< 		cep->phy_task.count.counter =3D 0;=0A=
1758,1762d1700=0A=
< #if defined(CONFIG_EON8260)=0A=
<         for (i=3D5; i>=3D0; i--) {=0A=
<                 *eap++ =3D dev->dev_addr[i] =3D =
bd->bi_enetaddr[i];=0A=
<         }=0A=
< #else   /* if defined(CONFIG_EON8260) */=0A=
1783d1720=0A=
< #endif /* if defined(CONFIG_EON8260) */=0A=
2006,2007d1942=0A=
< 			udelay(1);=0A=
< 			FCC_PDATC_MDC(0);=0A=
2010a1946,1947=0A=
> 			FCC_PDATC_MDC(0);=0A=
> 			udelay(1);=0A=

------_=_NextPart_000_01C524AC.E3CA6D1A--
