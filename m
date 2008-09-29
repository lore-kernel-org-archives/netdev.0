From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: AIM9 regression
Date: Mon, 29 Sep 2008 08:36:21 -0700 (PDT)
Message-ID: <31318813.77411222702581550.JavaMail.root@tahiti.vyatta.com>
References: <48E0EC13.3060907@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org,
	=?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33832 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbYI2PgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 11:36:23 -0400
In-Reply-To: <48E0EC13.3060907@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message -----
=46rom: "Christoph Lameter" <cl@linux-foundation.org>
To: "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi>
Cc: "David Miller" <davem@davemloft.net>, shemminger@vyatta.com, herber=
t@gondor.apana.org.au, netdev@vger.kernel.org
Sent: Monday, September 29, 2008 4:54:11 PM GMT +01:00 Amsterdam / Berl=
in / Bern / Rome / Stockholm / Vienna
Subject: Re: AIM9 regression

Ilpo J=C3=A4rvinen wrote:

> ...I was thinking earlier to answer "time?", but now once been there,=
 it=20
> seems that more time is more appropriate... So far I haven't been abl=
e to=20
> find a way to create a reproducable serie of result numbers with aim9=
=20
> tcp_test... it seems that the results vary within that (at least) 20%=
=20
> margin. Can Christoph actually get stable numbers out of it with 27-r=
cs
> (I haven't extensively tested .22 yet with long test durations but it=
=20
> seems that same problem occurs with it as well if short tests were us=
ed)?

Results fluctuate between 10 - 25%. The problem occurs with the short
durations as well. If this is due to the additional code complexity in =
later
kernels as we suspect then it may be an issue with cpu cache effectiven=
ess.

Going to 64 bit binaries also yields a significant hit (as high as 30%)=
 which
also indicates caching issues.

Both 64 bit kernels and later kernels cause the variability of results =
to
increase. 64 bit has double the effect than a 2.6.27 kernel. All indica=
tions
of cpu caching issues. The L1 cache may become ineffective due to the
increased cache footprint.

-------------
One of the items showing up in the profile is the local side port alloc=
ation.
Is the ephemeral port range getting full? If it is then the random port=
 scan
could take a long time to find the next free slot, especially now that =
source
ports are randomized.



