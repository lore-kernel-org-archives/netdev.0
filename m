From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Thu, 7 Feb 2013 16:05:02 -0500
Message-ID: <511416FE.9000906@windriver.com>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de> <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org> <1353800616.2590.4562.camel@edumazet-glaptop> <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de> <1353950255.7553.6.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de> <1354019816.7553.1585.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de> <1354023162.7553.1708.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tino Keitel <tino.keitel@tikei.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61568 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030217Ab3BGVEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 16:04:46 -0500
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-02-05 08:00 AM, Keitel, Tino (ALC NetworX GmbH) wrote:
> On Di, 2012-11-27 at 05:32 -0800, Eric Dumazet wrote:
>> On Tue, 2012-11-27 at 13:42 +0100, Keitel, Tino (ALC NetworX GmbH)
>> wrote:
>>> On Di, 2012-11-27 at 04:36 -0800, Eric Dumazet wrote:
>>>>
>>>> Can you reproduce the problem using a single cpu ?
>>>
>>> Yes, it is a single-CPU system.
>>
>> Can you reproduce the problem without PTP running, or disabled in the
>> driver ?
>>
>> (comment the "priv->hwts_tx_en = 1;" line)
> 
> I can't reproduce it with that line commented. However, so far I was
> only able to reproduce it when starting the ptp2 client, so maybe this
> is connected.

I found an mpc8315erdb, and built the default yocto build (v3.4.20,
which should have the issue based on your earlier reports.)

> 
>> By the way are any errata flagged in gfar_detect_errata() ?
> 
> This is from dmesg:
> 
> fsl-gianfar e0024000.ethernet: enabled errata workarounds, flags: 0x7
> 
> 0x7 would be GFAR_ERRATA_74, GFAR_ERRATA_76 and GFAR_ERRATA_A002
> according to drivers/net/ethernet/freescale/gianfar.h.

The MPC8315ECE.pdf lists the 8315 as having 76 and A002 (amongst
a lot of others.)  However the driver only does errata checks
for the 8313 it seems.  I also then manually forced the driver
to enable the errata and confirmed I saw 0x7 flag in dmesg.

Finally I added the meta-networking layer to the yocto build to
get a ptpd2 (2.2.0-r1)

On another board, I ran a server as:
    ptpd2 -G -C -c -b eth0

On the 8315, I ran the client as:
    ptpd2 -g -C -c -b eth0

In neither case (errata off, and errata manually enabled) I did not
manage to get the tx timeout that you got.

There must be something more specific to your environment, your
ptpd client (and args) and perhaps the board itself.

Paul.
--

> 
> Regards,
> Tino
> 
