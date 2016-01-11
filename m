From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Mon, 11 Jan 2016 13:21:29 +0000
Message-ID: <5693AC59.4080702@solarflare.com>
References: <56901197.8040808@solarflare.com>
 <56901235.1010800@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:40036 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760015AbcAKNVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:21:47 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 10:09, David Laight wrote:
> From: Edward Cree
>> Sent: 08 January 2016 19:47
> ...
>> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
>> +		csum = csum_fold(lco_csum(skb));
>> +		if (csum == 0)
>> +			csum = CSUM_MANGLED_0;
>> +		return csum;
>> +	} else {
>> +		return csum_fold(skb_checksum(skb, 0, skb->len, 0));
>> +	}
> You see to be worried about csum_fold() returning 0 in one
> path, but not in the other.
> I'm guessing that 0 can only happen if all the bytes that have
> been checksummed are zero.
csum_fold complements, so if the sum comes to (say) 0x1fffe, it will return ~0xffff which is 0.

Next version of patch will mangle 0 for both branches.

-ed
