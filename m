From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding
 sessions
Date: Sun, 01 Dec 2013 20:35:06 -0500 (EST)
Message-ID: <20131201.203506.1790384137281236147.davem@davemloft.net>
References: <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com>
	<52920CEE.2040407@universe-factory.net>
	<529AB8E9.30004@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab3LBBfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:35:08 -0500
In-Reply-To: <529AB8E9.30004@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Sun, 01 Dec 2013 05:19:53 +0100

> On 11/24/2013 03:27 PM, Matthias Schiffer wrote:
>> On 11/01/2013 09:21 AM, Steffen Klassert wrote:
>>> On some codepaths the skb does not have a dst entry
>>> when xfrm_decode_session() is called. So check for
>>> a valid skb_dst() before dereferencing the device
>>> interface index. We use 0 as the device index if
>>> there is no valid skb_dst(), or at reverse decoding
>>> we use skb_iif as device interface index.
>>>
>>> Bug was introduced with git commit bafd4bd4dc
>>> ("xfrm: Decode sessions with output interface.").
>>>
>>> Reported-by: Meelis Roos <mroos@linux.ee>
>>> Tested-by: Meelis Roos <mroos@linux.ee>
>>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> 
>> Please queue this for 3.12-stable, I've seen this bug trigger a panic
>> when heavily using Bittorrent (screenshot:
>> http://i.imgur.com/OIKVccM.jpg )
>> 
>> Thanks,
>> Matthias
>> 
> 
> Ping? Several people I know have hit this panic with 3.12.x at least
> once or twice by now during heavy IPv6 usage.

Steffen submitted it to stable@vger.kernel.org for inclusion on Monday
November 25th.
