From: Josh Triplett <josh@freedesktop.org>
Subject: Re: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Sun, 20 Jan 2008 23:29:32 -0800
Message-ID: <479449DC.4020105@freedesktop.org>
References: <20080120152146.70bc0b12@deepthought> <20080121050355.GD7541@linux.vnet.ibm.com> (sfid-20080120_230505_499288_FFFFFFFFEE31D810)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBC0B967D443129AEDBF04EB7"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:44954 "EHLO
	mail3.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbYAUH3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 02:29:19 -0500
In-Reply-To: <20080121050355.GD7541@linux.vnet.ibm.com> (sfid-20080120_230505_499288_FFFFFFFFEE31D810)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBC0B967D443129AEDBF04EB7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Paul E. McKenney wrote:
> On Sun, Jan 20, 2008 at 03:21:46PM -0800, Stephen Hemminger wrote:
>> Get rid of some more sparse warnings.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Adding Josh to CC -- is __acquires() case-insensitive?  If not, this
> needs to be __acquires(RCU) and __releases(RCU).
[...]
>> --- a/net/core/dev.c	2008-01-20 14:25:00.000000000 -0800
>> +++ b/net/core/dev.c	2008-01-20 14:25:48.000000000 -0800
>> @@ -2543,6 +2543,7 @@ static void *ptype_get_idx(loff_t pos)
>>  }
>>
>>  static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
>> +	__acquires(rcu)
>>  {
>>  	rcu_read_lock();
>>  	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
>> @@ -2578,6 +2579,7 @@ found:
>>  }
>>
>>  static void ptype_seq_stop(struct seq_file *seq, void *v)
>> +	__releases(rcu)
>>  {
>>  	rcu_read_unlock();
>>  }

At the moment, Sparse doesn't actually use the context expression.  In
the ideal case when it does, all references to the same lock should
use a context expression which resolves to that lock (whatever that
may mean; hence why Sparse doesn't handle it yet).  For mechanisms
like RCU without a lock variable, this will likely entail some sort of
fake lock expression, which again needs to match between all users of
the same mechanism.  Like any expression in C, case matters; thus,
please match the existing references to "RCU" rather than "rcu".

- Josh Triplett


--------------enigBC0B967D443129AEDBF04EB7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHlEncGJuZRtD+evsRApRxAJ9/1VMb+Iz8RF/kn9mmv7MQFoTNBwCgjESG
MVKCl6RtJMS72wfv8MgwfQM=
=zndJ
-----END PGP SIGNATURE-----

--------------enigBC0B967D443129AEDBF04EB7--
