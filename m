From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Wed, 21 Oct 2009 12:18:06 -0700
Message-ID: <1256152686.8469.34.camel@localhost.localdomain>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	 <20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	 <20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	 <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	 <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	 <20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703AbZJUTSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2009 15:18:03 -0400
In-Reply-To: <20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-10-18 at 10:39 +0900, Ken Kawasaki wrote:
> pcnet_cs,serial_cs:
> 
> add cis of PreMax ethernet pcmcia card,
> and some Sierra Wireless serial card(AC555, AC7xx, AC8xx).

Random question: are CIS files copyrightable?  What exactly do they
contain, just updates to the the CIS data on the card itself that the
manufacturer forgot to burn before shipping the card?

Also, I've got a Sierra AC860 here that reports as "prod_id(2):
"AC860"", and has the same manf_id (0x0192) and card_id (0x710) as the
AC850.

manf_id: 0x0192 card_id: 0x0710
function: 6 (network)
prod_id(1): "Sierra Wireless" (0xd85f6206)
prod_id(2): "AC860" (0x698f93db)
prod_id(3): "3G Network Adapter" (0xab3c6f47)
prod_id(4): "R1" (0xd9533fec)

It currently requests the 7xx CIS file because there isn't a specific
check for it in the driver and it uses the default 7xx manfid/prodid,
should I submit something like:

+	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC860", 0xd85f6206, 0x698f93db, "cis/SW_8xx_SER.cis"), /* Sierra Wireless AC860 3G Network Adapter R1 */

?

Dan

