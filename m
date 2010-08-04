From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Yet another bridge netfilter crash
Date: Thu, 5 Aug 2010 07:00:22 +0800
Message-ID: <AANLkTiniy+APw27u3Ld8YrRWqP7wwkSEoU=u94nhkxPd@mail.gmail.com>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net>
	<20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net>
	<20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60881 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759449Ab0HDXA7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 19:00:59 -0400
Received: by wwj40 with SMTP id 40so7078830wwj.1
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 16:00:45 -0700 (PDT)
In-Reply-To: <4C5995C2.1010909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 12:30 AM, Patrick McHardy <kaber@trash.net> wrot=
e:
> Am 23.07.2010 17:26, schrieb Herbert Xu:
>> On Fri, Jul 23, 2010 at 05:17:42PM +0200, Patrick McHardy wrote:
>>>
>>>> There's also the matter of fragments jumping between bridges.
>>>
>>> Conntrack zones can be used to avoid that, but that currently needs
>>> manual configuration.
>>
>> I think this is something that we need to fix. =A0Because as it
>> stands, it can still crash if you get the wrong nf_bridge.
>>
>> The reason is that skb->dev does not hold a ref count. =A0So the
>> reassembly code just throws it away and always uses the dev of
>> the last fragment.
>>
>> This breaks when two bridges combine to reassemble a single
>> packet, as the nf_bridge attribute of the reassembled packet
>> may come from an skb whose device is now dead. =A0This is then
>> used to fill in the skb->dev (via nf_bridge->physindev).
>
> We could perform a new device lookup on reassembly as we do
> when expiring a fragment queue, but we probably shouldn't even
> be reassembling fragments from different bridges. One way to
> avoid this would be to automatically assign each bridge device
> to a different conntrack zone, but conntrack zones are limited
> to 2^16 and this might also have other unwanted side-effects.
>
> Until we come up with something better the best fix seems to
> be to perform the device lookup based on the iif.

How about holding physindev and physoutdev when queueing the skbs into
frag queue, and take the skb->dev(bridge NIC) as a key when queueing
the skbs from bridges?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
