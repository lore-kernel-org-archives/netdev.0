From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 20:35:42 +0200
Message-ID: <ac3eb2510910101135t5bedb1ferc0806fe2fee15a83@mail.gmail.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	<20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com>
	<20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	<20091010052308.GA12458@kroah.com> <20091010141124.82d226b8.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:50563 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbZJJSge convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 14:36:34 -0400
In-Reply-To: <20091010141124.82d226b8.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2009 at 20:11, Bill Fink <billfink@mindspring.com> wrot=
e:
> No comment on the specific implementation decision, but I am in the
> process of setting up a large number of test systems with identical
> hardware configurations, and using a master disk image to clone all t=
he
> test systems. =C2=A0The biggest pain in this process is identiying th=
e MAC
> addresses for each of the six or more network interfaces in each test
> system (we want eth0...ethN to always reference the same physical por=
t
> on the test systems), and then having to modify the 70-persistent-net=
=2Erules
> udev file and the HWADDR entry for all the ifcfg-ethX files to reflec=
t
> the correct MAC addresses. =C2=A0It would be fantastic if there were =
some
> mechanism for making this part of the process unnecessary.

Udev creates the persistent rules only if no other rule set a name.
Adding something like:
  SUBSYSTEM=3D=3D"net", KERNEL=3D=3D""eth*", NAME=3D"eth%n"
in any earlier rules file before the udev generated one will skip all
off the automatic udev rule creation.

Kay
