From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 8 Feb 2012 11:57:18 +0100
Message-ID: <CAPXgP10-W+yeHJMENzWi7FBkYOaXw6ccMMMT=K9X2bf_Tigitw@mail.gmail.com>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
 <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
 <20120204021457.GA25386@khazad-dum.debian.net> <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
 <20120208020038.GE13296@khazad-dum.debian.net> <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
 <14373.1328683324@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42134 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab2BHK5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:57:38 -0500
In-Reply-To: <14373.1328683324@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2012 at 07:42,  <Valdis.Kletnieks@vt.edu> wrote:
> On Wed, 08 Feb 2012 04:50:15 +0100, Kay Sievers said:
>
>> After years of working in that area I will stop to work on these hacks
>> to promise stable ethX names. It was just wrong, like enumerations
>> always are in hotplug setups.
>
> So (real world case) I've got a server that's got a 1G ethernet connected to
> the public net, a 1G ethernet that's a cluster management network, and
> a 10G ethernet that connects to our HPC clusters.
>
> And I want to add iptables rules that distinguish based on interface. Currently
> I can nail the management net to eth0, the public net to eth1, and the 10G to
> eth2, and then just add "-i eth1" or whatever in the iptables ruleset.
>
> I really don't care if the 0/1/2 move around - but if we're not having nailed-down
> interface names, what will take the place of '-i ethN' in iptables?
>
>> People who need predictable interface names should just manually
>> configure custom/descriptive names, or names which are reliably
>> derived from the hardware, like firmware-provided names or the pci
>> slot number.
>
> Or is this sort of thing in /etc/udev/rules.d/70-persistent-net.rules
> SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:25:90:0b:f2:80", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
> what you are trying to move to, and my systems are already onboard and
> I should just move along, nothing to see here? ;)

Yeah, that's what we did in the past. It works fine if you never have
to swap names like eth0 and eth1, with need to free one of the the
names with a temporary rename.

If another device is added by a different kernel module, or just a USB
network device is already plugged-in at bootup time, the parallel
loading of drivers might cause the kernel to create a new eth0 or eth1
just in the moment we have the temporary rename active and we want to
swap the names.

That model is just entirely flawed and will never work reliably
without creating an even bigger mess we already have, by requiring
complex retry loops across multiple devices, or having global locks
including the kernel's device name allocation logic.

Let's just move on and stop pretending we want or we can solve these
problems. Simple device enumerations in hotplug setups can by their
very definition not work in a predictable way, we should never have
tried to mess around here, and just moved on to something that has at
least the potential to work.

Kay
