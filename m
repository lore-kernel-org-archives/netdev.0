From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 12:14:16 +0000
Message-ID: <56681B18.3030200@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:57170 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751782AbbLIMOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 07:14:24 -0500
In-Reply-To: <20151208.120654.2127200076257822677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/15 17:06, David Miller wrote:
> All of the headers get touched anyways as each layer of the stack > demuxes the packet. Therefore there is _ZERO_ cost to use 1's > complement to validate checksums in input. It's always superior.

Ah, I understand now, it's touching the memory that's expensive, not adding
up the numbers. Thanks for being patient with me :)

So that just leaves the question of offloading multiple _TX_ checksums.
Remote checksum offload would deal with this but the receiver might not
support it, meaning that after decapsulation the packet will have a zero
checksum (and still has chances to get corrupted); thus it's not necessarily
safe to do unless you control both endpoints and know you have RCO
everywhere.
Convincing hardware designers to go the HW_CSUM way and only fill in the
inner checksum, when their current approach can fill in both inner and outer
checksums (though admittedly only for the protocols the hardware knows
about), might be difficult.

Remember that NICs are going to have packet parsing for those protocols
anyway, because they need it for things like Windows-spec RSS, so in the
hardware designer's mind, ossified offloads are "free".
