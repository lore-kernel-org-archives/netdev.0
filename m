From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 16:55:52 -0600
Message-ID: <200501131655.55407.jeremy.guthrie@berbee.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C02D39006@orsmsx408>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart12160972.rPvSlENFIn";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Robert Olsson" <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C02D39006@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart12160972.rPvSlENFIn
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Thu Jan 13 16:50:06 CST 2005 entries:  0000cc39  Packets:  1127110  Errors:=
 =20
264136  PPS:  75140  Percentage:  23.43%
Thu Jan 13 16:50:22 CST 2005 entries:  000142c0  Packets:  1148930  Errors:=
 =20
743  PPS:  76595  Percentage:  0.6%
Thu Jan 13 16:50:37 CST 2005 entries:  0001aa91  Packets:  1158591  Errors:=
 =20
116  PPS:  77239  Percentage:  0.1%
Thu Jan 13 16:50:52 CST 2005 entries:  00021146  Packets:  1192241  Errors:=
 =20
11648  PPS:  79482  Percentage:  0.97%
Thu Jan 13 16:51:07 CST 2005 entries:  00025c42  Packets:  1227489  Errors:=
 =20
1056  PPS:  81832  Percentage:  0.8%
Thu Jan 13 16:51:22 CST 2005 entries:  00029ca0  Packets:  1217954  Errors:=
 =20
365  PPS:  81196  Percentage:  0.2%


ethtool -S eth3
NIC statistics:
     rx_packets: 8778549
     tx_packets: 5
     rx_bytes: 327267728
     tx_bytes: 398
     rx_errors: 575319
     tx_errors: 0
     rx_dropped: 360028
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 215291
     rx_missed_errors: 215291
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 4622235024
     rx_csum_offload_good: 8285347
     int_tx_desc: 5
     int_tx_queueempty: 6
     int_link_state: 1
     int_rx_frame_err: 0
     int_rx_desc_min_thresh: 1330
     int_rx_fifo_ovr: 47
     int_rx_timer: 1768171
     int_mdio: 0
     int_rxcfg: 1
     int_gpio_pins: 0
     rx_csum_offload_errors: 698


On Wednesday 12 January 2005 06:49 pm, Brandeburg, Jesse wrote:
> I didn't send this to netdev.... if the interrupt counting code does
> something good then we can publish it.
>
> Jeremy, I would agree a faster CPU is going to help you handle more
> traffic.  I can't speak to the routing thing.  Your test would be very
> interesting if we could set up something similar here, unfortunately
> we're mostly interested in network device performance and not so much on
> kernel policy routing.  I personally would be interested in having
> something set up to "play" with the driver on, but it may be doubtful
> how much time I would get to spend on it.
>
> Anyway, here is a driver that counts interrupt sources, you can get the
> counts from
> ethtool -S eth3
>
> you'll need to compile it like so:
> make CFLAGS_EXTRA=3D-DE1000_COUNT_ICR
>
> any messages in /var/log/messages from the network stack?  (I just saw
> your netdev email about dst cache overflow) This driver has what we
> think should be the correct napi code in e1000_clean.  If robert's fix
> works better for you then stick with it, and let me know cause what I'm
> sending you now is what we're going forward with unless we hear about
> problems.
>
> If you want to chat over an instant messenger of some kind here is my
> info:
> Aim: jbrandeb
> msn: go_jesse@hotmail.com
> yahoo: go_jesse
>
> I appreciate your patience as we try different stuff.  I know I'm poking
> at the driver a lot, but the high interrupt counts seem a little weird
> given the load of your system.
>
> jesse
>
> -----Original Message-----
> From: Jeremy M. Guthrie [mailto:jeremy.guthrie@berbee.com]
> Sent: Wednesday, January 12, 2005 2:31 PM
> To: netdev@oss.sgi.com
> Cc: Robert Olsson; Stephen Hemminger; Brandeburg, Jesse
> Subject: Re: V2.4 policy router operates faster/better than V2.6
>
> On Wednesday 12 January 2005 04:22 pm, Robert Olsson wrote:
> > Jeremy M. Guthrie writes:
> >  > I am now getting some push back from the project manager on this
> >  > performance problem.  I am wondering if you think faster CPUs will
> >  > a)  help relieve the symptoms of this problem
> >  > b)  not help because now we will hit a '# of routes in the
>
> route-cache'
>
> >  > problem
> >  > c)  or will help to a point till the # interrupts come back and
>
> bite us.
>
> >  Back out the patch I sent.and have hardirq's to run RX-softirq as you
> >  did before but something is very wrong. You didn't answer if there
>
> were
>
> >  other load on the machine...
>
> I have backed out.  As for the load, this box only does policy routing.
> Any
> other functions it performs are part of its automated system to download
> the
> next days policy-routing config.
>
> >  route-cache can probably be tuned you as have four times the linear
>
> seach
>
> >  I see in one PIII system at 110 kpps w. production traffic.
>
> How would I go about tuning that?
>
> >  Of course the non-engineering solution is to buy more CPU... :-)
>
> That is good to know.  This will help me calm the situation a bit.  8)

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart12160972.rPvSlENFIn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5vx7qtjaBHGZBeURAqarAJ9Cto6GThe8p6MhawcL3K15MHeELQCfcZRy
aL44Q235173XOvocmAQT/00=
=vgBG
-----END PGP SIGNATURE-----

--nextPart12160972.rPvSlENFIn--
