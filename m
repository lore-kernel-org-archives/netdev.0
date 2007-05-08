From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 3Com PCI 3c905 causes annoying pci_set_power_state()
 messages
Date: Tue, 08 May 2007 01:40:24 -0400
Message-ID: <46400D48.80307@garzik.org>
References: <87ejlwmd8k.fsf@obelix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Greg KH <gregkh@suse.de>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54570 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968006AbXEHFk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:40:28 -0400
In-Reply-To: <87ejlwmd8k.fsf@obelix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bj=F8rn Mork wrote:
> I don't know if this is the correct place for 3c59x bugs.  Couldn't f=
ind
> a maintainer entry for it.  Please redirect as appropriate.
>=20
> pci_set_power_state() is a bit weird, causing a failure if a device
> doesn't support PM and the driver tries to
>=20
>  1) save it's power_state,=20
>  2) wake up and do something, and=20
>  3) then reset to the saved state.
>=20
> The 3c59x driver does this in it's ioctl function.
>=20
>=20
> pci_set_power_state() will never set current_state for such devices,
> causing them to remain in PCI_UNKNOWN (5) forever.  But if you try to
> set the state to PCI_UNKNOWN, bounding will kick in, limiting the sta=
te
> to PCI_D3hot (3).  Then pci_set_power_state() will complain because=20
> PCI_D3hot < current_state, printing useless messages like this:
>=20
>  pci_set_power_state(): 0000:00:09.0: state=3D3, current state=3D5
>  pci_set_power_state(): 0000:00:09.0: state=3D3, current state=3D5
>=20
> and returning -EINVAL.
>=20
> I believe this is wrong because pci_set_power_state() is supposed to
> return -EIO if device does not support PCI PM.

Yes, please fix PCI.

	Jeff



