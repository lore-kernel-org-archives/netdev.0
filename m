From: Tuomas Jormola <tj@solitudo.net>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Thu, 24 Apr 2008 17:25:59 +0300
Message-ID: <20080424142559.GA25023@solitudo.net>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com> <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net> <20080308175721.GA3582@ami.dom.local> <2DAAA71E-5F03-41CA-B7E0-5BE4073D14F5@solitudo.net> <20080309173122.GA3339@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5/uDoXvLw7AC5HRs"
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solitudo.net ([213.157.84.60]:43433 "EHLO
	mail.solitudo.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbYDXOgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 10:36:05 -0400
Content-Disposition: inline
In-Reply-To: <20080309173122.GA3339@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5/uDoXvLw7AC5HRs
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Content-Disposition: inline


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi again,

On Sun, Mar 09, 2008 at 06:31:22PM +0100, Jarek Poplawski wrote:
> On Sun, Mar 09, 2008 at 06:58:47PM +0200, Tuomas Jormola wrote:
> ...
> > there be new oopses, I will replace the old card with a newer Intel=20
> > gigabit card that I have laying around, and put it in a different PCI=
=20
> > slot.
>=20
> The link I gave you described similar problem just with e1000.
> The next message after this thread looks alike (e1000 driver).
> So, you shouldn't hurry with this change. Just set this affinity
> for both cards and check if it's respected.
I've now run my system about a month with the following configuration. I
replaced the very old e100 card with a newer e1000 PCI card and set
affinity so that interrupts for the IRQs of both e1000e and e1000 cards
are handled by a single CPU, and this is working very well.

(17:15:13)(tj@shakti)(~)$ grep eth /proc/interrupts=20
 18:   88113407       3780   IO-APIC-fasteoi   uhci_hcd:usb1, uhci_hcd:usb6=
, eth0
217:    9710797       4297   PCI-MSI-edge      eth1

(This is after about a 8 days of uptime, the affinity was set
automatically in a local init script)

And with this, I've gotten rid of the OOPSes I had earlier. But is this
really a feasible long term solution to the problem? I.e. if you're
getting networking related OOPSes with SMP kernel on a box with two or
more CPUs, the first thing you should do is to switch off the interrupt
handling load balacing between the CPUs by issuing some obscure statment
on the command line? I don't think that's very friendly advice for so
called regular users... There's no way to work around it on the kernel
side?

Also after installing the e1000 card, I've gotten a few of these dumps
(see attachments) from the e1000 driver (during about a month, a dozen
incidents, sometimes there might be 3 incidents a day, sometimes it
takes a week when everything's normal.

Thanks,

--=20
Tuomas Jormola <tj@solitudo.net>

--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="e1000-hang1.txt"

Apr 22 10:08:48 shakti kernel: [435270.771373] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 10:08:48 shakti kernel: [435270.771375]   Tx Queue             <0>
Apr 22 10:08:48 shakti kernel: [435270.771376]   TDH                  <8b>
Apr 22 10:08:48 shakti kernel: [435270.771376]   TDT                  <78>
Apr 22 10:08:48 shakti kernel: [435270.771377]   next_to_use          <78>
Apr 22 10:08:48 shakti kernel: [435270.771378]   next_to_clean        <8b>
Apr 22 10:08:48 shakti kernel: [435270.771379] buffer_info[next_to_clean]
Apr 22 10:08:48 shakti kernel: [435270.771379]   time_stamp           <29843da>
Apr 22 10:08:48 shakti kernel: [435270.771380]   next_to_watch        <8d>
Apr 22 10:08:48 shakti kernel: [435270.771381]   jiffies              <29844bc>
Apr 22 10:08:48 shakti kernel: [435270.771382]   next_to_watch.status <0>
Apr 22 10:08:50 shakti kernel: [435272.769478] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 10:08:50 shakti kernel: [435272.769480]   Tx Queue             <0>
Apr 22 10:08:50 shakti kernel: [435272.769481]   TDH                  <8b>
Apr 22 10:08:50 shakti kernel: [435272.769482]   TDT                  <78>
Apr 22 10:08:50 shakti kernel: [435272.769483]   next_to_use          <78>
Apr 22 10:08:50 shakti kernel: [435272.769484]   next_to_clean        <8b>
Apr 22 10:08:50 shakti kernel: [435272.769484] buffer_info[next_to_clean]
Apr 22 10:08:50 shakti kernel: [435272.769485]   time_stamp           <29843da>
Apr 22 10:08:50 shakti kernel: [435272.769486]   next_to_watch        <8d>
Apr 22 10:08:50 shakti kernel: [435272.769486]   jiffies              <2984584>
Apr 22 10:08:50 shakti kernel: [435272.769487]   next_to_watch.status <0>
Apr 22 10:08:52 shakti kernel: [435274.767578] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 10:08:52 shakti kernel: [435274.767580]   Tx Queue             <0>
Apr 22 10:08:52 shakti kernel: [435274.767581]   TDH                  <8b>
Apr 22 10:08:52 shakti kernel: [435274.767582]   TDT                  <78>
Apr 22 10:08:52 shakti kernel: [435274.767582]   next_to_use          <78>
Apr 22 10:08:52 shakti kernel: [435274.767583]   next_to_clean        <8b>
Apr 22 10:08:52 shakti kernel: [435274.767584] buffer_info[next_to_clean]
Apr 22 10:08:52 shakti kernel: [435274.767585]   time_stamp           <29843da>
Apr 22 10:08:52 shakti kernel: [435274.767585]   next_to_watch        <8d>
Apr 22 10:08:52 shakti kernel: [435274.767586]   jiffies              <298464c>
Apr 22 10:08:52 shakti kernel: [435274.767587]   next_to_watch.status <0>
Apr 22 10:08:54 shakti kernel: [435276.765683] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 10:08:54 shakti kernel: [435276.765685]   Tx Queue             <0>
Apr 22 10:08:54 shakti kernel: [435276.765686]   TDH                  <8b>
Apr 22 10:08:54 shakti kernel: [435276.765687]   TDT                  <78>
Apr 22 10:08:54 shakti kernel: [435276.765687]   next_to_use          <78>
Apr 22 10:08:54 shakti kernel: [435276.765688]   next_to_clean        <8b>
Apr 22 10:08:54 shakti kernel: [435276.765689] buffer_info[next_to_clean]
Apr 22 10:08:54 shakti kernel: [435276.765690]   time_stamp           <29843da>
Apr 22 10:08:54 shakti kernel: [435276.765690]   next_to_watch        <8d>
Apr 22 10:08:54 shakti kernel: [435276.765691]   jiffies              <2984714>
Apr 22 10:08:54 shakti kernel: [435276.765692]   next_to_watch.status <0>
Apr 22 10:08:56 shakti kernel: [435278.763580] NETDEV WATCHDOG: eth0: transmit timed out
Apr 22 10:08:57 shakti kernel: [435280.482316] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX

--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="e1000-hang2.txt"

Apr 22 16:36:18 shakti kernel: [458498.700148] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 16:36:18 shakti kernel: [458498.700150]   Tx Queue             <0>
Apr 22 16:36:18 shakti kernel: [458498.700151]   TDH                  <31>
Apr 22 16:36:18 shakti kernel: [458498.700152]   TDT                  <1d>
Apr 22 16:36:18 shakti kernel: [458498.700152]   next_to_use          <1d>
Apr 22 16:36:18 shakti kernel: [458498.700153]   next_to_clean        <31>
Apr 22 16:36:18 shakti kernel: [458498.700154] buffer_info[next_to_clean]
Apr 22 16:36:18 shakti kernel: [458498.700154]   time_stamp           <2bbbdc6>
Apr 22 16:36:18 shakti kernel: [458498.700155]   next_to_watch        <33>
Apr 22 16:36:18 shakti kernel: [458498.700156]   jiffies              <2bbbec4>
Apr 22 16:36:18 shakti kernel: [458498.700157]   next_to_watch.status <0>
Apr 22 16:36:20 shakti kernel: [458500.698250] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 16:36:20 shakti kernel: [458500.698252]   Tx Queue             <0>
Apr 22 16:36:20 shakti kernel: [458500.698253]   TDH                  <31>
Apr 22 16:36:20 shakti kernel: [458500.698254]   TDT                  <1d>
Apr 22 16:36:20 shakti kernel: [458500.698255]   next_to_use          <1d>
Apr 22 16:36:20 shakti kernel: [458500.698255]   next_to_clean        <31>
Apr 22 16:36:20 shakti kernel: [458500.698256] buffer_info[next_to_clean]
Apr 22 16:36:20 shakti kernel: [458500.698257]   time_stamp           <2bbbdc6>
Apr 22 16:36:20 shakti kernel: [458500.698257]   next_to_watch        <33>
Apr 22 16:36:20 shakti kernel: [458500.698258]   jiffies              <2bbbf8c>
Apr 22 16:36:20 shakti kernel: [458500.698259]   next_to_watch.status <0>
Apr 22 16:36:22 shakti kernel: [458502.696351] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Apr 22 16:36:22 shakti kernel: [458502.696353]   Tx Queue             <0>
Apr 22 16:36:22 shakti kernel: [458502.696354]   TDH                  <31>
Apr 22 16:36:22 shakti kernel: [458502.696355]   TDT                  <1d>
Apr 22 16:36:22 shakti kernel: [458502.696355]   next_to_use          <1d>
Apr 22 16:36:22 shakti kernel: [458502.696356]   next_to_clean        <31>
Apr 22 16:36:22 shakti kernel: [458502.696357] buffer_info[next_to_clean]
Apr 22 16:36:22 shakti kernel: [458502.696357]   time_stamp           <2bbbdc6>
Apr 22 16:36:22 shakti kernel: [458502.696358]   next_to_watch        <33>
Apr 22 16:36:22 shakti kernel: [458502.696359]   jiffies              <2bbc054>
Apr 22 16:36:22 shakti kernel: [458502.696360]   next_to_watch.status <0>
Apr 22 16:36:23 shakti kernel: [458503.695087] NETDEV WATCHDOG: eth0: transmit timed out
Apr 22 16:36:24 shakti kernel: [458505.503739] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX

--k+w/mQv8wyuph6w0--

--5/uDoXvLw7AC5HRs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iD8DBQFIEJh3TIdDC2qqn8kRAiZQAJ9fFpUegwbIeEdQyiEJ701L2qlaAgCeJ79U
9cbPyGLszFu8Nk2VKBTz3+I=
=g7nT
-----END PGP SIGNATURE-----

--5/uDoXvLw7AC5HRs--
