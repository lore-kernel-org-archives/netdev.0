From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Fri, 7 Nov 2008 11:18:45 +0100
Message-ID: <1226053017.29620.431.camel@gentoo-jocke.transmode.se>
References: <1221524685-25968-1-git-send-email-afleming@freescale.com> <490DA8B5.2020303@garzik.org>
Reply-To: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andy Fleming" <afleming@freescale.com>, <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:6957 "EHLO
	mail.transmode.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbYKGKcb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 05:32:31 -0500
In-Reply-To: <490DA8B5.2020303@garzik.org>
content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-11-02 at 08:18 -0500, Jeff Garzik wrote:
> Andy Fleming wrote:
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > 
> > Creating a VLAN interface on top of ucc_geth adds 4 bytes
> > to the frame and the HW controller is not prepared to
> > TX a frame bigger than 1518 bytes which is 4 bytes too
> > small for a full VLAN frame. Also add 4 extra bytes for future
> > expansion.
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index 8f944e5..8fed4bb 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -113,10 +113,10 @@ static struct ucc_geth_info ugeth_primary_info = {
> >  	.maxGroupAddrInHash = 4,
> >  	.maxIndAddrInHash = 4,
> >  	.prel = 7,
> > -	.maxFrameLength = 1518,
> > +	.maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags and 4 extra bytes */
> >  	.minFrameLength = 64,
> > -	.maxD1Length = 1520,
> > -	.maxD2Length = 1520,
> > +	.maxD1Length = 1520+8,
> > +	.maxD2Length = 1520+8,
> >  	.vlantype = 0x8100,
> 
> Is this still needed?
> 
> I found this buried in my inbox.
> 
> If so, please resend with the "+8" converted into a named constant. 
> Hardcoding lengths like this without named constants (or comments, on 
> the other lines) tends to be an error-prone practice.

Yes, it is. I do recall the maintainer had some comments though.
Secondly, I think it should be changed to 8 extra bytes so
you can fit VLAN+pppoe=4+8 bytes. Possibly it could
be configuarble at complile time.

Andy, you think you can work out the details with the maintainer?
I am much to busy ATM.

 Jocke


