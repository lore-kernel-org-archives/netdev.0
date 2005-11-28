From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: VIA "Velocity" test report - VLAN reception not working
Date: Mon, 28 Nov 2005 23:48:55 +0100
Message-ID: <20051128224855.GA12814@electric-eye.fr.zoreil.com>
References: <20051126004057.11284.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux@horizon.com
Content-Disposition: inline
In-Reply-To: <20051126004057.11284.qmail@science.horizon.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

linux@horizon.com <linux@horizon.com> :
[...]
>         Link detected: no
> 
> Kernel 2.6.15-rc2, monolithic.  Only local patch is PPSkit-lite, which
> really shouldn't have any effect.  No idea about that "Link detected: no"
> line; I'm ssh- ed in over it right now.

The driver does not correctly handle netif_carrier_{on/off}.

[...]
> I saw a bunch of VLAN filtering stuff in the driver that I didn't
> really follow, so perhaps the problem's there.
> 
> (I confess I didn't choose super-carefully.  It was advertised as having
> Linux support and VLAN support and was reasonably cheap.  I didn't
> actually know the chipset until it arrived.  And yes, I *am* asking the
> vendor for support, but I expect that'll take a while.)

If you can put the card in a crashme/testme computer, feel free to try
the patches at:
http://www.zoreil.com/~romieu/linux/kernel/2.6.x/2.6.15-rc2/via-velocity/20051128

The patches apply on top of each other. I'd suggest doing a first round
of testing without VLAN to check that the usual flow did not experience
collateral damages.

If it works fine, enable VLAN when the last patch is applied and add
a single vlan with vconfig. If it does not crash, tcpdump + ping in
both direction w/wo VLAN may help fix the issues.

The patches are quite straightforward even if they are poorly described.

--
Ueimor
