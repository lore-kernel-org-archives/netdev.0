From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 08:34:02 -0700
Message-ID: <1242315242.25299.11.camel@w-sridhar.beaverton.ibm.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
	 <200905142128.58111.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:45259 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbZENPeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 11:34:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4EFaM09000997
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:36:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4EFY5VT185284
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:34:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4EFY4Yq025747
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:34:05 -0400
In-Reply-To: <200905142128.58111.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-05-14 at 21:28 +0930, Rusty Russell wrote:
> On Thu, 14 May 2009 07:37:42 pm Or Gerlitz wrote:
> > Hi,
> >
> > When running with jumbo frames (i.e set tap0 and guest nic mtu to 9k)
> > and using 8k sized packets with iperf, the qemu process exits with
> > "virtio-net truncating packet" which I see in the code of
> > qemu/hw/virtio-net.c
> >
> > :: virtio_net_receive(). This happens only when the VM is receiving, if I
> >
> > send 8K packets from the VM things go fine.
> >
> > I use virtio based NIC in the VM and Linux 2.6.29.1 in both the VM and the
> > host. Qemu is the one provided by kvm release 84 - whose sources don't
> > point me to a specific git tree nor a maintainer, so I hope you can help
> > me...
> 
> Maintainer Cc'd.  The answer is that virtio_net by default only supports 1500 
> MTU; I've not tried larger MTUs.


I am able to get virtio-net to work with an MTU upto 65521 between host and guest 
using qemu-kvm git tree and linux-2.6.30-rc5 running on the host and guest.
I didn't run into any issues while running iperf or netperf  with larger than 8K
message sizes.

I changed the mtu of the bridge and tap device on the host and the guest 
virtio-net device to 65521.

Thanks
Sridhar

