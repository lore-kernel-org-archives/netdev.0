From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: no connectivity on PF with Intel 82599/SR-IOV/OVS
Date: Mon, 1 Dec 2014 12:47:25 -0800
Message-ID: <CAADnVQ+L06LEmwXvhTFSXDKv3kepdCqLzjSGmhPy7G+oBwCs6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dmitry N." <plretbox@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:43236 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbaLAUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 15:47:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc-ing netdev

On Mon, Dec 1, 2014 at 3:45 AM, Dmitry N. <plretbox@gmail.com> wrote:
> Hello all.
>
> I'm having an issue with SR-IOV on 82599 NIC in lab env. Basically
> what I have is Ubuntu 12.04 with a set of vanilla kernels and Open
> vSwitch.
>
> A simplified scheme for ovs setup:
> br-mgmt -> [vlan 102]br-eth0 -> eth0 -> fabric
>
> When VFs are disabled, connectivity works fine. However when at least
> one VF is enabled, traffic just doesn't go any further than br-eth0.
> Oddly enough, it acts this way only if VLAN is configured on br-eth0
> via OVS. When I try to configure VLAN with ip link, it works just
> fine.
>
> It's not an udev issue because re-adding eth0 to br-eth0 doesn't help.
> I've tried different OVS and ixgbe/ixgbevf versions against different
> kernel versions and ruled out issues with OVS and ixgbe.
>
> This could be a kernel bug.
>
> Kernel versions I've tried:
> 3.11.0 works fine
> 3.12.24 has this issue
> 3.14.23 has this issue
> 3.15.10 has this issue
> 3.16.7 and later kernels: the situation is opposite: when VFs are
> disabled, there is no connectivity on PF; as soon as at leas 1 VF is
> enabled, connectivity appears.
>
> OVS versions:
> 2.3.0 for user space
> 2.3.0 (and kernel native where 2.3.0 is not supported - starting with
> 3.15.x) for kernel space
>
> ixgbe:
> latest from Intel website (3.22.3)
>
> ixgbevf:
> latest from Intel website (2.15.3)
>
> Any suggestions? Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
