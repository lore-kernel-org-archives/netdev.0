From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: ip xfrm policy semantics
Date: Fri, 09 Jan 2009 21:21:42 +0200
Message-ID: <4967A3C6.30901@iki.fi>
References: <49675C3E.6010109@iki.fi> <496784AE.6000505@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:44788 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbZAITVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 14:21:49 -0500
Received: by ey-out-2122.google.com with SMTP id 22so1146343eye.37
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 11:21:47 -0800 (PST)
In-Reply-To: <496784AE.6000505@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Ok, I tried to find what the code does. Apparently the ip_forward() c=
alls=20
> xfrm4_route_forward() which ends up doing __xfrm_route_forward() fall=
ing
> back to xfrm_lookup() which is fixed to use XFRM_POLICY_OUT. So 'out'
> policy is always used; even for packets that are being forwarded.
>=20
> Ok, now I tried adding:
>   policy in  src pptp-server
>   policy out dst pptp-server
>   policy out dst internal-pptp-client
>=20
> all with high priority and policy 'none'. Now it looks like the packe=
ts
> from pptp-client go out to internet properly. The connection tracking
> entries are recorded, but the reply packets from pptp-server do not
> get back to internal-pptp-client. Apparently the 'none' policy preven=
ts
> NAT to work.

=46orget the above. I had a typo in my policy config.

Having:
  policy out dst pptp-server
  policy out dst internal-pptp-client

set to high priority and no transforms works great too.

> Any ideas what would the proper way to patch XFRM to distinguish if
> forwarded packets should be touched or not?

So basically, I would like to have separate policy for 'out' and
'fwd_out'. But adding new policy type is kinda bad. I wonder why
in the first place 'in' and 'fwd' were split, but 'out' was left
all alone without any information about if it's forwarded or local
packet?

So, I'm back to thinking how to fix this without adding IP
addresses to my security policies.

The options I could think of are:
1. A way to test input interface on policy selector
2. GRE upper layer awareness. gre key being the likely key.
(3. Splitting 'out' policy to 'out' and 'outfwd')

Any comment on which would the preferred way to go?

- Timo
