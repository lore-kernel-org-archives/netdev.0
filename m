From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Fri, 28 Mar 2008 10:54:16 +0800
Message-ID: <989B956029373F45A0B8AF029708189001D19A3F@zch01exm26.fsl.freescale.net>
References: <> <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se> <989B956029373F45A0B8AF029708189001D19565@zch01exm26.fsl.freescale.net> <46CAC1281D7CB94A9AEFFB131F9569CA227627@tmnt04.transmode.se> <1206436671.7589.208.camel@gentoo-jocke.transmode.se> <989B956029373F45A0B8AF029708189001D198BC@zch01exm26.fsl.freescale.net> <1206621833.7589.286.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
To: <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:61618 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbYC1CyW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 22:54:22 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m2S2sIOO007889
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 19:54:19 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m2S2sGvA003403
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 21:54:17 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1206621833.7589.286.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Hi Jocke,
> > 
> > QUICC engine supports dynamic maximum frame length.  If you are not 
> > expecting to receive only tagged frames, I recommend to use this 
> > feature by setting dynamicMaxFrameLength and 
> dynamicMinFrameLength in 
> > ug_info instead of increasing the MaxLength for both tagged 
> and untagged frames.
> > See the following part from the reference manual.
> > 
> > The MFLR entry in the Global Parameter RAM defines the 
> length of the 
> > largest frame, excluding Q TAG but including FCS, that is 
> still valid. 
> > When REMODER[DXE]=1, a tagged frame that has length equals
> > MaxLength+4 considered valid, and a non tagged frame that has length
> > equals MaxLength is the longest
> > that is still considered valid. When REMODER[DXE]=0, any 
> frame longer 
> > than MaxLength consider erroneous frame.
> > For systems with only tagged frames, set REMODER[DXE]=0 and set 
> > MaxLength = Max LLC size+4.
> > 
> > - Leo
> 
> Interesting, that should also work although QinQ will not. I 
> will have a closer look but I still don't see how my orginal 
> patch would harm anything. One could add my patch on top but 
> with only 4 bytes extra.

Hi,

The increase of max packet length may cause a waste of QE internal
buffer for every packet.  Furthermore it affects the hardware statistics
of jumbo packets.

- Leo
