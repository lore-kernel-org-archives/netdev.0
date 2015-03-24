From: David Christensen <davidch@broadcom.com>
Subject: RE: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Tue, 24 Mar 2015 18:48:41 +0000
Message-ID: <3A5015FE9E557D448AF7238AF0ACE20A2D8D704A@IRVEXCHMB11.corp.ad.broadcom.com>
References: <20150323002215.GA6074@roeck-us.net>
 <550F6D7D.7030403@gmail.com> <550F8102.7040701@roeck-us.net>
 <550F8600.2020300@gmail.com> <550F8987.5070600@roeck-us.net>
 <5510498D.5010001@cumulusnetworks.com>
 <CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
 <20150324142921.GA2026@nanopsycho.orion>
 <20150324160126.GA17104@roeck-us.net> <5511A29F.5010006@cumulusnetworks.com>
 <20150324175825.GA1465@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	"John Fastabend" <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"David Miller" <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:59869 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbbCXSsn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:48:43 -0400
In-Reply-To: <20150324175825.GA1465@roeck-us.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This is still overhead for every packet on the switches we support. The
> > number of ports can go close to 128
> > (40G ports can be broken into 4x10G ports).
> >
> Agreed. Given that, and since dev_get_by_index_rcu uses a hash to find the
> device pointer, it may actually be (much) faster (and the above "iterate
> over all ports" is a bit misleading).
> 
> I tested the above approach with DSA and a Marvell switch chip. It works,
> but I am a bit concerned about the per-packet overhead, especially
> in larger networks. I would prefer if there would be a means to 'catch'
> duplicate packets earlier - before they are even created, if that is
> possible.

Seems like we're running into issues that would be encountered by stacked
switches.  Should we consider similar solutions, i.e. a stacking protocol
like HiGig?  In this situation each packet would be passed between switches
along with a stacking data structure that indicates relevant information
such as where the packet was first received (i.e. an ingress module ID) 
and a bit indicating that it's a broadcast packet.  The receiving switch
then knows which ports the broadcast frame has already egressed and can
then flood remaining ports if necessary.  You can also create a CPU bit
if you want to forward the frame specifically to the host CPU.

It requires more upfront work but pays off later in flexibility.

Dave
