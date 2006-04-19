From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.16-rc5] S2io: Receive packet classification and steering mechanisms
Date: Wed, 19 Apr 2006 15:45:48 -0700
Message-ID: <MAEEKMLDLDFEGKHNIJHIEEJDCDAA.ravinandan.arakali@neterion.com>
References: <200604190259.14854.ak@suse.de>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:19600 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751297AbWDSWp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:45:27 -0400
To: "Andi Kleen" <ak@suse.de>
In-Reply-To: <200604190259.14854.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi,
We would like to explain that this patch is tier-1 of a two
tiered approach. It implements all the steering
functionality at driver-only level, and it is fairly Neterion-specific.

The second upcoming submission will add a generic netlink-based
interface for channel data flow and configuration(including receive steering
parameters) on per-channel basis, that will utilize the lower level
implementation from the current patch.

Thanks,
Ravi

-----Original Message-----
From: Andi Kleen [mailto:ak@suse.de]
Sent: Tuesday, April 18, 2006 5:59 PM
To: ravinandan.arakali@neterion.com
Cc: jgarzik@pobox.com; netdev@vger.kernel.org
Subject: Re: [PATCH 2.6.16-rc5] S2io: Receive packet classification and
steering mechanisms


On Wednesday 19 April 2006 02:38, Ravinandan Arakali wrote:

> configuration: A mask(specified using loadable parameter rth_fn_and_mask)
> can be used to select a subset of TCP/UDP tuple for hash calculation.
> eg. To mask source port for TCP/IPv4 configuration,
> # insmod s2io.ko rx_steering_type=2 rth_fn_and_mask=0x0101
> LSB specifies RTH function type and MSB the mask. A full description
> is provided at the beginning of s2io.c

I don't think it's a good idea to introduce such weird and hard to
understand
module parameters for this.  I would be better to define a generic
internal kernel interface between stack and driver. Perhaps starting
with a standard netlink interface for this might be a good start
until the stack learns how to use this on its own.

> 3. MAC address-based:
> Done based on destination MAC address of packet. Xframe can be
> configured with multiple unicast MAC addresses.
>
> configuration: Load-time parameters multi_mac_cnt and multi_macs
> can be used to specify no. of MAC addresses and list of unicast
> addresses.
> eg. insmod s2io.ko rx_steering_type=8 multi_mac_cnt=3
> 	multi_macs=00:0c:fc:00:00:22, 00:0c:fc:00:01:22, 00:0c:fc:00:02:22
> Packets received with default destination MAC address will be steered to
> ring0. Packets with destination MAC addresses specified by multi_macs are
> steered to ring1, ring2... respectively.

The obvious way to do this nicely would be to allow to define multiple
virtual interfaces where the mac addresses can be set using the usual
ioctls.


-Andi

