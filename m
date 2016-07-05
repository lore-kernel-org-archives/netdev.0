From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 SRIOV VLAN support
Date: Tue, 5 Jul 2016 11:11:05 +0300
Message-ID: <CALzJLG8Y3N2PqbJuLTSbfWcxbWJuugZ62nJvz0_Tq7hFSN7axA@mail.gmail.com>
References: <CAOYAsN=5VQM-QF+vnx=p1DtDV+912QO9kwDE-wszXmTJLc4uGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: domingo montoya <reach.domingomontoya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35353 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbcGEILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 04:11:25 -0400
Received: by mail-yw0-f176.google.com with SMTP id l125so55351966ywb.2
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 01:11:25 -0700 (PDT)
In-Reply-To: <CAOYAsN=5VQM-QF+vnx=p1DtDV+912QO9kwDE-wszXmTJLc4uGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 10:37 AM, domingo montoya
<reach.domingomontoya@gmail.com> wrote:
> Hi,
>
> Is VLAN supported in SRIOV mode for mlx5?
>

For VGT mode vlan is supported by default same as bare-metal.
For VST you need to use ip tool to configure VST vlan:  ip link set
eth<X> vf 1 vlan 2 qos 2

note: VGT mode will not work on VF if VST is configured on that VF.

>
> Can anyone please help me to:
>
> Enable VLAN guest tagging in mlx5 PF driver?
>
> Do I need to add any E-switch rules to do the same?
>

No,
Nothing is required for VGT mode, just create the vlan on guest VF
machine and work with it!
E-Swtich is automatically/dynamically configured.

>
> My requirement is something like this:
>
>
> mlx5 VF driver<--------------->mlx5 PF
> driver<------------------------->Network<-----------> mlx5 dedicated
> driver(non-sriov)
>
>
>
> I would like to be able to send ICMP traffic between mlx5 VF driver
> and mlx5 dedicated driver.
>
> My understanding is I should be able to do without adding any rules in
> the E-switch on the PF driver as by default all traffic is allowed.
>
> Is this correct?
>

correct.

>
>
> I tried but as this didn't work. I added ingress rules to allow VLAN
> traffic and also egress rules to the E-switch ACL tables.
>

How did you do this ? changed the code ? by default (no VST/no spoof
check) ACL tables should not be opened.

> But still i cannot see any traffic between mlx5 VF driver and mlx5
> dedicated driver.
>
> I can see that the packets reach the CX4 adapter (mlx5 VF/mlx5 PF) but
> they don't go out on the network.
>
> i tried configuring vlan using ip link add dev enp1s0f0 name
> enp1s0f0.100 type vlan id 100 on both the mlx5 vf driver and mlx5
> dedicated driver.
>
>

Strange, should work. Please make sure VST mode is off on the VF.
can you share some logs with us:
on PF/VF and remote dedicated driver:

ip link show <interface>
ethtool -k <interface>

Thanks,
Saeed.
