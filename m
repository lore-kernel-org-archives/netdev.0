From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 15:19:59 -0600
Message-ID: <200501061520.02362.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061335.55104.jeremy.guthrie@berbee.com> <16861.40858.80960.794144@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1762425.JcF5JoSj3n";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.40858.80960.794144@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1762425.JcF5JoSj3n
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Pulling Rx Polling has kept V2.6 from dropping packets.  argh?!?!?!  I shou=
ld=20
have caught that sooner.   8(  Well, I have a window of opportunity here.  =
If=20
you want I can still provide a broken environment but that seems pointless=
=20
while NAPI is not acting right... what is evident is that this will run=20
better till we start to bump up against the top of CPU0.

On Thursday 06 January 2005 02:29 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  You only use CPU0 for packet processing. Also it seems you use  the
>  > > non-NAPI version of e1000.
>  >
>  > The E1000 driver is the stock driver in 2.4.28.
>
>  There is a kernel config option.  Use Rx Polling (NAPI)
>
>  > eth2 is TX only.  We don't receive anything on it.  This system should
>  > only ever RX on eth3 and TX on eth2 as part of its function.
>
>  Ok! So unidirectional traffic and CPU0 processes all skb's and passes th=
em
>  over to CPU1 which touches and frees them. You could try some other
>  affinity setting later on but there are so many options depending what
>  we want do. If we just want to compare 2.4/2.6 we can start out simple
>  with setting affinity so only one CPU. Which is almost what you got.
>  We reach all the complicated problems immediately... Now we pass skb's
>  between the CPU's which release cache bouncing and makes slab rebalance
> it's pools. So using just one CPU is probably better... If we had incoming
> pkts on eth2 eventually we could have had any use for CPU1.
>
>  Install NAPI-driver, set affinity so eth2/eth3 uses same CPU to start
> with.
>
>  The stats info you sent was almost impossible to read. See if you can get
>  only the rtstats.
>
>       --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1762425.JcF5JoSj3n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3auCqtjaBHGZBeURAjvkAJ45z7mmyPo5uy7j5n6AUuz9mom0ZwCfabzF
9epO/lWTp3KOLc5IGxztcJU=
=c04g
-----END PGP SIGNATURE-----

--nextPart1762425.JcF5JoSj3n--
