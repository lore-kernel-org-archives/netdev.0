From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 14:54:51 -0600
Message-ID: <200501061454.54595.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061335.55104.jeremy.guthrie@berbee.com> <16861.40858.80960.794144@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1802544.rI78qs9h2M";
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

--nextPart1802544.rI78qs9h2M
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 January 2005 02:29 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  You only use CPU0 for packet processing. Also it seems you use  the
>  > > non-NAPI version of e1000.
>  >
>  > The E1000 driver is the stock driver in 2.4.28.
>  There is a kernel config option.  Use Rx Polling (NAPI)
I'm recompiling the module and will reload the module.

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
I installed the NAPI driver and now I drop packets under 2.4.28.  I tried=20
setting eth2/3 onto the same CPU.  If both eth2/3 are on CPU0, I drop a lot=
=20
of packets.  If CPU0-eth2 & CPU1-eth3, I still drop packets, just not as=20
fast.

I am going to try V2.6 w/o NAPI to see how much that helps.

>  The stats info you sent was almost impossible to read. See if you can get
>  only the rtstats.


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1802544.rI78qs9h2M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3aWeqtjaBHGZBeURAgJLAJ9Ivcgnf/HcOFB4eMC9XGFGC1ck4wCfeYG/
MT8a07gBXWfgSiaudO8YcDs=
=bxZV
-----END PGP SIGNATURE-----

--nextPart1802544.rI78qs9h2M--
