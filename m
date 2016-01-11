From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Mon, 11 Jan 2016 10:39:40 -0800
Message-ID: <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<56901235.1010800@solarflare.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
	<5693AC59.4080702@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33694 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757452AbcAKSjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:39:41 -0500
Received: by mail-io0-f195.google.com with SMTP id f81so11090126iof.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:39:40 -0800 (PST)
In-Reply-To: <5693AC59.4080702@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 5:21 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 11/01/16 10:09, David Laight wrote:
>> From: Edward Cree
>>> Sent: 08 January 2016 19:47
>> ...
>>> +    if (skb->ip_summed == CHECKSUM_PARTIAL) {
>>> +            csum = csum_fold(lco_csum(skb));
>>> +            if (csum == 0)
>>> +                    csum = CSUM_MANGLED_0;
>>> +            return csum;
>>> +    } else {
>>> +            return csum_fold(skb_checksum(skb, 0, skb->len, 0));
>>> +    }
>> You see to be worried about csum_fold() returning 0 in one
>> path, but not in the other.
>> I'm guessing that 0 can only happen if all the bytes that have
>> been checksummed are zero.
> csum_fold complements, so if the sum comes to (say) 0x1fffe, it will return ~0xffff which is 0.
>
> Next version of patch will mangle 0 for both branches.

Actually you may want to go the other way on that.  If they weren't
flipping the checksum value for GRE before why should we start doing
that now?  I'm pretty sure the checksum mangling is a very UDP centric
thing.  There is no need to introduce it to other protocols.

- Alex
