From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: RTL8136
Date: Thu, 31 Aug 2006 23:32:37 +0100
Message-ID: <4E5F3C4A40%linux@youmustbejoking.demon.co.uk>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com>
 <4E5C6C7764%linux@youmustbejoking.demon.co.uk> <4E5CF8AF74%linux@youmustbejoking.demon.co.uk> <20060827214135.GA21464@electric-eye.fr.zoreil.com>
 <4E5D2F7732%linux@youmustbejoking.demon.co.uk> <20060831210506.GA9463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-30.mail.demon.net ([194.217.242.88]:11015 "EHLO
	anchor-post-30.mail.demon.net") by vger.kernel.org with ESMTP
	id S964806AbWHaW7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:59:05 -0400
To: romieu@fr.zoreil.com
In-Reply-To: <20060831210506.GA9463@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I demand that Francois Romieu may or may not have written...

> Darren Salt <linux@youmustbejoking.demon.co.uk> :
> [...]
>> The former. Without that, the connection is persistently re-negotiated
>> (though, according to the switch's LEDs, it's fine before the module is
>> loaded).

> The state of the LEDs at startup is not necessarily significant (it can
> come from the eeprom).

I'm inclined to believe the switch...

> I have regenerated a serie which includes a fix with the correct RTL_CFG_2
> at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5/r8169 (the git
> branch has been updated as well).

Got it.

> Could you use it with mii-tool to collect the state of the mii registers in
> the broken state and in the working state ?

Broken:

eth0: no link
  registers for MII PHY 32: 
    1000 7849 0000 8201 0de1 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 05c0 0000 000f 0000 0000 0000 0000
    0000 0080 0000 0000 0000 0000 0000 0000
  product info: vendor 00:00:20, model 32 rev 1
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

eth0: no link
  registers for MII PHY 32: 
    3100 7849 0000 8201 0de1 45e0 0001 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    000c 05c0 007a 000f 0000 0000 0000 0000
    0000 00f8 0000 0000 0000 0000 0000 0000
  product info: vendor 00:00:20, model 32 rev 1
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control


Working (after "mii-tool -A 10baseT eth0"):

eth0: negotiated 10baseT-FD, link ok
  registers for MII PHY 32: 
    1100 786d 0000 8201 0061 45e1 0001 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    000c 05c0 0000 000f 0000 0000 0000 0000
    0000 0086 0000 0000 0000 0000 0000 0000
  product info: vendor 00:00:20, model 32 rev 1
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  10baseT-FD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control


Working (after "mii-tool -R eth0", needed to allow 100baseTx):

eth0: negotiated 100baseTx-FD, link ok
  registers for MII PHY 32: 
    3100 786d 0000 8201 01e1 45e1 0001 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    000c 05c0 0000 0002 0000 0000 0000 0000
    0000 00f9 0000 0000 0000 0000 0000 0000
  product info: vendor 00:00:20, model 32 rev 1
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
|   Say NO to UK ID cards. http://www.no2id.net/

Windows 2000. Known to some as Windows 1900.
