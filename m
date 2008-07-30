From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Wed, 30 Jul 2008 08:49:38 -0400
Message-ID: <48906362.2090902@hp.com>
References: <488E0192.9030406@hp.com>	<20080728174432.GA15892@gerrit.erg.abdn.ac.uk>	<488E0B73.8070701@hp.com> <20080730.031935.61479223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:47459 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbYG3Mto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 08:49:44 -0400
In-Reply-To: <20080730.031935.61479223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 28 Jul 2008 14:09:55 -0400
> 
>> The IPv6 checks are much different.  The MUST requirement is to provide as much
>> data as possible upto IPv6 min mtu.  So, the IPv6 icmp code should probably look
>> to see if min(payload_len, min_mtu) is provided.
> 
> "Be liberal in what you accept..." -Jon Postel

Yeah, that check is really too strict.

> 
> Also, do you know any case where 576 bytes won't provide enough
> quoted packet bytes? :-)
> 

Yes, I've seen a case where a full 1280 was needed.  It involved a
very convoluted packet that had extension headers and then went
through 2 encapsulations.  This was an extreme test scenario and
not a real world example.

-vlad
