From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 10:24:59 -0600
Message-ID: <200501121025.03899.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501111927.15574.jeremy.guthrie@berbee.com> <16869.15931.324875.264756@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9616339.dZIAtcjDUb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.15931.324875.264756@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart9616339.dZIAtcjDUb
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 12 January 2005 09:11 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > > Did the e1000 patch cure the problem that interrupts got enabled for
>  > > unidirectional traffic? Ring size? I've never seen any win in system
>  > > performance w. RX rings larger than 256 at least not in lab.
>  >
>  > ETH3 Interrupts(calc'd from below):  1479968
>  > ETH2 Interrupts:  261543
>  > Packets RX'd on ETH3:  3892720
>  > Packets dropped on RX on ETH3:  10305
>
>  Very strange...
>
>  eth3 is bound to CPU0 which in turn has all packet load... If we were
>  to believe your CPU0 was saturated (due to the drops). We should see no
>  (RX) interrupts on eth3. But there is a lot... one irq per every three
>  packet. Why?
I have no idea why it would be doing this.

>  Can you investigate? e1000 has problem like this w. unidirectional traff=
ic
>  w/o the patch I sent.
This appears to be where this problem is getting beyond my expertise.  I=20
verified NAPI is turned on.  I also verified the patch is in place.  I am=20
open to suggestions but otherwise I am not the worlds best coder.=20

>  Or is your traffic so extremely bursty. No?
By the nature of our business it can be very bursty.  We just have so many=
=20
sources/destinations for traffic that our traffic is generally pretty burst=
y. =20
We might be running 300-400 mbps with spikes of 40-100 mbps.

>       --ro
>
>  > This equates to about a 0.26% drop rate. W/ 256 packet RX ring size I
>  > see about a 0.42% drop rate.
>  >
>  > This is using both the newest Intel driver w/ your patch and an
>  > increased ring size of 2048.
>  >
>  > Tue Jan 11 19:15:04 CST 2005
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255=
=2E0
>  >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>  >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>  >           RX packets:2337377824 errors:14992144 dropped:14992144
>  > overruns:9643826 frame:0
>  >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
>  >           collisions:0 txqueuelen:1000
>  >           RX bytes:3984064976 (3799.5 Mb)  TX bytes:398 (398.0 b)
>  >           Base address:0x22a0 Memory:eff80000-effa0000
>  >
>  >            CPU0       CPU1
>  >   0:   93627934  353254270    IO-APIC-edge  timer
>  >   1:         35        507    IO-APIC-edge  i8042
>  >   7:          0          0   IO-APIC-level  ohci_hcd
>  >   8:          0          2    IO-APIC-edge  rtc
>  >  12:         73        145    IO-APIC-edge  i8042
>  >  14:        120        313    IO-APIC-edge  ide0
>  >  18: 2158179576       1815   IO-APIC-level  eth3
>  >  20:          2 2136514988   IO-APIC-level  eth2
>  >  27:     204201     371301   IO-APIC-level  eth0
>  >  28:      14585      75320   IO-APIC-level  aic7xxx
>  >  30:          0          0   IO-APIC-level  acpi
>  > NMI:          0          0
>  > LOC:  446922783  446921227
>  > ERR:          0
>  > MIS:          0
>  >
>  > Tue Jan 11 19:16:05 CST 2005
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255=
=2E0
>  >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>  >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>  >           RX packets:2341270544 errors:15002449 dropped:15002449
>  > overruns:9652393 frame:0
>  >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
>  >           collisions:0 txqueuelen:1000
>  >           RX bytes:1664751812 (1587.6 Mb)  TX bytes:398 (398.0 b)
>  >           Base address:0x22a0 Memory:eff80000-effa0000
>  >
>  >            CPU0       CPU1
>  >   0:   93639955  353302319    IO-APIC-edge  timer
>  >   1:         35        507    IO-APIC-edge  i8042
>  >   7:          0          0   IO-APIC-level  ohci_hcd
>  >   8:          0          2    IO-APIC-edge  rtc
>  >  12:         73        145    IO-APIC-edge  i8042
>  >  14:        120        313    IO-APIC-edge  ide0
>  >  18: 2159659544       1815   IO-APIC-level  eth3
>  >  20:          2 2136776531   IO-APIC-level  eth2
>  >  27:     204245     371369   IO-APIC-level  eth0
>  >  28:      14593      75343   IO-APIC-level  aic7xxx
>  >  30:          0          0   IO-APIC-level  acpi
>  > NMI:          0          0
>  > LOC:  446982858  446981302
>  > ERR:          0
>  > MIS:          0

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart9616339.dZIAtcjDUb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5U9fqtjaBHGZBeURAlDZAJsESGin954USIQg7WeStvEeoFqleACgnW0g
n3EHNxl6YfkaK62IoVMu/hg=
=rvzQ
-----END PGP SIGNATURE-----

--nextPart9616339.dZIAtcjDUb--
