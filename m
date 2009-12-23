From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 01:15:30 -0500
Message-ID: <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu>
	<4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu>
	<4B3103B4.4070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:56877 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbZLWGPu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 01:15:50 -0500
In-Reply-To: <4B3103B4.4070708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2009 at 12:36, Gregory Haskins
<gregory.haskins@gmail.com> wrote:
> On 12/22/09 2:57 AM, Ingo Molnar wrote:
>> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>>> Actually, these patches have nothing to do with the KVM folks. [...=
]
>>
>> That claim is curious to me - the AlacrityVM host
>
> It's quite simple, really. =C2=A0These drivers support accessing vbus=
, and
> vbus is hypervisor agnostic. =C2=A0In fact, vbus isn't necessarily ev=
en
> hypervisor related. =C2=A0It may be used anywhere where a Linux kerne=
l is the
> "io backend", which includes hypervisors like AlacrityVM, but also
> userspace apps, and interconnected physical systems as well.
>
> The vbus-core on the backend, and the drivers on the frontend operate
> completely independent of the underlying hypervisor. =C2=A0A glue pie=
ce
> called a "connector" ties them together, and any "hypervisor" specifi=
c
> details are encapsulated in the connector module. =C2=A0In this case,=
 the
> connector surfaces to the guest side as a pci-bridge, so even that is
> not hypervisor specific per se. =C2=A0It will work with any pci-bridg=
e that
> exposes a compatible ABI, which conceivably could be actual hardware.

This is actually something that is of particular interest to me.  I
have a few prototype boards right now with programmable PCI-E
host/device links on them; one of my long-term plans is to finagle
vbus into providing multiple "virtual" devices across that single
PCI-E interface.

Specifically, I want to be able to provide virtual NIC(s), serial
ports and serial consoles, virtual block storage, and possibly other
kinds of interfaces.  My big problem with existing virtio right now
(although I would be happy to be proven wrong) is that it seems to
need some sort of out-of-band communication channel for setting up
devices, not to mention it seems to need one PCI device per virtual
device.

So I would love to be able to port something like vbus to my nify PCI
hardware and write some backend drivers... then my PCI-E connected
systems would dynamically provide a list of highly-efficient "virtual"
devices to each other, with only one 4-lane PCI-E bus.

Cheers,
Kyle Moffett
