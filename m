From: Xu Bingcan <bingcanxu@gmail.com>
Subject: [help] macb driver modification for direct mac-to-mac connection
 without phy -- Thanks
Date: Thu, 7 Jul 2011 15:27:41 +0800
Message-ID: <CAKGTVyuA22YLfi44XQ+Jx4gNRLwPCaz2GeOTkBKm3hjCX8YQ1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bingcan Xu <bingcanxu@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60502 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab1GGH1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 03:27:42 -0400
Received: by iwn6 with SMTP id 6so607684iwn.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 00:27:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Guys

I am appreciate that anyone can give me some hint...

My Case Description:

I'm working with an Atmel ARM9 board (macb driver), that doesn't have
a PHY. The MAC is connected to a switch via MII.  That MII link is
hard-wired to be 100M full-duplex.

I have a real, working MDIO bus.What I don't have is a PHY.I don't
want an emulated MDIO bus such as phy_fixed.

I found a mail thread about "Question about PHY-less board and
"fixed_phy"" in the linux netdev but no solution provided.
http://www.spinics.net/lists/netdev/msg143651.html


/* Not really PHY in our situation. Use a fake phy like fixed_phy
except a really MDIO to switch
* The switch IP175C uses the PHY addr 0-6 16 18 29 30 31. For more
detail information refer to IP175Cx-DS-R17-20081121.pdf.
* For simplity, the fake PHY use addr = FAKE_PHY_ADDR(19)
*/
I try to modify mdiobus_scan() so that it just allocate space and does
not register device for PHYADDR 19
at macb_mii_probe().. I replace the first found phy to my hardcode one
FAKE_PHY_ADDR(19)...

then I modify the macb_mdio_read() macb_mdio_write() to use my stub
function when addr == FAKE_PHY_ADDR.

But the traffic are lost when startup.

Thanks

Brs,

- Xu Bingcan
