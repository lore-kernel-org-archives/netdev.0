From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 21:59:39 -0500
Message-ID: <5497891B.9020904@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <5497250F.2020906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:39441 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbaLVC7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 21:59:43 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so3365429igd.7
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 18:59:42 -0800 (PST)
In-Reply-To: <5497250F.2020906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 14:52, John Fastabend wrote:

> not a problem thanks for the response. I might try to document this
> somewhere if folks think it would be useful. Something describing
> how it works today would be helpful is my thought. Showing the
> various stacked cases and how messages get propagated. (Some cases
> being with bridge, without bridge, with bridge and multiple uplinks,
> with bridge + VLAN filtering, macvlan, SR-IOV + bridge + VMDQ, etc.)
>
> Its not a small task so likely won't get to it until after the new
> year.
>

I think this would be very useful.
We are looking for an L2 tutorial at netdev01 (I was looking at
Vlad and Roopa so far) so maybe we could split the work. Would
you be interested?
Yes, all those bridge and bridge like things like Vxlan for example
should be part of this de-mystification.
Shrijeet is also putting together a BOF for the offload stuff.

>
> Yes, but I don't think its too late to bring it into the picture here.
>

that would be nice.


>>> The PF port, when acting as the control interface, is actually
>>> TheClassThingy we discuss on/off.
>
> Yep or if you take Jiri's approach any port on the nic could be used
> to manage this.
>
> The VF's may have netdev's if they are in the host. In this case you
> could use 'bridge fdb' to manage them. In many use cases though the
> VFs are directly assigned to VMs and then are outside the hosts
> management domain. For this case you can either let the host tell the
> driver which addresses it would want to receive.
>

Which driver? The PF? I dont think the semantics allow for that;
How do i tell the PF using "fdb add" that a specific mac+vlan should
be sent to vf1 which is now sitting inside some vm?

> Another _idea_ would be to create a "shadow" netdev in the host
> to manage the port even when the VF is direct assigned.

That may work. But there are questions:
Can its name be changed within the container/vm or are those
different namespaces etc.
So if the answer is that "self" implies using the hardware fdb,
what does "master" mean?


>Then you
> could use all your normal commands from the host to set the MTU,
> set any MACs, etc. At the moment as Jamal noted we have a subset
> of 'ip link' commands that we use to work on VFs when they are not
> in the host domain.
>
>      'ip link set ethx vf # ...'
>

I think once it moves management of such things as MTUs should be from
wherever that thing sits at (vm/container) to avoid any suprises.


> In the SR-IOV case you would have a PF and then a set of eth-vf#
> netdev's which are not attached to a VF but act as the management
> interface for the port.
>

you can have more than one PF?


> I think this is not specific to SR-IOV though right.This is the
> same point for both "real" switch ASICs and SR-IOV. Using the netdev
> directly as a management interace (a la rocker) seems to work OK.
> But does it become cleaner to have the switch object represented
> explicitly for management.
>

Indeed it does. In particular if you had to move around a bridge port
to a container or VM.
Now if we introduced the idea of showing up with netdev for each vf
and you had a classthing you dont have to keep the vf1s visible
once migrated - but would be able to add fdb entries pointing to
them (assuming names/ifindices remain valid).

cheers,
jamal
