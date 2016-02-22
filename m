From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Mon, 22 Feb 2016 16:12:36 +0100
Message-ID: <56CB2564.9030003@stressinduktion.org>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
 <5679C58C.2090308@stressinduktion.org>
 <20160222150443.GV26042@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51045 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbcBVPMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 10:12:41 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 4325220C76
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 10:12:41 -0500 (EST)
In-Reply-To: <20160222150443.GV26042@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marc,

On 22.02.2016 16:04, Marc Haber wrote:
> In prose:
>
> The host is a host for KVM VMs. It receives IPv6 connectivity via RA
> on eth0, where the default gateway announces its address as fe80::1.
> It also provides IPv6 connectivity to the VMs via the br0 interface.
> It is running radvd on br0, and for statically configured VMs it has
> also fe80::1 on br0.
>
> If accept_ra_from_local on eth0 were 0, the system would not accept
> the RA from the default gateway and and up with no IPv6 since fe80::1
> is locally configured with br0.

Isn't this behavior fixed with

commit c1a9a291cee0890eb0f435243f3fb84fefb04348
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Wed Dec 23 22:44:37 2015 +0100

     ipv6: honor ifindex in case we receive ll addresses in router 
advertisements

$ git describe --contains c1a9a291cee0890eb0f435243f3fb84fefb04348
v4.4-rc8~5^2~10

?

If you don't have fe80::1%br0 bound on exactly that interface, it should 
work, no? So, no need for accept_ra_from_local, which has dubious 
semantics anyway.

> If accept_ra_from_local on eth0 is 1, the system accepts both the RA
> from the default gateway on eth0 _AND_ its own RA sent out and
> received on br0, and, making things worse, is setting the IP address
> and default route not on br0, but on eth0.

Understood. Thanks, I was just able to easily reproduce it. Was already 
wondering why someone would enable accept_ra_from_local besides only 
testing. I check it out, thanks!

Thanks,
Hannes
