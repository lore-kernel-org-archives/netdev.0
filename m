From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 09:26:50 -0600
Message-ID: <200501060926.54588.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501051325.40616.jeremy.guthrie@berbee.com> <16860.19615.251360.169722@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1559170.S0gtjA0Rb7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16860.19615.251360.169722@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1559170.S0gtjA0Rb7
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 05 January 2005 02:22 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > After smp_affinity adjustments and turning off IRQ balancing.
>  >
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >
>  >           RX packets:537271635 errors:2377048 dropped:2377048
>  > overruns:1849169
>
>  Worse?
>
>  Yes. I'll remember Hararld moved rt_cache_stat /proc/net/stats/ and wrote
> a new utility for it. Should be in iproute2 package.  Stephen knows the
> details. Otherwise change path in rtstat. You need this to relate and
> verify the load.
I still don't see the rt_cache_stat file even under 2.4.28 stock.  See belo=
w.

>  Check throughtput and how packet load is used with 2.4.
> /proc/net/softnet_stat and rtstat. Also meditate how the comparison can be
> fair wrt taffic patterns. Do smame with 2.6.
wc -l /proc/net/rt_cache
Segmentation fault
cat /proc/net/rt_cache > /tmp/rt_cache ; wc -l /tmp/rt_cache
cat: write error: Bad address
57664 /tmp/rt_cache

ls -la /proc/net/
total 0
dr-xr-xr-x   6 root root 0 Jan  6 09:22 .
dr-xr-xr-x  55 root root 0 Jan  5 15:23 ..
=2Dr--r--r--   1 root root 0 Jan  6 09:22 arp
dr-xr-xr-x   2 root root 0 Jan  6 09:22 atm
=2Dr--r--r--   1 root root 0 Jan  6 09:22 dev
=2Dr--r--r--   1 root root 0 Jan  6 09:22 dev_mcast
dr-xr-xr-x   2 root root 0 Jan  6 09:22 drivers
=2Dr--r--r--   1 root root 0 Jan  6 09:22 igmp
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_mr_cache
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_mr_vif
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_queue
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_tables_matches
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_tables_names
=2Dr--r--r--   1 root root 0 Jan  6 09:22 ip_tables_targets
=2Dr--r--r--   1 root root 0 Jan  6 09:22 mcfilter
=2Dr--r--r--   1 root root 0 Jan  6 09:22 netlink
=2Dr--r--r--   1 root root 0 Jan  6 09:22 netstat
=2Dr--r--r--   1 root root 0 Jan  6 09:22 pnp
=2Dr--r--r--   1 root root 0 Jan  6 09:22 psched
=2Dr--r--r--   1 root root 0 Jan  6 09:22 raw
=2Dr--r--r--   1 root root 0 Jan  6 09:22 route
dr-xr-xr-x   2 root root 0 Jan  6 09:22 rpc
=2Dr--r--r--   1 root root 0 Jan  6 09:22 rt_acct
=2Dr--r--r--   1 root root 0 Jan  6 09:22 rt_cache
=2Dr--r--r--   1 root root 0 Jan  6 09:22 snmp
=2Dr--r--r--   1 root root 0 Jan  6 09:22 sockstat
=2Dr--r--r--   1 root root 0 Jan  6 09:22 softnet_stat
dr-xr-xr-x   2 root root 0 Jan  6 09:22 stat
=2Dr--r--r--   1 root root 0 Jan  6 09:22 tcp
=2Dr--r--r--   1 root root 0 Jan  6 09:22 udp
=2Dr--r--r--   1 root root 0 Jan  6 09:22 unix
=2Dr--r--r--   1 root root 0 Jan  6 09:22 wireless
ls -la /proc/net/stat/
total 0
dr-xr-xr-x  2 root root 0 Jan  6 09:22 .
dr-xr-xr-x  6 root root 0 Jan  6 09:22 ..
=2Dr--r--r--  1 root root 0 Jan  6 09:22 arp_cache
=2Dr--r--r--  1 root root 0 Jan  6 09:22 clip_arp_cache
=2Dr--r--r--  1 root root 0 Jan  6 09:22 rt_cache
cat /proc/net/softnet_stat
96deb140 0032844e 00012bbb 00000fd8 00000000 00000000 00000000 00000000=20
00000dd4
00013dda 00000000 00000000 00000000 00000000 00000000 00000000 00000000=20
0000041f
cat /proc/interrupts
           CPU0       CPU1
  0:     821852    5664906    IO-APIC-edge  timer
  1:        484       1247    IO-APIC-edge  keyboard
  8:          0          2    IO-APIC-edge  rtc
 14:          5         16    IO-APIC-edge  ide0
 18: 1928608529       1374   IO-APIC-level  eth3
 20:          1  226113098   IO-APIC-level  eth2
 27:       7950      34312   IO-APIC-level  eth0
 28:       2718       8097   IO-APIC-level  aic7xxx
 30:          0          0   IO-APIC-level  acpi
NMI:          0          0
LOC:    6487240    6487239
ERR:          0
MIS:          0


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1559170.S0gtjA0Rb7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3Vi+qtjaBHGZBeURAt66AJwM0xWjzgxb+u3M/UlpHFEWhMH0VgCfXpXz
DJFwD5QWmhr9IfBJzDX98a0=
=hXMn
-----END PGP SIGNATURE-----

--nextPart1559170.S0gtjA0Rb7--
