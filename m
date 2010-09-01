From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 1 Sep 2010 16:45:06 +0900
Message-ID: <000501cb49a9$9cd4bf00$66f8800a@maildom.okisemi.com>
References: <4C61EDE5.4030505@dsn.okisemi.com> <4C62981B.8050402@grandegger.com> <D5AB6E638E5A3E4B8F4406B113A5A19A28EA26CC@shsmsx501.ccr.corp.intel.com> <4C63B6C9.5050804@grandegger.com> <D5AB6E638E5A3E4B8F4406B113A5A19A28EA29DF@shsmsx501.ccr.corp.intel.com>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>, <arjan@linux.intel.com>,
	<gregkh@suse.de>, "Qi" <qi.wang@intel.com>,
	"Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>,
	"ML linux-kernel" <linux-kernel@vger.kernel.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	<socketcan-core@lists.berlios.de>,
	"Samuel Ortiz" <sameo@linux.intel.com>,
	"Barry Song" <21cnbao@gmail.com>,
	"Christian Pellegrin" <chripell@fsfe.org>,
	"Wolfram Sang" <w.sang@pengutronix.de>,
	"\"David S. Miller\"" <davem@davemloft.net>
To: "Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:49027 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751199Ab0IAHpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 03:45:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, for late response.
----- Original Message ----- 
From: "Wang, Qi" <qi.wang@intel.com>
To: "Masayuki Ohtak" <masa-korg@dsn.okisemi.com>
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>; <gregkh@suse.de>; <arjan@linux.intel.com>; "Wang, Yong
Y" <yong.y.wang@intel.com>; "Wolfgang Grandegger" <wg@grandegger.com>
Sent: Thursday, August 12, 2010 6:00 PM
Subject: RE: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35


> Hi Ohtak-san,
>
> Would you please answer the question from Wolfgang?
>
> Best Regards,
> Qi.
>
> > -----Original Message-----
> > From: Wolfgang Grandegger [mailto:wg@grandegger.com]
> > Sent: Thursday, August 12, 2010 4:55 PM
> > To: Wang, Qi
> > Cc: Masayuki Ohtak; Khor, Andrew Chih Howe; gregkh@suse.de;
> > arjan@linux.intel.com; Wang, Yong Y
> > Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> >
> > On 08/12/2010 03:29 AM, Wang, Qi wrote:
> > >> -----Original Message-----
> > >> From: Wolfgang Grandegger [mailto:wg@grandegger.com]
> > >> Sent: Wednesday, August 11, 2010 8:31 PM
> > >> To: Masayuki Ohtak
> > >> Cc: meego-dev@meego.com; socketcan-core@lists.berlios.de;
> > >> netdev@vger.kernel.org; Khor, Andrew Chih Howe; gregkh@suse.de;
> > >> arjan@linux.intel.com; Wang, Qi; Wang, Yong Y
> > >> Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> > >>
> > >> Hello,
> > >>
> > >> On 08/11/2010 02:25 AM, Masayuki Ohtak wrote:
> > >>> CAN driver of Topcliff PCH
> > >>>
> > >>> Topcliff PCH is the platform controller hub that is going to be used in
> > >>> Intel's upcoming general embedded platform. All IO peripherals in
> > >>> Topcliff PCH are actually devices sitting on AMBA bus.
> > >>
> > >> That's interesting. Where can I/we find more information about this CAN
> > >> controller, e.g. data-sheets. It seems to have a few interesting
> > >> features (message scheduler, etc.).
> > >
> > > I remove all the maillist, and show you something about this platform.
> >
> > Like Greg, I also prefer the public discussion.
> >
> > >
> > > Topcliff PCH is connected with Tunnelcreak (A kind of ATOM-based processor,
> > which integrate Memory controller, GFX and RC). And Topcliff is a kind of
> > stand-alone ARM-based processor, so it has AMBA-based peripherals, such as
> > CAN, GBE, I2C.
> > >
> > > Topcliff connected with Tunnelcreak via PCIe x1 lane. And PCH_PHUB works
> > as a gateway, which transform PCIe transaction to AMBA transaction, and vice
> > versa.
> > >
> > > The datasheet of those two chips aren't open now.
> >
> > Thanks for the info.
> >
> > >>> Topcliff PCH has CAN I/F. This driver enables CAN function.
> > >>>
> > >>> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> > >>
> > >> Thanks for your contribution. Unfortunately, there are many issues,
> > >> especially the driver is not yet conform with the Socket-CAN driver API:
> > >>
> > >> - My first observation was:
> > >>
> > >>   $ wc -l pch_can.c
> > >>   4076 pch_can.c
> > >>   $ grep dev_dbg pch_can.c | wc -l
> > >>   143
> > >>
> > >>   That's a lot of code, mainly debugging code, I think. This needs to
> > >>   be cleaned up sooner than later. dev_dbg's should be restricted to a
> > >>   few useful for the real users.

We will reduce dev_dbg code.

> > >>
> > >> - The values for the hw-specific bit-timing registers should be derived
> > >>   from the calculated values in "priv->can.bittiming":
> > >>
> > >>   http://lxr.linux.no/#linux+v2.6.35/include/linux/can/netlink.h#L17
> > >>

I show current pch_can code below.

+static int pch_set_bittiming(struct net_device *ndev)
+{
+ struct pch_can_priv *priv = netdev_priv(ndev);
+ struct pch_can_os *dev_can_os = priv->pch_can_os_p;
+ const struct can_bittiming *bt = &priv->can.bittiming;

Is the above TRUE, isn't it ?

> > >> - The driver should handle state changes and communicate them to the
> > >>   user space via error messages, if possible.
> > >>
What's "state chage" mean ?

> > >> - The driver should report errors to the user space via error messages.
> > >>
Is the above mean using alloc_can_err_skb and set error info and notify to kernel with netif_rx ?


> > >> - Bus errors seem not to be handled properly.I'm missing can_bus_off().
> > >>   Does the controller recover from bus-off automatically?
No.
CAN driver recovers from Bus-off state.

> > >>
> > >> - I see that the driver uses many TX and RX objects. How do you avoid
> > >>   out-of-order transmission and reception?
> > > What do you mean out-of-order RX and TX?
> > > Atom processor only supports in-order execution, and PCIe-based peripherals
> > can solve it with consumer-producer model. Actually IC designer will take care
> > of out-of-order PCIe CPLD transaction.
> >
> > I mean out-of-order transmission to or from the CAN bus. This is handled
> > by the CAN controller hardware. It has nothing to to with the processor.
Cannot avoid occurring rx or tx our-of-order.

Thanks, Ohtake(OKISemi)



