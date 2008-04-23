From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Question of Network 1Gbps Intel Packet Split
Date: Wed, 23 Apr 2008 08:46:15 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205005516@orsmsx418.amr.corp.intel.com>
References: <5d96567b0804222317i7c6f900wc8a9164423610976@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Raz" <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58408 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbYDWPqq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 11:46:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <5d96567b0804222317i7c6f900wc8a9164423610976@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raz wrote:
> I have been wondering whether anyone can answer the bellow two
> questions. Intel PCI-E 1Gbps cards have a feature for rx mode :
> "packet split". 

If you'd included something about e1000/e1000e in the message our
filters would have marked this so we could reply to you :-)

> so:
> 1. Is it true that when "packet split" is enabled, **ALL** packets
> will be splitted , header / payload ?

All packets that are 
a) recognized, i.e. IPv4, TCP, UDP, IPv6, etc
b) not too short (sometimes packets < 70 bytes or so are not split, at
least on 82571)
c) sometimes the header after the TCP/UDP header can be split too, like
maybe for NFS, you're welcome to read the manual for PCIe parts posted
at e1000.sf.net

> 2. Is is true that there is exactly one fragment when splitted ?

nr_frags will typically be 1, unless the frame is too short ( < 128 )
and then it is "unsplit" into the header buffer to avoid the page
free/allocation.

In the case of e1000/e1000e, splitting the packet is best used for jumbo
frames, and in that case multiple pages can be used to hold the packet,
with a single header buffer at skb->data, and nr_frags > 1

Hope this helps, and in the future you're welcome to post to
e1000-devel@lists.sf.net for these kinds of specific to Intel hardware
questions.
  
  Jesse
