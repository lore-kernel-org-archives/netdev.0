From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Mon, 10 Jan 2005 15:11:02 -0600
Message-ID: <200501101511.07164.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071501510.5818-100000@localhost.localdomain>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3504373.GH3shJKScU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>, Robert.Olsson@data.slu.se,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0501071501510.5818-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart3504373.GH3shJKScU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I rebound the card with 2048 RxDescriptors.  There appears to be a burst=20
errors right when the port comes online.  Down below is an ifconfig ; sleep=
=20
60 ; ifconfig.

I'll be tesitng Robert's patch shortly.

ethtool -S eth2
NIC statistics:
     rx_packets: 0
     tx_packets: 7295976
     rx_bytes: 0
     tx_bytes: 3413882143
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
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
     rx_long_byte_count: 0
     rx_csum_offload_good: 0
     rx_csum_offload_errors: 0

ethtool -S eth3
NIC statistics:
     rx_packets: 19231078
     tx_packets: 5
     rx_bytes: 1350479823
     tx_bytes: 398
     rx_errors: 522159
     tx_errors: 0
     rx_dropped: 320198
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 201961
     rx_missed_errors: 201961
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
     rx_long_byte_count: 9940414415
     rx_csum_offload_good: 17879204
     rx_csum_offload_errors: 8537

Mon Jan 10 15:06:26 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
          inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:67183383 errors:583215 dropped:583215 overruns:247258=
=20
frame:0
          TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1120957705 (1069.0 Mb)  TX bytes:398 (398.0 b)
          Base address:0x22a0 Memory:eff80000-effa0000

Mon Jan 10 15:07:26 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
          inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:73275567 errors:616520 dropped:616520 overruns:262517=
=20
frame:0
          TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:337437991 (321.8 Mb)  TX bytes:398 (398.0 b)
          Base address:0x22a0 Memory:eff80000-effa0000


On Friday 07 January 2005 05:23 pm, Jesse Brandeburg wrote:
> On Fri, 7 Jan 2005, Jeremy M. Guthrie wrote:
> > > Very interesting that with your workload the napi driver doesn't keep
> > > up (from looking at your posts in netdev) and yet the interrupt mode
> > > driver can.
> >
> > Well, I need to do more digging.   One scenario the interrupt mode can
> > hand stuff off to the CPU but the network stack still drops.  The other
> > scenario, the card drops.
> >
> > ethtool -S eth2
> > NIC statistics:
>
> <snip!>
>
> >      tx_packets: 314550698
> >      tx_bytes: 4290523139
> > ethtool -S eth3
> > NIC statistics:
>
> <snip!>
>
> >      rx_packets: 719847127
> >      tx_packets: 5
> >      rx_bytes: 1880301945
> >      tx_bytes: 398
> >      rx_errors: 3368295
> >      rx_dropped: 1478044
> >      rx_fifo_errors: 1890251
> >      rx_missed_errors: 1890251
> >      rx_long_byte_count: 379837423993
> >      rx_csum_offload_good: 672891990
> >      rx_csum_offload_errors: 178666
>
> Okay, well, rx_dropped means "receive no buffers count" in our driver, but
> doesn't necessarily mean that the packet was completely dropped it just
> means that the fifo may have had to queue up the packet on the adapter as
> best it could and wait for the OS to provide more skb's, this may or may
> not lead to further errors...
>
> Now, the rx_fifo errors is from hardware counter "missed packet count"
> which means that a packet was dropped because the fifo was full (probably
> indicated at least some of the time because the card was in "receive no
> buffers" state) btw fifo errors and rx_missed are both being fed by the
> same hardware counter.
>
> rx_csum_offload_errors is somewhat worrisome because it means that you're
> receiving packets that appear to be corrupted.  This could be from any
> number of sources, but is most likely a misconfigured station on your lan
> or something is corrupting checksums (a tcpdump would help debug here, but
> would really slow things down)  The packets are NOT dropped, but handed to
> the stack to decide what to do.
>
> So, to mitigate the rnbc "receive no buffers count" a little you can
> provide some more buffering on the receive side by loading the module with
> RxDescriptors=3D2048 or something larger than the default of 256.  this w=
ill
> help (if you haven't already) but will also probably increase the amount
> of work your system has to do, as more packets will be able to be stored
> up.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart3504373.GH3shJKScU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB4u9rqtjaBHGZBeURAv0yAJ9c7cSKfASuSPohBZa3oQULETdLuwCfWcLa
9M0cO9ukxBaJo3d6vEbdAdw=
=5So+
-----END PGP SIGNATURE-----

--nextPart3504373.GH3shJKScU--