> use PROD_ID for AC7xx, because MANF_ID of AC7xx and AC8xx are the same.
> 
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
> 
> ---
> 
>  drivers/net/pcmcia/pcnet_cs.c    |    2 +-
>  drivers/serial/serial_cs.c       |    8 ++++----
>  firmware/Makefile                |    6 ++++--
>  firmware/WHENCE                  |    4 ++++
>  firmware/cis/PE-200.cis.ihex     |    9 +++++++++
>  firmware/cis/SW_555_SER.cis.ihex |   12 ++++++++++++
>  firmware/cis/SW_7xx_SER.cis.ihex |   13 +++++++++++++
>  firmware/cis/SW_8xx_SER.cis.ihex |   13 +++++++++++++
>  8 files changed, 60 insertions(+), 7 deletions(-)
> 
> diff -urpN linux-2.6.32-rc5.orig/drivers/net/pcmcia/pcnet_cs.c linux-2.6.32-rc5/drivers/net/pcmcia/pcnet_cs.c
> --- linux-2.6.32-rc5.orig/drivers/net/pcmcia/pcnet_cs.c	2009-10-17 15:53:44.000000000 +0900
> +++ linux-2.6.32-rc5/drivers/net/pcmcia/pcnet_cs.c	2009-10-17 16:07:12.000000000 +0900
> @@ -1760,7 +1760,7 @@ static struct pcmcia_device_id pcnet_ids
>  	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "cis/LA-PCM.cis"),
>  	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "PE520.cis"),
>  	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "cis/NE2K.cis"),
> -	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "PE-200.cis"),
> +	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "cis/PE-200.cis"),
>  	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "cis/tamarack.cis"),
>  	PCMCIA_DEVICE_PROD_ID12("Ethernet", "CF Size PC Card", 0x00b2e941, 0x43ac239b),
>  	PCMCIA_DEVICE_PROD_ID123("Fast Ethernet", "CF Size PC Card", "1.0",
> diff -urpN linux-2.6.32-rc5.orig/drivers/serial/serial_cs.c linux-2.6.32-rc5/drivers/serial/serial_cs.c
> --- linux-2.6.32-rc5.orig/drivers/serial/serial_cs.c	2009-10-17 15:53:45.000000000 +0900
> +++ linux-2.6.32-rc5/drivers/serial/serial_cs.c	2009-10-17 16:02:50.000000000 +0900
> @@ -879,10 +879,10 @@ static struct pcmcia_device_id serial_id
>  	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0175, 0x0000, "cis/DP83903.cis"),
>  	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0035, "cis/3CXEM556.cis"),
>  	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x003d, "cis/3CXEM556.cis"),
> -	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC850", 0xd85f6206, 0x42a2c018, "SW_8xx_SER.cis"),  /* Sierra Wireless AC850 3G Network Adapter R1 */
> -	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0x0710, "SW_7xx_SER.cis"),	/* Sierra Wireless AC710/AC750 GPRS Network Adapter R1 */
> -	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
> -	PCMCIA_DEVICE_CIS_MANF_CARD(0x013f, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- post update */
> +	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC850", 0xd85f6206, 0x42a2c018, "cis/SW_8xx_SER.cis"), /* Sierra Wireless AC850 3G Network Adapter R1 */
> +	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC710/AC750", 0xd85f6206, 0x761b11e0, "cis/SW_7xx_SER.cis"),  /* Sierra Wireless AC710/AC750 GPRS Network Adapter R1 */
> +	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "cis/SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
> +	PCMCIA_DEVICE_CIS_MANF_CARD(0x013f, 0xa555, "cis/SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- post update */
>  	PCMCIA_DEVICE_CIS_PROD_ID12("MultiTech", "PCMCIA 56K DataFax", 0x842047ee, 0xc2efcf03, "cis/MT5634ZLX.cis"),
>  	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-2", 0x96913a85, 0x27ab5437, "cis/COMpad2.cis"),
>  	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-4", 0x96913a85, 0xcec8f102, "cis/COMpad4.cis"),
> diff -urpN linux-2.6.32-rc5.orig/firmware/cis/PE-200.cis.ihex linux-2.6.32-rc5/firmware/cis/PE-200.cis.ihex
> --- linux-2.6.32-rc5.orig/firmware/cis/PE-200.cis.ihex	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/cis/PE-200.cis.ihex	2009-10-17 16:13:21.000000000 +0900
> @@ -0,0 +1,9 @@
> +:1000000001030000FF151E0401504D582020200060
> +:1000100050452D3230300045544845524E4554002D
> +:1000200052303100FF210206031A050101000101CF
> +:100030001B0EC181190155E051000F100F30FFFF59
> +:040040001400FF00A9
> +:00000001FF
> +#
> +# Replacement CIS for PE-200 ethernet card
> +#
> diff -urpN linux-2.6.32-rc5.orig/firmware/cis/SW_555_SER.cis.ihex linux-2.6.32-rc5/firmware/cis/SW_555_SER.cis.ihex
> --- linux-2.6.32-rc5.orig/firmware/cis/SW_555_SER.cis.ihex	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/cis/SW_555_SER.cis.ihex	2009-10-17 16:12:47.000000000 +0900
> @@ -0,0 +1,12 @@
> +:100000000101FF17034100FF20043F0110072102F7
> +:100010000200152A070053696572726120576972E0
> +:10002000656C657373004169724361726420353594
> +:1000300035004135353500526576203100FF1A050F
> +:1000400001030007731B0BE00118A360F8030730DE
> +:10005000BC3F1B08A10108A360F802071B08A2010E
> +:1000600008A360E803071B08A30108A360E80207D0
> +:0A0070001B04A40108231400FF0084
> +:00000001FF
> +#
> +# Replacement CIS for AC555 provided by Sierra Wireless
> +#
> diff -urpN linux-2.6.32-rc5.orig/firmware/cis/SW_7xx_SER.cis.ihex linux-2.6.32-rc5/firmware/cis/SW_7xx_SER.cis.ihex
> --- linux-2.6.32-rc5.orig/firmware/cis/SW_7xx_SER.cis.ihex	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/cis/SW_7xx_SER.cis.ihex	2009-10-17 16:12:47.000000000 +0900
> @@ -0,0 +1,13 @@
> +:100000000101FF17034100FF2004920110072102A4
> +:1000100002001537070053696572726120576972D3
> +:10002000656C6573730041433731302F4143373579
> +:10003000300047505253204E6574776F726B2041E9
> +:1000400064617074657200523100FF1A050103008B
> +:1000500007731B10E00119784D555D25A360F80367
> +:100060000730BC861B08A10108A360F802071B0823
> +:10007000A20108A360E803071B08A30108A360E826
> +:0C00800002071B04A40108231400FF0069
> +:00000001FF
> +#
> +# Replacement CIS for AC7xx provided by Sierra Wireless
> +#
> diff -urpN linux-2.6.32-rc5.orig/firmware/cis/SW_8xx_SER.cis.ihex linux-2.6.32-rc5/firmware/cis/SW_8xx_SER.cis.ihex
> --- linux-2.6.32-rc5.orig/firmware/cis/SW_8xx_SER.cis.ihex	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/cis/SW_8xx_SER.cis.ihex	2009-10-17 16:12:47.000000000 +0900
> @@ -0,0 +1,13 @@
> +:100000000101FF17034100FF2004920110072102A4
> +:100010000200152F070053696572726120576972DB
> +:10002000656C657373004143383530003347204EAB
> +:100030006574776F726B20416461707465720052F1
> +:100040003100FF1A0501030007731B10E001197846
> +:100050004D555D25A360F8480730BC861B08A101FB
> +:1000600008A360F847071B08A20108A360E8480737
> +:100070001B08A30108A360E847071B04A401082389
> +:040080001400FF0069
> +:00000001FF
> +#
> +# Replacement CIS for AC8xx provided by Sierra Wireless
> +#
> diff -urpN linux-2.6.32-rc5.orig/firmware/Makefile linux-2.6.32-rc5/firmware/Makefile
> --- linux-2.6.32-rc5.orig/firmware/Makefile	2009-10-17 15:53:52.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/Makefile	2009-10-17 16:12:21.000000000 +0900
> @@ -69,11 +69,13 @@ fw-shipped-$(CONFIG_E100) += e100/d101m_
>  fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
>  fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis cis/PCMLM28.cis \
>  				     cis/DP83903.cis cis/NE2K.cis \
> -				     cis/tamarack.cis
> +				     cis/tamarack.cis cis/PE-200.cis
>  fw-shipped-$(CONFIG_PCMCIA_3C589) += cis/3CXEM556.cis
>  fw-shipped-$(CONFIG_PCMCIA_3C574) += cis/3CCFEM556.cis
>  fw-shipped-$(CONFIG_SERIAL_8250_CS) += cis/MT5634ZLX.cis cis/RS-COM-2P.cis \
> -				       cis/COMpad2.cis cis/COMpad4.cis
> +				       cis/COMpad2.cis cis/COMpad4.cis \
> +				       cis/SW_555_SER.cis cis/SW_7xx_SER.cis \
> +				       cis/SW_8xx_SER.cis
>  fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
>  fw-shipped-$(CONFIG_SCSI_ADVANSYS) += advansys/mcode.bin advansys/38C1600.bin \
>  				      advansys/3550.bin advansys/38C0800.bin
> diff -urpN linux-2.6.32-rc5.orig/firmware/WHENCE linux-2.6.32-rc5/firmware/WHENCE
> --- linux-2.6.32-rc5.orig/firmware/WHENCE	2009-10-17 15:53:52.000000000 +0900
> +++ linux-2.6.32-rc5/firmware/WHENCE	2009-10-17 16:12:04.000000000 +0900
> @@ -600,6 +600,7 @@ File: cis/LA-PCM.cis
>        cis/DP83903.cis
>        cis/NE2K.cis
>        cis/tamarack.cis
> +      cis/PE-200.cis
>  
>  Licence: GPL
>  
> @@ -633,6 +634,9 @@ File: cis/MT5634ZLX.cis
>        cis/RS-COM-2P.cis
>        cis/COMpad2.cis
>        cis/COMpad4.cis
> +      cis/SW_555_SER.cis
> +      cis/SW_7xx_SER.cis
> +      cis/SW_8xx_SER.cis
>  
>  Licence: GPL
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

