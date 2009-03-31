From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: TX time stamping
Date: Tue, 31 Mar 2009 08:53:41 +0200
Message-ID: <1238482421.11761.19.camel@pohly-MOBL>
References: <1236105081.4653.68.camel@pohly-MOBL>
	 <20090319.140509.152824531.davem@davemloft.net>
	 <20090320021050.GA7021@gondor.apana.org.au>
	 <1237964924.26966.310.camel@pohly-MOBL>
	 <20090326144835.GA19592@gondor.apana.org.au>
	 <1238081410.19066.125.camel@ecld0pohly>  <49D10AE4.8070907@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35046 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbZCaGx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 02:53:58 -0400
In-Reply-To: <49D10AE4.8070907@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-03-30 at 21:09 +0300, Oliver Hartkopp wrote:
> i wonder if using the IP stack for PTP with the possibility to send TX-stamped
>  PDUs on various interfaces is the best solution.

PTPd already only sends on one interface. How to deal with packets that
go out via multiple interfaces becomes relevant when generalizing the
hardware time stamping concept.

> I'm not aware of all the routing, packet scheduling, etc. stuff that much -
> but does it probably make sense to use AF_PACKET for PTP, where you can
> specify the interface and build a PTP IP PDU directly? I assume this does not
> make that big difference to the ptpd in userspace.

I'm not familiar with AF_PACKET. It let's user space assemble the
complete packet (including Ethernet header) and send directly via a
specific interface, right?

The drawback is that the user space daemon would have to reimplement the
joining/leaving of a multicast group. When using the IP stack, it can
let the kernel do that.

It also still uses write() or sendmsg(), doesn't it? In that case
there's no advantage over the current approach because the only link
back to the sender is still only the socket.

But perhaps I am simply unaware of some aspects of the socket API for
AF_PACKET. Is there something which would allow implementing Herbert's
approach with communication via sh_info when the sender is in user
space?

Herbert, what do you think about the "identify socket via unique ID"
idea? Is that possible/doable/acceptable/stupid/all of these?

-- 
Best Regards

Patrick Ohly
Senior Software Engineer

Intel GmbH
Software & Solutions Group                
Hermuelheimer Strasse 8a                  Phone: +49-2232-2090-30
50321 Bruehl                              Fax: +49-2232-2090-29
Germany

