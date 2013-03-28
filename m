From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Thu, 28 Mar 2013 14:12:12 +0100
Message-ID: <20130328131212.GA7721@order.stressinduktion.org>
References: <1364335457.8215.21.camel@localhost> <20130327151210.GA23223@order.stressinduktion.org> <1364398673.21709.4.camel@localhost> <20130327181146.GB23223@order.stressinduktion.org> <1364408454.15362.1.camel@localhost> <20130327183558.GC23223@order.stressinduktion.org> <1364475638.5000.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36314 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab3C1NMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:12:14 -0400
Content-Disposition: inline
In-Reply-To: <1364475638.5000.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 02:00:38PM +0100, Wilco Baan Hofman wrote:
> For 6rd, rfc5969 section 9 specifies that a link *may*, if needed, have
> a non-used link-local address [2], this may be where the /128 comes in:
> 
>    The 6rd link is modeled as an NBMA link similar to other automatic
>    IPv6 in IPv4 tunneling mechanisms like [RFC5214], with all 6rd CEs
>    and BRs defined as off-link neighbors from one other.  The link-local
>    address of a 6rd virtual interface performing the 6rd encapsulation
>    would, if needed, be formed as described in Section 3.7 of [RFC4213].
>    However, no communication using link-local addresses will occur.
> 

Hm, perhaps this is the reason. Also, RFC3964 ("Security Considerations for
6to4") states that the use of non-global addresses on a 6to4 link should be
prohibited:

|   o  Disallow traffic in which the destination IPv6 address is not a
|      global address; in particular, link-local addresses, mapped
|      addresses, and such should not be used.

Could you check if the creation of a /128 ll address does act as a guard
against that and does suppress ll traffic? I am not sure.

Perhaps a patch where we check the IFF_POINTTOPOINT flag and selectively
create a /128 or /64 would be a solution.

Thanks,

  Hannes
