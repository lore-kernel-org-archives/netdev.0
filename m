From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Thu, 27 Mar 2008 13:43:53 +0100
Message-ID: <1206621833.7589.286.camel@gentoo-jocke.transmode.se>
References: <>
	 <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001D19565@zch01exm26.fsl.freescale.net>
	 <46CAC1281D7CB94A9AEFFB131F9569CA227627@tmnt04.transmode.se>
	 <1206436671.7589.208.camel@gentoo-jocke.transmode.se>
	 <989B956029373F45A0B8AF029708189001D198BC@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:21456 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755497AbYC0Mn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:43:56 -0400
In-Reply-To: <989B956029373F45A0B8AF029708189001D198BC@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-03-26 at 20:43 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se] 
> > Sent: Tuesday, March 25, 2008 5:18 PM
> > To: Li Yang
> > Cc: Netdev; Linuxppc-Embedded@Ozlabs.Org
> > Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
> > 
> > 
> > On Sat, 2008-03-22 at 12:51 +0100, Joakim Tjernlund wrote:
> > > >> -----Original Message-----
> > > >> From: netdev-owner@vger.kernel.org
> > > >> [mailto:netdev-owner@vger.kernel.org] On Behalf Of 
> > Joakim Tjernlund
> > > > Sent: Tuesday, March 18, 2008 11:11 PM
> > > >> To: Netdev; Li Yang
> > > >> Cc: Joakim Tjernlund
> > > >>Subject: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
> > > >>
> > > >> Creating a VLAN interface on top of ucc_geth adds 4 bytes to the 
> > > >> frame and the HW controller is not prepared to TX a frame bigger 
> > > >> than 1518 bytes which is 4 bytes too small for a full 
> > VLAN frame. 
> > > >> Also add 4 extra bytes for future expansion.
> > > > 
> > > > IMO, VLAN and Jumbo packet support is not general case of 
> > Ethernet.
> > > > Could you make this change optional?  Thanks.
> > > > 
> > > > - Leo
> > > 
> > > hmm, I do not agree. VLAN is common today.
> > > 
> > > If you were to enable HW support for VLAN then the ethernet 
> > controller 
> > > would inject an extra 4 bytes into the frame.
> > > This change does not change the visible MTU for the user. 
> > As is now, 
> > > soft VLAN is silently broken. Do you really want the user 
> > to find and 
> > > turn on a controller specific feature to use VLAN?
> > > 
> > > What does netdev people think? 
> > > 
> > >  Jocke
> > 
> > hmm, I misread the HW specs. The change has nothing to do 
> > with TX, it is the MAX RX frame size that was too small for 
> > VLAN and that is what the patch addresses. I see that tg3.c 
> > adds 4 bytes to MAX RX pkgs:
> >  	/* MTU + ethernet header + FCS + optional VLAN tag */
> > 	tw32(MAC_RX_MTU_SIZE, tp->dev->mtu + ETH_HLEN + 8); So 
> > I don't think this change should be hidden behind a new 
> > CONFIG option. Updated patch below with changed description.
> 
> Hi Jocke,
> 
> QUICC engine supports dynamic maximum frame length.  If you are not
> expecting to receive only tagged frames, I recommend to use this feature
> by setting dynamicMaxFrameLength and dynamicMinFrameLength in ug_info
> instead of increasing the MaxLength for both tagged and untagged frames.
> See the following part from the reference manual.
> 
> The MFLR entry in the Global Parameter RAM defines the length of the
> largest frame, excluding Q TAG
> but including FCS, that is still valid. When REMODER[DXE]=1, a tagged
> frame that has length equals
> MaxLength+4 considered valid, and a non tagged frame that has length
> equals MaxLength is the longest
> that is still considered valid. When REMODER[DXE]=0, any frame longer
> than MaxLength consider
> erroneous frame.
> For systems with only tagged frames, set REMODER[DXE]=0 and set
> MaxLength = Max LLC size+4.
> 
> - Leo

Interesting, that should also work although QinQ will not. I will have
a closer look but I still don't see how my orginal patch would
harm anything. One could add my patch on top but with only 4 bytes
extra.

 Jocke

