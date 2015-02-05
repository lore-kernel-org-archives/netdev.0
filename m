From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Ethernet: how to disable gigabit support
Date: Thu, 05 Feb 2015 14:44:55 -0800
Message-ID: <54D3F267.3000908@gmail.com>
References: <20150205202527.GA7917@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150205202527.GA7917@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/02/15 12:25, Pavel Machek wrote:
> Hi!
> 
> This happened on more than one project: there's gigabit-capable chip,
> but the connector is not designed for gigabit speed.
> 
> I'd like to have speed autonegotiation, but not offer gigabit (as it
> will not work).
> 
> Is there way to do that without hacking the kernel? Should mii-tool do
> that?

Since you use the PHY library, you should be able to do something like
this in your PHY driver prior to starting the PHY state machine:

phydev->supported &= PHY_BASIC_FEATURES (effectively masking Gigabit
capability)

See drivers/net/ethernet/broadcom/genet/bcmmii.c for instance where this
is done based on the type of interface (RevMII, MII) we are connected to.

> 
> Thanks,
> 								Pavel
> 
> root@ib8315:~# mii-tool.net-tools  -A 100baseTx,10baseT eth1
> restarting autonegotiation...
> root@ib8315:~# [32432.443883] libphy: mdio@e0024520:01 - Link is Down
> 
> root@ib8315:~# [32435.447863] libphy: mdio@e0024520:01 - Link is Up - 1000/Full
> 
> root@ib8315:~# mii-tool.net-tools -v eth1
> eth1: negotiated 1000baseT-FD flow-control, link ok
> product info: vendor 00:01:c1, model 3 rev 1
> basic mode:   autonegotiation enabled
>  basic status: autonegotiation complete, link ok
>  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD
>  advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD
>  link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD flow-control
>  root@ib8315:~# mii-tool.net-tools -V
>  $Id: mii-tool.c,v 1.9 2006/09/27 20:59:18 ecki Exp $
>  (Author: David Hinds based on Donald Becker's mii-diag)
>  net-tools 1.60
>  root@ib8315:~#
> 	    
> 


-- 
Florian
