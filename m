From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.16-rc5] S2io: Receive packet classification and steering mechanisms
Date: Wed, 19 Apr 2006 02:59:14 +0200
Message-ID: <200604190259.14854.ak@suse.de>
References: <MAEEKMLDLDFEGKHNIJHIAEIGCDAA.ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:8381 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750960AbWDSA71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 20:59:27 -0400
To: ravinandan.arakali@neterion.com
In-Reply-To: <MAEEKMLDLDFEGKHNIJHIAEIGCDAA.ravinandan.arakali@neterion.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 April 2006 02:38, Ravinandan Arakali wrote:

> configuration: A mask(specified using loadable parameter rth_fn_and_mask)
> can be used to select a subset of TCP/UDP tuple for hash calculation.
> eg. To mask source port for TCP/IPv4 configuration,
> # insmod s2io.ko rx_steering_type=2 rth_fn_and_mask=0x0101
> LSB specifies RTH function type and MSB the mask. A full description
> is provided at the beginning of s2io.c 

I don't think it's a good idea to introduce such weird and hard to understand
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
virtual interfaces where the mac addresses can be set using the usual ioctls.


-Andi
