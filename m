From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Thu, 20 Aug 2009 10:57:43 +0100
Message-ID: <fbd9d3990908200257ge4e13ceh32f28601bc0f762f@mail.gmail.com>
References: <20090818172752.GC17631@ovro.caltech.edu>
	 <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com>
	 <20090819003812.GA11168@ovro.caltech.edu>
	 <4A8B9051.3020505@redhat.com>
	 <20090819152811.GA22294@ovro.caltech.edu>
	 <4A8C1C22.3010101@redhat.com>
	 <20090819162902.GB22294@ovro.caltech.edu>
	 <4A8C2A87.5060305@redhat.com>
	 <1250715920.4237.26.camel@slab.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: Hollis Blanchard <hollisb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50410 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbZHTJ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:57:44 -0400
In-Reply-To: <1250715920.4237.26.camel@slab.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 10:05 PM, Hollis Blanchard<hollisb@us.ibm.com> wrote:
> On Wed, 2009-08-19 at 19:38 +0300, Avi Kivity wrote:
>> On 08/19/2009 07:29 PM, Ira W. Snyder wrote:
>> >>> That said, I'm not sure how qemu-system-ppc running on x86 could
>> >>> possibly communicate using virtio-net. This would mean the guest is an
>> >>> emulated big-endian PPC, while the host is a little-endian x86. I
>> >>> haven't actually tested this situation, so perhaps I am wrong.

Cross-platform virtio works when endianness is known in advance.  For
a hypervisor and a guest:
1. virtio-pci I/O registers use PCI endianness
2. vring uses guest endianness (hypervisor must byteswap)
3. guest memory buffers use guest endianness (hypervisor must byteswap)

I know of no existing way when endianness is not known in advance.
Perhaps a transport bit could be added to mark the endianness of the
guest/driver side.  This can be negotiated because virtio-pci has a
known endianness.  After negotiation, the host knows whether or not
byteswapping is necessary for structures in guest memory.

Stefan
