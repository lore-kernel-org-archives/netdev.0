From: Michael Chan <mchan@broadcom.com>
Subject: Re: Linux kernel commit breaks IPMI on iface downing
Date: Thu, 13 Aug 2015 18:30:34 -0700
Message-ID: <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=cp1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?S=E9bastien?= Bocahu <sbu@reportlinker.com>,
	<harish.patil@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:7300 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbHNBaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 21:30:35 -0400
In-Reply-To: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+netdev and Harish who is the current maintainer of bnx2 at qlogic.

The patch in question effectively just removes the
bnx2_set_power_state() call during "ip link set down".  If there is
IPMI, the firmware should know the link needs to stay up when the drive=
r
resets the device during bnx2_close().  This should be a very common
scenario.  Please provide the firmware versions to Harish with ethtool
-i.  Perhaps upgrading the firmware can resolve this issue.

On Thu, 2015-08-13 at 15:47 +0200, S=E9bastien Bocahu wrote:=20
> Hi,
>=20
> Being unable to install Debian Jessie via IPMI on mainstream Dell R41=
0
> servers that used to be well supported by Debian Wheezy, I tracked th=
e
> problem down to a specific commit in the Linux kernel, specifically i=
n
> the bnx2 driver.
> The issue is that "ip link set eth0 down" takes the Ethernet part of
> the BMC down (shared NIC for BMC+eth0), cutting off the IPMI session.
> The BMC gets back only after power cycling.
>=20
> Hardware: Dell R410 w/ a Broadcom 5716 NIC:
> Ethernet controller: Broadcom Corporation NetXtreme II BCM5716 Gigabi=
t
> Ethernet (rev 20)  )
> Part number: BCM95716C1
> Vendor specific: 6.4.5 (Firmware has been updated to the latest
> version available by Dell's support website)
>=20
> I built many kernels to track which change caused the issue and it
> seems that's :
> 25bfb1dd4ba3b2d9a49ce9d9b0cd7be1840e15ed (bnx2: Add pci shutdown hand=
ler.)
>=20
> Before, 'ip link set eth0 down' would just cause 2/3s of packet loss
> but IPMI would still be working afterwards.
>=20
> I'm available for more informations and/or testing if needed.
>=20
> Thanks !
>=20
>=20
>=20
