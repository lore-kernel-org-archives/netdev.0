From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 13:28:29 -0600
Message-ID: <200501131328.34449.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121723.21969.jeremy.guthrie@berbee.com> <16870.14259.701771.389978@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2668695.7sWysN36Or";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16870.14259.701771.389978@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2668695.7sWysN36Or
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I after a few revs I just bumped rhash_entries to 2.4mil in an attempt to g=
et=20
well above my actual usage.=20

You can see below I am over 600K entries before it blows them away and=20
restarts.  How do I bump up the time from 10 minutes to something longer? =
=20
With the way our system works, entries should be good for a day as we won't=
=20
reprogram the policy route table but once a day.

I still have some instrumented network card drivers to work with but I now=
=20
show some 30-40% idle CPU on CPU0 but still with 0.3% packet loss.  I'll po=
st=20
stats once I get the instrumented drivers in.

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc=20
GC: tot ignored goal_miss ovrf HASH: in_search out_search
611167     98712     645     0     0     0     0     0        30       0=20
1074229262     645     643         0    0           61922         17
611461     96203     591     0     0     0     1     0        42       1=20
3220738034     592     590         0    0           63160         14
611759     93852     592     0     0     0     0     0        18       0   =
  =20
0     591     589         0    0           63078          6
612094     95276     632     0     0     0     0     0        28       0   =
  =20
0     632     630         0    0           63336          8
612368     94945     580     0     0     0     0     0        22       0   =
  =20
0     578     576         0    0           61224         18
612670     99258     622     0     0     0     0     0        28       0   =
  =20
0     621     619         0    0           63922          8
613025     93573     666     0     0     0     0     0        16       0   =
  =20
0     665     663         0    0           61781          6
613394     83917     722     0     0     0     0     0         8       0   =
  =20
0     721     719         0    0           55533         10
613697     85851     634     0     0     0     0     0        10       0   =
  =20
0     633     631         0    0           56394         12
613986     81854     611     0     0     0     0     0         8       0   =
  =20
0     610     608         0    0           54273          8
614349     81419     704     0     0     0     0     0         4       0   =
  =20
0     702     700         0    0           52641          8
614651     83312     616     0     0     0     0     0        14       0   =
  =20
0     617     615         0    0           54160         12
614962     83119     651     0     0     0     0     0         6       0   =
  =20
0     651     649         0    0           56612          4
615264     84871     583     0     0     0     0     0        10       0   =
  =20
0     583     581         0    0           56130         12
615521     83932     557     0     0     0     0     0         8       0   =
  =20
0     557     555         0    0           56229         10
615852     86368     626     0     0     0     0     0         8       0   =
  =20
0     624     622         0    0           56504         10
493558     47553    4603     0     0     0     0     0         2       0   =
  =20
0    4166    4164         0    0           28346          0
10091     46526    7096     0     0     0     0     0         2       3    =
  0      =20
0       0         0    0             554          0
16238     80565    6145     0     0     0     0     0         6       3    =
  0      =20
0       0         0    0            1334          0
21754     81224    5515     0     0     0     0     0         6       2    =
  0      =20
0       0         0    0            1793          0
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot    =
 mc=20
GC: tot ignored goal_miss ovrf HASH: in_search out_search
26737     80792    4982     0     0     0     0     0         5       2=20
1074229262       0       0         0    0            2669          0
31085     82895    4347     0     0     0     0     0         5       1=20
3220738034       0       0         0    0            2397          0
35333     83220    4248     0     0     0     0     0         1       1    =
  0      =20
0       0         0    0            2754          0
39053     83910    3720     0     0     0     0     0         7       1    =
  0      =20
0       0         0    0            3328          0
42692     82373    3634     0     0     0     0     0         8       6    =
  0      =20
0       0         0    0            3485          3
46404     84900    3707     0     0     0     0     0        15       7    =
  0      =20
0       0         0    0            3889          1


On Thursday 13 January 2005 02:56 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  As your traffic looks sane double your bucket size of the route hash
>  > > to start with. Use the boot option w. rhash_entries. look at rtstat
>  >
>  > Does it make sense that the driver would kill throughput and force us =
to
>  > output these types of messages?
>
>  No the other way around... Higher (driver/cpu) throughput/load causes mo=
re
>  dst-entries to freed and you reach the max_size*ip_rt_gc_min_interval
> which is a constant and get "dst cache overflow".
>
>  Increasing  rhash_entries is the easieast way to attack this.. Give this
>  a try. Monitor with rtstat. You might even have to quadruple your size.
>
>       --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2668695.7sWysN36Or
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5sviqtjaBHGZBeURAkUqAJ4oKcrGq3qtLSJHT0vJZG5Zk8o0DgCffgee
z8UBMfM4V3ifgUym8XNgmY4=
=Jhh0
-----END PGP SIGNATURE-----

--nextPart2668695.7sWysN36Or--
