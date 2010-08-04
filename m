From: Patrick McHardy <kaber@trash.net>
Subject: Re: Yet another bridge netfilter crash
Date: Wed, 04 Aug 2010 18:50:50 +0200
Message-ID: <4C599A6A.6050202@trash.net>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net> <20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net> <20100804164119.GA6256@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab0HDQuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:50:52 -0400
In-Reply-To: <20100804164119.GA6256@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.08.2010 18:41, schrieb Herbert Xu:
> On Wed, Aug 04, 2010 at 06:30:58PM +0200, Patrick McHardy wrote:
>>
>> We could perform a new device lookup on reassembly as we do
>> when expiring a fragment queue, but we probably shouldn't even
>> be reassembling fragments from different bridges. One way to
>> avoid this would be to automatically assign each bridge device
>> to a different conntrack zone, but conntrack zones are limited
>> to 2^16 and this might also have other unwanted side-effects.
>>
>> Until we come up with something better the best fix seems to
>> be to perform the device lookup based on the iif.
> 
> I don't think we can as the iif will point to the bridge device.
> The physindev contains the original physical device where the
> packet came in.

If it originally points to the bridge device, there doesn't
seem anything wrong with the device pointing to the bridge
device after reassembly. Am I missing something?
