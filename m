From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 0/2][RFC] virtio_net: MAC filtering
Date: Wed, 07 Jan 2009 11:28:25 -0700
Message-ID: <1231352906.7109.140.camel@lappy>
References: <1231351559.7109.128.camel@lappy>
	 <4964F11B.7020509@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:40200 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbZAGS16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 13:27:58 -0500
In-Reply-To: <4964F11B.7020509@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-07 at 12:14 -0600, Anthony Liguori wrote:
> Alex Williamson wrote:
> >
> > As noted in the RFC thread adding the kvm/qemu backing, this does
> > increase the size of the virtio-net device I/O port space, up to 1kB
> > with PCI rounding if we add a 4k entry VLAN bitmap.  A 64 device limit
> > is still pretty high for a VM, but maybe we should think about adding
> > MMIO space for virtio-pci.  Thanks,
> >   
> 
> I'm not quite sure the best way to address this.  Maybe another control 
> queue for sending commands to control this sort of stuff?  What are your 
> thoughts Rusty?

This is also a good time to decide if a fixed 16 entry MAC filter table
is sufficient.  Should the size be programmed into the config space?
There's plenty of room to make it a bigger fixed size and still stay at
1kB of I/O port space with the VLAN table.  This implementation is a
little wasteful of space in using 8 bytes to store the MAC and a valid
bit, but I suspect there's some endian issues I'm ignoring and a
standard data type might make that easier later.

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

