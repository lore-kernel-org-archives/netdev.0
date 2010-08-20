From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 20 Aug 2010 15:01:55 +0900
Message-ID: <000f01cb402d$34b675b0$66f8800a@maildom.okisemi.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>	<4C63B8F8.6090106@grandegger.com> <D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1@shsmsx501.ccr.corp.intel.com> <4C65255F.4010709@grandegger.com>
Cc: "Wang, Qi" <qi.wang@intel.com>, <arjan@linux.intel.com>,
	<meego-dev@meego.com>, "Wang, Yong Y" <yong.y.wang@intel.com>,
	<gregkh@suse.de>, <netdev@vger.kernel.org>,
	<socketcan-core@lists.berlios.de>,
	"Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>,
	"Morinaga" <morinaga526@dsn.okisemi.com>
To: "Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:20061 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751227Ab0HTGCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 02:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

> >>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> >>> Just take a look at kfifo.h. This structure has been changed. I remembered
> >> there was a spin_lock from kfifo previously. Currently it's been removed, good.
> >>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to
> >> use this structure and APIs?
> >>
> >> As I see it, the code related to that fifo is not used (== dead code)?
> > I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.

We are about to study kfifo infra structure.
I have a question.

It seems all CAN drivers accepted by upstream don't use kfifo infrastructure, right ?
(I couldn't see message with "grep kfifo * in drivers/net/can")

If yes, why should we use the kfifo ?
If no, please show me the kfifo reference driver

Thanks, Ohtake(OKISEMI)
----- Original Message ----- 
From: "Wolfgang Grandegger" <wg@grandegger.com>
To: "Wang, Qi" <qi.wang@intel.com>
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>; <socketcan-core@lists.berlios.de>;
<netdev@vger.kernel.org>; <gregkh@suse.de>; "Wang, Yong Y" <yong.y.wang@intel.com>; "Masayuki Ohtak"
<masa-korg@dsn.okisemi.com>; <meego-dev@meego.com>; <arjan@linux.intel.com>
Sent: Friday, August 13, 2010 7:58 PM
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35


> On 08/13/2010 02:23 AM, Wang, Qi wrote:
> >> -----Original Message-----
> >> From: Wolfgang Grandegger [mailto:wg@grandegger.com]
> >> Sent: Thursday, August 12, 2010 5:04 PM
> >> To: Wang, Qi
> >> Cc: Daniel Baluta; Masayuki Ohtak; meego-dev@meego.com;
> >> socketcan-core@lists.berlios.de; netdev@vger.kernel.org; Khor, Andrew Chih
> >> Howe; gregkh@suse.de; arjan@linux.intel.com; Wang, Yong Y
> >> Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> >>
> >> On 08/12/2010 03:42 AM, Wang, Qi wrote:
> >>>> -----Original Message-----
> >>>> From: Daniel Baluta [mailto:daniel.baluta@gmail.com]
> >>>> Sent: Wednesday, August 11, 2010 6:37 PM
> >>>> To: Masayuki Ohtak
> >>>> Cc: meego-dev@meego.com; Wolfgang Grandegger;
> >>>> socketcan-core@lists.berlios.de; netdev@vger.kernel.org; Khor, Andrew
> >> Chih
> >>>> Howe; gregkh@suse.de; arjan@linux.intel.com; Wang, Qi; Wang, Yong Y
> >>>> Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> >>>>
> >>>> Hi,
> >>>>
> >>>> 2010/8/11 Masayuki Ohtak <masa-korg@dsn.okisemi.com>:
> >>>>> CAN driver of Topcliff PCH
> >>>>>
> >>>>> Topcliff PCH is the platform controller hub that is going to be used in
> >>>>> Intel's upcoming general embedded platform. All IO peripherals in
> >>>>> Topcliff PCH are actually devices sitting on AMBA bus.
> >>>>> Topcliff PCH has CAN I/F. This driver enables CAN function.
> >>>>>
> >>>>> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> >>>>
> >>>> I have a few questions:
> >>>>
> >>>> 1. Is your code based on Intel's CAN EP80579 ([1]) ?
> >>> No.
> >>
> >> For curiosity, is the controller similar to the OKI MSM9225 or ML9620?
> > The Topcliff IOH is developed by OKI actually.
> >
> >>
> >>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> >>> Just take a look at kfifo.h. This structure has been changed. I remembered
> >> there was a spin_lock from kfifo previously. Currently it's been removed, good.
> >>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to
> >> use this structure and APIs?
> >>
> >> As I see it, the code related to that fifo is not used (== dead code)?
> > I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.
> >>
> >>> Daniel,
> >>>
> >>> We're anxious to integrate those codes now. Perhaps it'll take us quite a long
> >> time to use kfifo. How about implementing it with the next version?
> >>
> >> See above. What do you mean with the next version. The driver posted by
> >> Masayuki is far away from being accepted as it does not yet comply with
> >> the Socket-CAN driver API, to say the least.
> > I've few experience on CAN driver and it's also the first time for OKI-san to write Can driver. Would you please
give us a reference and we'll follow it up. We only read 'can.txt' from kernel document. Thank you for your help in
advance.
>
> You are welcome. I think I/we already gave useful hints on what is
> missing and what examples to follow.
>
> Wolfgang.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


