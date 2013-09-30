From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v4] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Mon, 30 Sep 2013 17:09:35 +0200
Message-ID: <5249942F.3090504@xdin.com>
References: <523A4F5E.9070503@xdin.com> <20130920.151017.2125552741552759738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>, <elias.molina@ehu.es>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:60493 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775Ab3I3PJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 11:09:38 -0400
In-Reply-To: <20130920.151017.2125552741552759738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-09-20 21:10, David Miller wrote:
> From: Arvid Brodin <arvid.brodin@xdin.com>
> Date: Thu, 19 Sep 2013 03:11:58 +0200
>=20
>> +#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
>> +		/* We need to memmove the whole header to work around
>> +		 * alignment problems caused by the 6-byte HSR tag.
>> +		 */
>> +		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
>> +			skb_headlen(skb_deliver));
>> +		skb_deliver->data -=3D HSR_TAGLEN;
>> +		skb_deliver->tail -=3D HSR_TAGLEN;
>> +#endif
>=20
> You can't do this.
>=20
> First of all, you have no idea if subtracting skb->data a given amoun=
t
> will underflow the skb buffer start.  You aren't even checking, all
> of the standard skb_*() data adjustment interfaces do.

(Shorter and more to the point than my previous replies:)

I _do_ know: this can't possibly underflow since strip_hsr_tag() a=20
few lines above pulled the same amount of data. I will rename=20
strip_hsr_tag() to hsr_pull_tag() to make this clearer.


> Secondly, everything after the header is now at the wrong offset from
> the beginning of the packet.

How does this matter? The memmove moves everything back (restores the=20
changes made to the packet on the sending side) so that it is at the
"normal" position for an ethernet packet.


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
