From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Wed, 19 Aug 2009 11:40:09 +0300
Message-ID: <4A8BBA69.4060500@iki.fi>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi> <4A8AA63D.4000702@trash.net> <4A8AB25A.4000105@iki.fi> <4A8AC1A0.6000602@trash.net> <4A8AE76D.7040707@iki.fi> <4A8B02D2.2090400@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:56434 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbZHSIkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 04:40:09 -0400
In-Reply-To: <4A8B02D2.2090400@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Ok, finally figured out the difference. Looks like depending
> on the sendto() / local route / forward route / my patched mrt
> the skb that gets passed to ipgre_tunnel_xmit() seems to have
> nfctinfo either 0 or 2. This value is not modified; nf_reset()
> is called just before ip_local_out(). Looks like nf_reset()
> clears nfct to NULL, but does not touch nfctinfo.
>=20
> So when LOCAL_OUT hook for the GRE packet is hit, depending
> where the packet came: it has nfct=3DNULL and nfctinfo=3DESTABLISHED
> or NEW. This also seems to affect if that specific skb gets
> the nat/OUTPUT hook called.
>=20
> Is this behaviour for nf_reset() intentional?

Apparently it does not matter.

The real problem seems to be bug that did not account for
irq times properly. It was fixed by "sched: account system time
properly" f5f293a4e3d0a0c52cec31de6762c95050156516 and that
caused biased CPU usage measurements.

Testing with kernel having that, I'm getting the same CPU
readings. And oprofile in timer mode didn't help noticing this.

Sorry for the noise.

- Timo

