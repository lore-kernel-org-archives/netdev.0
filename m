From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 18:22:29 +0800
Message-ID: <20150415102229.GA3917@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48529 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbDOKWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:22:33 -0400
Content-Disposition: inline
In-Reply-To: <552E3B7A.2040701@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 12:20:42PM +0200, Nicolas Dichtel wrote:
> Le 15/04/2015 12:01, Herbert Xu a =E9crit :
> >The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> >harmonize cleanup done on skb on rx path") broke anyone trying to
> >use netfilter marking across IPv4 tunnels.  As the commit message
> >did not give any justification for this (in fact it shouldn't
> >even be touching the tx path), I can only assume that it was a typo.
> If I remember well, this was discussed on netdev (CC Eric). The goal =
of this
> patch was, like the title said, to hamonize packets processing in tun=
nels.
> I'm not against to keep the mark, but I think patching skb_scrub_pack=
et is
> better. With your patch, ip6tnl, gre6, etc. still drops the mark. And=
 at the
> end, it's not consistant.
>=20
> What about something like this:

Yes this is better.  I'm currently auditing all the other bits
that are cleared to see if there is anything else that we should
preserve for tunneling.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
