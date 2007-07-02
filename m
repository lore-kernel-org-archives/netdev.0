From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 silicon bugs and workarounds...
Date: Mon, 2 Jul 2007 17:10:17 +0100
Message-ID: <6278d2220707020910q1f71f072n2ae4495d6d99d7d2@mail.gmail.com>
References: <6278d2220707020636h7764fb27lb648ce50f1597b4@mail.gmail.com>
	 <6278d2220707020637m2f11a691x9c51ca4bfe823104@mail.gmail.com>
	 <20070702085612.45eb7aeb@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:47728 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbXGBQKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 12:10:19 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1288106ugf
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2007 09:10:18 -0700 (PDT)
In-Reply-To: <20070702085612.45eb7aeb@freepuppy.localdomain.hemminger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Mon, 2 Jul 2007 14:37:06 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> > When the sky2 driver initialises, it sets the the ISR timer register
> > (STAT_ISR_TIMER_INI) to 125 * 20 = 2500, whereas the vendor sk98lin
> > driver sets it to 400, irrespective of the clockspeed of the NIC
> > processor.
> >
> > I guess you found more performance/stability from this value...?

> Not really, it was just a rough guess to try and get more frames
> per irq under DoS load.  Haven't fine tuned those values.

> > I've checked through the errata workarounds common to my rev-1 and 2
> > Yukon-EC chips...the HWF_WA_DEV_4167 "oversize receive hang"
> > workaround checks and can reset the (as I understand) bus master unit
> > of the NIC (in CheckRxPath) in a periodic timer that is fired, where
> > is finds no progress is made.

> Where did you get those errata's. I keep having to do reverse
> engineering guessing with vendor driver.

http://www.syskonnect.de/e_en/products/adapters/pcie_server/sk-9exx/software/linux/driver/install_v10.0.4.3.tar.bz2
from sk98lin.tar.bz2 inside

---> defined in ./common/h/skgeinit.h

/*-RMV- DWORD 1: Deviations */
#define HWF_WA_DEV_53                   0x11000000UL    /*-RMV- 5.3
(Tx Done LSOv2 rep)*/
#define HWF_WA_DEV_LIM_IPV6_RSS 0x10800000UL    /*-RMV- IPV6 RSS limitted */
#define HWF_WA_DEV_4217                 0x10400000UL    /*-RMV- 4.217
(PCI-E blockage) */
#define HWF_WA_DEV_4200                 0x10200000UL    /*-RMV- 4.200
(D3 Blue Screen)*/
#define HWF_WA_DEV_4185CS               0x10100000UL    /*-RMV- 4.185
(ECU 100 CS cal)*/
#define HWF_WA_DEV_4185                 0x10080000UL    /*-RMV- 4.185
(ECU Tx h check)*/
#define HWF_WA_DEV_4167                 0x10040000UL    /*-RMV- 4.167
(Rx OvSize Hang)*/
#define HWF_WA_DEV_4152                 0x10020000UL    /*-RMV- 4.152
(RSS issue) */
#define HWF_WA_DEV_4115                 0x10010000UL    /*-RMV- 4.115
(Rx MAC FIFO) */
#define HWF_WA_DEV_4109                 0x10008000UL    /*-RMV- 4.109
(BIU hang) */
#define HWF_WA_DEV_483                  0x10004000UL    /*-RMV- 4.83
(Rx TCP wrong) */
#define HWF_WA_DEV_479                  0x10002000UL    /*-RMV- 4.79
(Rx BMU hang II) */
#define HWF_WA_DEV_472                  0x10001000UL    /*-RMV- 4.72
(GPHY2 MDC clk) */
#define HWF_WA_DEV_463                  0x10000800UL    /*-RMV- 4.63
(Rx BMU hang I) */
#define HWF_WA_DEV_427                  0x10000400UL    /*-RMV- 4.27
(Tx Done Rep) */
#define HWF_WA_DEV_42                   0x10000200UL    /*-RMV- 4.2
(pref unit burst) */
#define HWF_WA_DEV_46                   0x10000100UL    /*-RMV- 4.6
(CPU crash II) */
#define HWF_WA_DEV_43_418               0x10000080UL    /*-RMV- 4.3 &
4.18 (PCI unexp */

                         /*-RMV- compl&Stat BMU deadl) */
#define HWF_WA_DEV_420                  0x10000040UL    /*-RMV- 4.20
(Status BMU ov) */
#define HWF_WA_DEV_423                  0x10000020UL    /*-RMV- 4.23
(TCP Segm Hang) */
#define HWF_WA_DEV_424                  0x10000010UL    /*-RMV- 4.24
(MAC reg overwr) */
#define HWF_WA_DEV_425                  0x10000008UL    /*-RMV- 4.25
(Magic packet */

                         /*-RMV- with odd offset) */
#define HWF_WA_DEV_428                  0x10000004UL    /*-RMV- 4.28
(Poll-U &BigEndi)*/
#define HWF_WA_FIFO_FLUSH_YLA0  0x10000002UL    /*-RMV- dis Rx GMAC FIFO Flush*/

                         /*-RMV- for Yu-L Rev. A0 only */
#define HWF_WA_COMA_MODE                0x10000001UL    /*-RMV- Coma
Mode WA req */

---> common/skgeinit.c:SkGeSetUpSupFeatures()

        case CHIP_ID_YUKON_EC:
                        pAC->GIni.HwF.Features[HW_DEV_LIST] =
                                HWF_WA_DEV_42   | HWF_WA_DEV_46   |
HWF_WA_DEV_43_418 |
...
        case CHIP_ID_YUKON_FE:
                pAC->GIni.HwF.Features[HW_DEV_LIST] =
                        HWF_WA_DEV_427  | HWF_WA_DEV_4109 |
                        HWF_WA_DEV_4152 | HWF_WA_DEV_4167;
                break;
        case CHIP_ID_YUKON_XL:
... etc

It's worthwhile looking at 2.6/skge.c:CheckRxPath() and it's call-site
from the timer handler.

Thanks,
  Daniel
-- 
Daniel J Blueman
