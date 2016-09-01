From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net v2] bnx2x: don't reset chip on cleanup if PCI function
 is offline
Date: Thu, 1 Sep 2016 07:52:00 +0000
Message-ID: <DM5PR11MB172310F98945446BE3EA387697E20@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1472656317-2323-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0135.outbound.protection.outlook.com ([104.47.42.135]:63625
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754506AbcIAHwI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 03:52:08 -0400
In-Reply-To: <1472656317-2323-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When PCI error is detected, in some architectures (like PowerPC) a slot r=
eset is
> performed - the driver's error handlers are in charge of "disable"
> device before the reset, and re-enable it after a successful slot reset.
>=20
> There are two cases though that another path is taken on the code: if the=
 slot
> reset is not successful or if too many errors already happened in the spe=
cific
> adapter (meaning that possibly the device is experiencing a HW failure th=
at slot
> reset is not able to solve), the core PCI error mechanism (called EEH in =
PowerPC)
> will remove the adapter from the system, since it will consider this as a
> permanent failure on device. In this case, a path is taken that leads to
> bnx2x_chip_cleanup() calling bnx2x_reset_hw(), which then tries to perfor=
m a
> HW reset on chip. This reset won't succeed since the HW is in a fault sta=
te,
> which can be seen by multiple messages on kernel log like below:
>=20
> 	bnx2x: [bnx2x_issue_dmae_with_comp:552(eth1)]DMAE timeout!
> 	bnx2x: [bnx2x_write_dmae:600(eth1)]DMAE returned failure -1
>=20
> After some time, the PCI error mechanism gives up on waiting the driver's
> correct removal procedure and forcibly remove the adapter from the system=
.
> We can see soft lockup while core PCI error mechanism is waiting for driv=
er to
> accomplish the right removal process.
>=20
> This patch adds a verification to avoid a chip reset whenever the functio=
n is in
> PCI error state - since this case is only reached when we have a device b=
eing
> removed because of a permanent failure, the HW chip reset is not expected=
 to
> work fine neither is necessary.
>=20
> Also, as a minor improvement in error path, we avoid the MCP information
> dump in case of non-recoverable PCI error (when adapter is about to be
> removed), since it will certainly fail.
>=20
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Thanks.

Acked-By: Yuval Mintz <Yuval.Mintz@qlogic.com>
