From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 14 Jan 2005 13:26:26 -0600
Message-ID: <200501141326.29575.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <16871.60849.905998.527106@robur.slu.se> <200501141300.44347.jeremy.guthrie@berbee.com>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1722434.I5vvOfWpoh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200501141300.44347.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1722434.I5vvOfWpoh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I actually upped the buffer count to 8192 buffers instead of 10k.  Of the 7=
4=20
samples I have thus far, 57 have been clean of errors.  Most of the sample=
=20
errors appear to be shortly after the cache flush.

I am going to let the buffers run for a bit longer then I have to go.  I ha=
ve=20
a five hour drive ahead of me. =20

On Friday 14 January 2005 01:00 pm, Jeremy M. Guthrie wrote:
> These stats are from the driver Jesse instrumented.
> ethtool -S eth3 | egrep -v ": 0"
> NIC statistics:
>      rx_packets: 1130958533
>      tx_packets: 5
>      rx_bytes: 2373643298
>      tx_bytes: 398
>      rx_errors: 4388190
>      rx_dropped: 1486253
>      rx_fifo_errors: 2901937
>      rx_missed_errors: 2901937
>      rx_long_byte_count: 582194228258
>      rx_csum_offload_good: 1040376597
>      int_tx_desc: 4
>      int_tx_queueempty: 5
>      int_link_state: 1
>      int_rx_desc_min_thresh: 20704
>      int_rx_fifo_ovr: 1208
>      int_rx_timer: 331925913
>      int_rxcfg: 1
>      rx_csum_offload_errors: 325045
>
> I am seeing more times w/ his driver where I run at zero errors.  Of the
> last 877 samples since I switched drivers, I see 231 samples w/ zero
> errors.
>
> On Friday 14 January 2005 10:05 am, Robert Olsson wrote:
> > Jeremy M. Guthrie writes:
> >  > I ran a script overnight using the modified driver you had given me
> >  > Robert. it is interesting that there is almost always errors in the
> >  > interface even though we aren't getting dst-cache errors and running=
 ~
> >  > 40% free CPU now.  I am going to switch over to Jesse's driver to see
> >  > if his instrumentation helps nail down where the problem is.
> >  >
> >  >
> >  >      rx_packets: 2722676103
> >  >      tx_packets: 5
> >  >      rx_bytes: 1171335471
> >  >      tx_bytes: 398
> >  >      rx_errors: 8558366
> >  >      tx_errors: 0
> >  >      rx_dropped: 1951692
> >
> >  It might come from be periodic work from GC process correlate drops w.
> > rtatat.
> >
> >  I think the GC process can be made more smooth but studies and
> > experimentation is probably needed as GC process is quite complex. Maybe
> > some looked into this already?
> >  Also you reported less drops when you increased the size of the RX ring
> > and I see higher system performance with smaller RX rings. Both
> > statements may actually be true. Big rings size may buffer during
> > periodic work as GC.
>
> I am running w/ 2048 input buffers.  I am going to increase to 10K and try
> again.
>
> >  Also I have an experimental patch so you route without the route hash =
as
> > a comparison. You have to be brave...
>
> I am about 300 miles from the machine this week and next week though I
> might be able to try it this weekend while I am home.
>
> >  BTW we had this thread going for week,
>
> Pardon me for being a bit naive but I am not understanding this last
> comment.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1722434.I5vvOfWpoh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB6BzlqtjaBHGZBeURAoSjAJ4/VOZwu9cpJ3P8bjfgWvl4hRWhFwCfY7Cw
0w3Q/VDpYzMapAZIegRJoGQ=
=zpTx
-----END PGP SIGNATURE-----

--nextPart1722434.I5vvOfWpoh--
