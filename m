From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH] ethtool: add IPv6 to the NFC API
Date: Fri, 22 Jan 2016 17:03:21 +0000
Message-ID: <56A260D9.3020004@solarflare.com>
References: <1453317771.3734.68.camel@decadent.org.uk>
 <56A12E29.7000507@solarflare.com>
 <CAKgT0UeP4u04PsaupuQ19HdOxa6qZ3dCaxbdJeJ4DJ-Oqq+SOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:36931 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754420AbcAVRDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 12:03:36 -0500
In-Reply-To: <CAKgT0UeP4u04PsaupuQ19HdOxa6qZ3dCaxbdJeJ4DJ-Oqq+SOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/01/16 22:48, Alexander Duyck wrote:
> On Thu, Jan 21, 2016 at 11:14 AM, Edward Cree <ecree@solarflare.com> wrote:
>> +       __be32  spi;
> Is this supposed to be the flow label, or is this the IPSec security
> parameter index?  If it is the flow label you may want to rename it.
> If it is supposed to be the IPSec security parameter index this might
> belong in a different flow definition since it is not actually a part
> of the IPv6 header.
It's the IPSec SPI; I just blindly copied what ethtool_ah_espip4_spec had.
I guess splitting out three different spec structs as per ipv4 would make
this somewhat clearer.
Would the flow label be useful thing to include?  I would have thought it'd
be a bit too short-lived normally.
>> +       __u8    tos;
>> +       __u8    proto;
>> +};
>> +
> Technically the name of the field for proto is nexthdr.
But will NICs filter on the actual nexthdr, or on the *last* nexthdr in the
chain of IPv6 options?  If the latter, calling it nexthdr might be misleading.
(I've just checked what sfc will do, it filters on the last nexthdr.)

Will spin a v2 shortly.

-Ed
