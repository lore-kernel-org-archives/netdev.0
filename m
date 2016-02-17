From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic
 unless there was an error
Date: Tue, 16 Feb 2016 20:07:03 -0500 (EST)
Message-ID: <20160216.200703.2116723624769185830.davem@davemloft.net>
References: <87bn7rrqdk.fsf@doppelsaurus.mobileactivedefense.com>
	<20160216.125157.1927195719504877809.davem@davemloft.net>
	<1455668691.1143.18.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rweikusat@mobileactivedefense.com, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, joseph.salisbury@canonical.com
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455668691.1143.18.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 17 Feb 2016 00:24:51 +0000

> I agree that 'if (err) goto cleanup;' is widely used and is generally
> understandable (though more creative uses of goto are often not).
>=20
> My objection was to 'err =3D -EFOO; if (cond) goto cleanup;'. =A0That=
 is
> definitely not clear and it hides mistakes like this.

I don't see any difference whatsoever.

Part of the convention of the cleanup blob at the end of the
function is that error propagate to it's return statement via
a variable.

If this code wanted to handle that in more than one way, it is
the problem of this function, not of the convention itself.
