From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 09:18:19 -0600
Message-ID: <200501050918.22472.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501031656.57041.jeremy.guthrie@berbee.com> <16859.59675.522262.418329@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3761034.eMIVnrcmVK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16859.59675.522262.418329@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart3761034.eMIVnrcmVK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 05 January 2005 07:18 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > How would I check?  It should be in the hundreds of thousands.
>
>  Good question  Stephen,..
>
>  Yes it seems like this pretty hefty load. Forwarding rate of 92k kpps
>  and a drop rate of 10 kpps and dst hash mostly at 50-60 kentries if
>  I read the stats correctly.
Yeah, the load will be high.  I'm expecting this to be watching ~ 750 mbps =
by=20
next December.  The app profiles all traffic going in and out of our data=20
centers.

>  And 2.4 were able handle this but not 2.6.10?
Yes.  It does handle it.  It runs harder ie. 2.6 caps out at ~ 50% utilizat=
ion=20
where 2.4 might run 60-75% utilized.

>  Assuming things are uses and setup identically. 2.6 uses RCU for route
> hash locking. Any dst cache overslow messages seen?
No.

>  A couple of lines of rtstat would be very interesing from this box.
I'm not showing the /proc/net/rt_cache_stat file.  Was there a kernel optio=
n I=20
need to recompile with for rt_cache_stat to show up in proc?

>  Also check that the CPU shares the RX packet load. CPU0 affinty to eth0
>  and CPU1 to eth1 seems to be best. It gives cache bouncing at "TX" and
>  slab jobs but we have accept that for now.
How would I go about doing this?

>  13:37:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle
>
> > intr/s
> > 13:38:24     all    0.14    0.00    0.12    0.12    2.02   42.89   54.71
> > 25900.70
> > 13:38:24       0    0.03    0.00    0.05    0.22    0.00   16.67   83.03
> > 2246.10
> > 13:38:24       1    0.25    0.00    0.20    0.03    4.02   69.12   26.40
> > 23654.55
>
> This looks weird to me... we cannot have CPU left? Due to the imbalance?

> Check /proc/net/softnet_stat,
cat /proc/net/softnet_stat
5592c972 00000000 00001fc8 00000000 00000000 00000000 00000000 00000000=20
00391c3f
000f1991 00000000 00000000 00000000 00000000 00000000 00000000 00000000=20
001292ba


> Haven't used mpstat. %soft is that *all* softirq's or only softirq's
> deferred to ksoftird only?
"%soft"
Show  the percentage of time spent by the CPU or CPUs to service           =
   =20
softirqs.  A softirq (software interrupt) is one  of  up  to  32           =
   =20
enumerated software interrupts which can run on multiple CPUs at           =
   =20
once.


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart3761034.eMIVnrcmVK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3AU+qtjaBHGZBeURAieyAJ9rfhGwR6xUQ7nG20+7sD80au3vSwCaA3Vm
vQkUCdaU2ctd5k52Bjow/X0=
=azzl
-----END PGP SIGNATURE-----

--nextPart3761034.eMIVnrcmVK--
