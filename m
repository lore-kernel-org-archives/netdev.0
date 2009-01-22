From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 11:24:41 +0200
Message-ID: <49783B59.90208@iki.fi>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au> <49782EE4.2070809@iki.fi> <20090122085053.GA12806@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:39325 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbZAVJYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:24:47 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2092385fgg.17
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 01:24:45 -0800 (PST)
In-Reply-To: <20090122085053.GA12806@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 22, 2009 at 10:31:32AM +0200, Timo Ter=E4s wrote:
>> The (quickish) look on *swans would imply that for each
>> dynamic connection I would need to hand create a new connection
>> entity. Could be scriptable, but then I would somehow
>> need to make up connection names based on the IPs and always
>> inject full config by the admin tool.
>=20
> They have templates for inbound connections on servers and also
> outbound connections which were used for Opportunistic Encryption.
> So you can adapt these to generate connections on demand.
>=20
> Also creating/destroying connections at run-time is really easy
> without generating a full config at all by using ipsec whack.

I think I looked into openswan int he beginning in detail
and it had various problems. I think there wasn't netlink
stuff there either when I looked into it.

Looking at strongswan now, it does look a lot more usable.

But I don't like how IKEv2 is complitely separate from
IKEv1. Different daemons, different whack interface, etc.

There was some other things too why I decided to go for
ipsec-tools in the beginning. But it doesn't really matter
as long as I get IPsec.

So for the time being, I can have my patched kernel, fix
some of the swans and switch to it, or even write my own
IPsec keying manager if it comes to that. IPsec KM is not
that relevant for me, as long as it works.

>> But if there's multiple nodes behind same public IP the xfrm
>> has two (or more) choices for which xfrm state to use. The
>> NAT-OA can be used as distinguishing factor. So when ip_gre
>> sends out packet, the xfrm can choose the correct xfrm state.
>=20
> That's precisely what you don't want to do unless you trust all
> your peers equally.  The reason is that NAT-OA is not authenticated,
> i.e., I can choose any address to send over as NAT-OA and there
> is nothing you can do to stop me.
>=20
> It was only ever intended to be used for fixing up the checksum
> so you can't safely use it for making policy/routing decisions.

In DMVPN/GRE case, the NAT-OA from IPsec would not be used
unless the NAT-OA is set on neighbour cache. This would not
happen unless NHRP can authenticate it. In DMVPN case you need
a valid certificate to give the ranom NAT-OA in any case. So
if you lie about your NAT-OA I can just revoke you.

Or do you have, other recommendations how to distinguish peers
behind same public IP than NAT-OA? Maybe we add the certificate
subject to xfrm state and neighbour cache. And use that?
That would certainly be authenticated. Would that be a better
approach? Or in general, allow a random token to be associated
with an xfrm state, so that we can connect neighbor cache in
gre interface to that specific state.

- Timo
