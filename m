From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Tue, 06 Oct 2015 00:34:52 -0700
Message-ID: <5613799C.1060400@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <56129A32.1010201@gmail.com> <20151005163012.GO2278@nanopsycho.orion> <5612AC1E.1050504@gmail.com> <CAE4R7bAwu+NTa7mBHQSYpfhmGm=tL=6xfXrweNJhT1tD5eFeAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34323 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbbJFHfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:35:06 -0400
Received: by padhy16 with SMTP id hy16so62157237pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:35:05 -0700 (PDT)
In-Reply-To: <CAE4R7bAwu+NTa7mBHQSYpfhmGm=tL=6xfXrweNJhT1tD5eFeAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>> Its related in that if you expose your device model you do not need
>> opaque strings to do wholesale reconfiguration of the device. Instead
>> if the parts of the device that are configurable are exposed to the
>> user they can build the "world" they want.
> 
> The disconnect here, I believe, is offloading to hw the Linux
> forwarding plane vs. offloading an arbitrary application's forwarding
> plane.  Switchdev (and rocker) are about offloading the Linux
> dataplane.  That means Linux _is_ the application (the NOS); hw
> offloads what it can from the kernel to accelerate pkt forwarding.
> But the user's experience is standard Linux tools (iproute2, netlink)
> and building blocks (bridge, bond, etc) are used to construct a switch
> (or router), and the fact that the data path is offloaded to hw is
> transparent to the user.  We could define APIs for arbitrary
> applications to program hardware, like John is suggesting. by giving
> up raw access to hw resources, like tables, etc.  This approach moves
> the "driver" to the application, and by-passes the Linux tools and
> building blocks.  We're still TBD on these APIs, probably because of
> the "by-pass" part.

Thanks Scott I think this helps some.

I don't view my approach as a by-pass though or even letting arbitrary
applications have access to the hardware. Today I load arbitrary
filters and bpf programs into the kernel to create a pipeline. Now I
want to string a couple other tables in front of my pipeline to do
some of the heavy lifting. Maybe the real difference is my _datapath_
is not offloaded (by-passing?) the kernel. Most (all?) of my packets
are meant for the host and I want to do partial offloading where some
of the initial processing is done in the hardware and the rest is
handled by software. The "driver" is not in the application it is
still in the kernel.

I almost have something ready to kick out I meant to do this today
might be another day or two though.

> 
> Jiri's patchset here is about moving things around so he can define
> another hw mode in rocker.   The upper edge for rocker driver is still
> switchdev, but with the new eBPF hw mode he's working on, he'll be
> able to push down a dynamic pipeline rather than being stuck with the
> OF-DPA pipeline we have today (in rocker).  I presume once he has this
> new eBPF support, he'll program in a "Linux kernel" pipeline, and fill
> out the corresponding swtichdev ops.  I imagine a P4 -> ePBF compiler,
> and we take a linux.p4 and program hw.  Linux.p4 should be
> generic...consumable by any hardware...it is a representation of the
> Linux pipeline.  (Similar to P4's switch.p4).
> 
> But now, with eBPF mode in hw, an arbitrary.p4 could be written for
> that arbitrary application and pushed down.  We still need APIs for
> that application.
> 

My gripe here was flipping the hardware between modes with a string
value. It seems it has been dropped from the latest version though so
I have no problem with the patches.

.John
