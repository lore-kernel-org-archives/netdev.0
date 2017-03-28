From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for SoC devices
Date: Tue, 28 Mar 2017 18:21:32 +0200
Message-ID: <8622591.q4sXytZqXW@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr> <2357006.NGKQYCh4BG@debian64> <20170328151837.GC3152@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        m@kresin.me
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34304 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbdC1QVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 12:21:46 -0400
In-Reply-To: <20170328151837.GC3152@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, March 28, 2017 5:18:37 PM CEST Andrew Lunn wrote:
> > But LEDE/OpenWRT rely on the firmware loading API more than ever and 
> > currently there is not a replacement for it.
> 
> ....
> 
> 
> > I looked into 10-ath9k-eeprom [0] of LEDE's AR71XX target and I noticed
> > that quite a few devices patch the MACs of the wifi.
> > If you look at the code for the Airtight C-55 and C-60, Meraki MR18,
> > Meraki Z1, you'll notice that each one has to add a fixed value (+1,
> > +2, ...) to the extraced MAC-Address. So how would you replicate this,
> > with "nvmem-cell-names = address" without some sort of 
> > nvmem-provider-processor?
> 
> ...
>  
> > https://github.com/lede-project/source/blob/master/target/linux/ar71xx/files/arch/mips/ath79/dev-eth.c#L1204
> > 
> > and grep lists the following devices:
> > mach-dgl-5500-a1.c, mach-dhp-1565-a1.c, mach-dir-505-a1.c, mach-dir-615-c1.c
> > mach-dir-615-i1.c, mach-dir-825-b1.c, mach-dir-825-c1.c, mach-tew-673gru.c
> > mach-tew-712br.c, mach-tew-732br.c, mach-tew-823dru.c
> 
> I would say a big part of the problem is that all of these use cases
> are outside of mainline. Why should mainline support something which
> is not actually used in mainline.
> 
> So i would suggest your first step is to bring some of these devices
> into mainline. Once in mainline, it becomes a mainline issue, and
> people will help get it solved.
>
Oh, in that case you should probably go "all out" and ask on the 
LKML to remove all of the ath9k and ath10k ahb work. From what I
know all the "users" are running some sort of OpenWRT/LEDE or a 
derivative. This is because Atheros/QCA provided a SDK based on
OpenWRT.

Alban has been trying to convert the platform to device-tree
and add them to the mainline for a while now:
 
https://patchwork.kernel.org/patch/6514551/

So, you are questioning this work as well.

Thanks,
Christian
