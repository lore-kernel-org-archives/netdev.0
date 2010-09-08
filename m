From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 12:54:23 -0700
Message-ID: <AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj@mail.gmail.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009081142.31610.sven.eckelmann@gmx.de>
	<AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ@mail.gmail.com>
	<201009082058.15533.sven.eckelmann@gmx.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org
To: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201009082058.15533.sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 8, 2010 at 11:58 AM, Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org> wro=
te:
> Jesse Gross wrote:
>> Potentially one way to do this is to build on top of Open vSwitch. =A0It
>> contains a pretty generic flow-based kernel module for forwarding data
>> packets and making simple modifications. =A0Control packets can be sent
>> to userspace to handle the routing logic, while data packets remain in
>> the kernel for performance. =A0This would dramatically reduce the amount
>> of code that needs to be in the kernel and may even help performance
>> by simplifying the fast path.
>>
>> I don't know the details of your protocol well enough to know if this
>> is feasible but it seems like something you might want to look into.
>> Open vSwitch is currently in the process of finalizing its interfaces
>> to prepare for upstreaming.
>
> It sounds interesting. I haven't looked into it yet, but maybe you could
> easily answer some questions:
> =A0* Does it allow to generate multiple net_devices on the system?

Yes.

> =A0* Does it allow to attach multiple net_devices to a single openvswitch
> =A0 device?

Yes.

> =A0* Does the attaching of a net_device to a openvswitch device prevent i=
t to be
> =A0 added to another openvswitch device?

It can be set up in different ways, depending on the desired behavior.

> =A0* Does it propagate the information about the incoming device to the
> =A0 userspace in case of the not routed packets (everything which should

I think the last part of your question got cut off.  However, packets
do include metadata about the input device.  Userspace would then be
able to use the normal Linux mechanisms to find out whatever it needs
(or look at its own information).

> =A0* Does it allow to append extra header information to the packet?
> =A0* Does it allow fragmentation of packets (not real fragmentation, but =
more
> =A0 single split)?

I'm assuming that both of these questions are for tunneling.  Open
vSwitch currently supports a few different L2 over L3 tunneling
mechanisms and has a tunnel library that makes adding additional
protocols easy.  It probably can't do exactly what you need right now,
but it should be fairly easy to extend.

> =A0* Does it allow to define outgoing patterns (on which attached interfa=
ce
> =A0 goes the thing out again) on packet number or incoming device (the re=
al
> =A0 hardware device it was coming in)?

I'm not sure what you mean by "packet number".  It does allow you to
specify the output interface based on a number of factors, include the
input device.

> =A0* Is it possible to define rules like: "If this is a broadcast of an u=
dp/ip
> =A0 packet with target port 123 which may or may not have a vlan tag, but=
 is
> =A0 coming directly from the virtual device and is not routed by us, then
> =A0 change the mac address to following"?

Yes.

> =A0* Can it be backported to old kernels (~2.6.21 - yes, their are "custo=
mers"
> =A0 who need even older kernels due to the fantastic vendors out their)?

The kernel module currently supports 2.6.18+.
