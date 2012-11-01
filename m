From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Wed, 31 Oct 2012 17:50:45 -0700
Message-ID: <B23C28F0-4005-4970-984D-3BAD063EA513@alum.mit.edu>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu> <CAOxq_8O8Vkm5Napp_h6HVj6C=EH2gd_PQJJ1N5d_VQZrRZFYNQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	tcpdump-workers@lists.tcpdump.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.mail.sonic.net ([64.142.19.5]:50237 "EHLO b.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584Ab2KABCo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:02:44 -0400
In-Reply-To: <CAOxq_8O8Vkm5Napp_h6HVj6C=EH2gd_PQJJ1N5d_VQZrRZFYNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 31, 2012, at 3:35 PM, Ani Sinha <ani@aristanetworks.com> wrote:

> yes but if the packet is passed to the filter within libpcap (when we
> are not using the kernel filter) before the reinsertion,

...that would be a bug.

Currently, that bug doesn't exist in the recvfrom() code path, but *does* appear to exist in the tpacket code path - and that code path also runs the filter before the SLL header is constructed.  That should be fixed.

Yes, it means constructing the SLL header and inserting the tags blah blah blah on packets that might not pass the filter, but in most cases the filtering should be done in the kernel, not userland, when doing a live capture, and in those cases where the filtering can't done in the kernel, you're already somewhat hosed by the fact that the packets are being copied to the buffer and wakeups are being delivered before the packets are being filtered.
