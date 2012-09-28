From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Lab: v.1.8 + Linux 2.6.37.6+up #1 + ESXi 5.0 - VM - Slow
 Network Performance/Failures
Date: Fri, 28 Sep 2012 09:21:25 -0700
Message-ID: <20120928092125.1e92a663@nehalam.linuxnetplumber.net>
References: <CAJXRGaj8t5Qx_jewDfS-zYOSQL4iNx_vLM46t72=uYF1x7x=Pw@mail.gmail.com>
	<CAJXRGag+VEMYUfhEaVwpVCUpjwC6Rhd0NeOrA15VAEz-5OwAMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mike Harris <mharris@onxis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39553 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757572Ab2I1QWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 12:22:00 -0400
In-Reply-To: <CAJXRGag+VEMYUfhEaVwpVCUpjwC6Rhd0NeOrA15VAEz-5OwAMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Sep 2012 04:56:35 +0200
Mike Harris <mharris@onxis.com> wrote:

> Hi,
>=20
> I hope everyone is well!
>=20
> Some network throughput/performance oddness with a linux based virtua=
l firewall=85
>=20
> Lab scenario;
>=20
> [Windows VM #1] --- VLAN X-----(*)Linux Firewall VM ----- VLAN Y
> ---[Windows VM #2]
>=20
> A tcpdump is kicked off with the following options on the firewall
> this a 100MB file is copied between VM #1 to VM #2 (SMB).
>=20
> tcpdump -i eth0.x -n -s0 -w file-transfer-1.pcap -c100
>=20
> Notes:
>=20
> + Physical blade run ESXi 5.0.
> + Windows VMs run on the same vSwitch and physical blade.
> + VLAN X and Y support up to 1500 bytes MTU.
> + Virtual firewall is configured with the 4095 (any) VLAN (receives
> and transmits tagged frames).
> + Virtual firewall is runs Linux 2.6.37.6+up #1
> + Virtual and physical backbones do support up to 9k frames.
>=20
> Observations;
>=20
> 1. The file copy fails=85
> 2. The pcap reveals a 12,443 byte uber jumbo frame is present shortly
> after the file transfer starts.
>=20
> Repeated the same scenario using a test vyatta 6.4 VM and the file
> copy completes normally=85 no jumbo frames or any other oddness.
> Virtual and physical networking can not originate such a frame
> normally.
>=20
> Given this, I suspect there's a general framing failure of the networ=
k
> driver on the virtual linux firewall, which lead me to the dmesg
> command and this mailing list :)
>=20
> Has anyone else seen this behavior before on a linux VM before?
>=20
> Thoughts?
>=20
> Helpful suggestions :)

Vyatta ran into a problem because the Vmware driver was incorrectly kee=
ping LRO
enabled even when forwarding. Given the age of the kernel that could
be your problem.

The short term workaround used to just force LRO off (change to vmxnet3=
).
Thankfully, someone later found where the driver was mistakenly renabli=
ng LRO
and fixed the real bug.
