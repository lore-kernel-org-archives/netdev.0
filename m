From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Wed, 20 Jan 2016 11:35:20 -0800
Message-ID: <CAKgT0Ufpj2DpaLPOzU5hyFATpjN=jT9ziJCpmSMo1QkefAcAKQ@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<56901235.1010800@solarflare.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
	<5693AC59.4080702@solarflare.com>
	<CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
	<8BD201BE-E272-4BA7-ABB4-8FDCE139495D@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38535 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbcATTfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 14:35:21 -0500
Received: by mail-ig0-f177.google.com with SMTP id mw1so19100909igb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 11:35:20 -0800 (PST)
In-Reply-To: <8BD201BE-E272-4BA7-ABB4-8FDCE139495D@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 11:11 AM, Rustad, Mark D
<mark.d.rustad@intel.com> wrote:
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> Actually you may want to go the other way on that.  If they weren't
>> flipping the checksum value for GRE before why should we start doing
>> that now?  I'm pretty sure the checksum mangling is a very UDP centric
>> thing.  There is no need to introduce it to other protocols.
>
>
> If different checksum representations are needed, then there really should
> be an explicit indication of whether it is a UDP-style checksum or other in
> the skb I would think rather than guessing it based on the offset. Of course
> it would be convenient if all the protocols that use a one's complement
> checksum would tolerate the UDP representation. I have a long (and now old)
> history working with real one's complement machines, and so I would want to
> believe that any correct implementation would tolerate it, but I don't know
> for a fact that they do.

The only reason why UDP does the bit flip is because it has reserved a
checksum of 0 as a special value.  For the checksum math itself either
0xFFFF or 0 are interchangeable.  The only time they would make any
difference would be if we had a value of 0 that we were checksumming,
but since that is not the case the values will always end up
converging back onto 0xFFFF as the final result in the case of a
correct checksum.

- Alex
