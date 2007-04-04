From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Optimize MTU calculation
Date: Wed, 04 Apr 2007 15:07:34 +0200
Message-ID: <4613A316.8090805@trash.net>
References: <46128290.5060701@trash.net> <4612B268.6060204@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miika Komu <miika@iki.fi>
To: DiegoB <diego.beltrami@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58514 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992896AbXDDNHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 09:07:36 -0400
In-Reply-To: <4612B268.6060204@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DiegoB wrote:
> Patrick McHardy wrote:
> 
>> I've updated my IPsec MTU optimization patch I've posted a couple
>> of month ago to net-2.6.22 and added the further optimization
>> suggested by Herbert to account for the space lost due to alignment
>> in the room reserved for IP options in transport mode.
>>
>> Tested with IPv4 and IPv6 in tunnel and transport mode. Beet mode
>> is untested since no keying daemon seems to support it.
> 
> 
> Actually for BEET mode you can check the following:
> 
> http://hipl.hiit.fi/
> http://www.openhip.org/
> http://www.hip4inter.net/


Thanks for the pointers, I'm using manual keying for testing now.
It took me a while to properly set it up though since I wasn't
expecting that I need to specify a selector for the inbound SA.
Is there a reason for not using x->props.saddr/x->id.daddr during
inbound processing as on the output side?

draft-nikander-esp-beet-mode-06.txt states ".. MUST contain the
outer source and destination addresses, as defined in the SA"
for both inbound and outbound processing, so I think it would
be easier to handle this symetrical.
