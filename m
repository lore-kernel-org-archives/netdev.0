From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: Micrel KSZ8031 - phy link missing
Date: Fri, 10 Oct 2014 11:32:56 +0000
Message-ID: <915054555B5659448ACF8A70E114824D0163C7A7F9@Exchange2010.kamstrup.dk>
References: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk>
 <5437A7A2.3020700@gmail.com>
 <915054555B5659448ACF8A70E114824D0163C7A77B@Exchange2010.kamstrup.dk>
 <5437BACA.1000201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Angelo Dureghello <angelo70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:37532 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502AbaJJLc6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:32:58 -0400
In-Reply-To: <5437BACA.1000201@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey again,

> thanks for the prompt help,
> well i am setting up that clock pin in my board.c, as
> ..
>
> Probably it's me that i am doing something illegal, i explain:
>
> I am moving from a 3.5.1 to a 3.17 kernel, but have a special board.c startup file i cannot convert into DT easily.
> So i am booting using old way (board.c).
> Now, new kernels have "pinctrl" that probably jump over my gpio setting later in the boot, is it possible ?

Looks like you just enable clock output from DA850. You also need to setup PHY to accept RMII clock from MAC.
This can be done with something like this...

static int angelo_board_phy_fixup(struct phy_device *phy)
{
	phy->dev_flags |= MICREL_PHY_50MHZ_CLK;
	return 0;
}

static void __init angelo_board_init(void)
{
	phy_register_fixup_for_uid(PHY_ID_KSZ8031, MICREL_PHY_ID_MASK,
					   angelo_board_phy_fixup);

	// Old board init
}



Venlig hilsen / Best regards

Kamstrup A/S <http://www.kamstrup.dk> 
Bruno Thomsen
Development engineer
Technology

Kamstrup A/S
Industrivej 28
DK-8660 Skanderborg
Tel:	 +45 89 93 10 00	 
Fax:	 +45 89 93 10 01	 
Dir:	 +45 89 93 13 94	 
E-mail:	 bth@kamstrup.dk	 
Web:	 www.kamstrup.dk	 
