From: Tilman Schmidt <tilman@imap.cc>
Subject: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Thu, 13 Mar 2008 20:48:32 +0100
Message-ID: <47D98510.60801@imap.cc>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7BEB4EC2850E682582E0D096"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756646AbYCMUOb@vger.kernel.org>
In-Reply-To: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7BEB4EC2850E682582E0D096
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 11.03.2008 09:14 schrieb Andrew Morton:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25-rc=
5/2.6.25-rc5-mm1/

I'm noticing a strange effect with this:

On my openSUSE 10.3 development machine with SUSEs default MTA
Postfix installed, I occasionally send a pre-formatted mail by
feeding it directly into "/usr/sbin/sendmail -t". If I try that
while running a 2.6.25-rc5-mm1 kernel, I get:

ts@xenon:~/kernel> /usr/sbin/sendmail -t < patch-usb-reduce-syslog-clutte=
r-v3
postdrop: warning: can't open /proc/net/if_inet6 (Permission denied) - sk=
ipping IPv6 configuration
postdrop: fatal: parameter inet_interfaces: no local interface found for =
::1
sendmail: warning: command "/usr/sbin/postdrop -r" exited with status 1
sendmail: fatal: ts(1000): unable to execute /usr/sbin/postdrop -r: Succe=
ss
ts@xenon:~/kernel>

and unsurprisingly, the mail is not sent. If I do the same as root,
everything works as usual, there is no console output from the
sendmail command, and the mail goes out as it should. All other
networking applications appear to be running normally.

On a 2.6.25-rc5 (non-mm) kernel I do not need to run the sendmail
command as root. It works just as well if I run it as myself.

IPv6 is not in use on that machine. The Ethernet interface has
just the link local IPv6 address. Possibly relevant information:

ts@xenon:~> /sbin/ifconfig -a
eth0      Protokoll:Ethernet  Hardware Adresse 00:19:D1:03:D8:FF
          inet Adresse:192.168.59.102  Bcast:192.168.59.255  Maske:255.25=
5.255.0
          inet6 Adresse: fe80::219:d1ff:fe03:d8ff/64 G=FCltigkeitsbereich=
:Verbindung
          UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:78 errors:0 dropped:0 overruns:0 frame:0
          TX packets:145 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:100
          RX bytes:9547 (9.3 Kb)  TX bytes:17952 (17.5 Kb)
          Speicher:92c00000-92c20000

lo        Protokoll:Lokale Schleife
          inet Adresse:127.0.0.1  Maske:255.0.0.0
          inet6 Adresse: ::1/128 G=FCltigkeitsbereich:Maschine
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:0
          RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)

ts@xenon:~/kernel> ls -l /proc/net/if_inet6
-r--r--r-- 1 root root 0 13. M=E4r 19:26 /proc/net/if_inet6
ts@xenon:~> cat /proc/net/if_inet6
fe800000000000000219d1fffe03d8ff 02 40 20 80     eth0
00000000000000000000000000000001 01 80 10 80       lo
ts@xenon:~> uname -a
Linux xenon 2.6.25-rc5-mm1-testing #1 SMP PREEMPT Tue Mar 11 14:34:49 CET=
 2008 i686 i686 i386 GNU/Linux

As you see, I can cat /proc/net/if_inet6 as regular (non-root) user
just fine, even though Postfix complains it cannot access it.
The content of /proc/net/if_inet6 is identical if I cat it on
kernel 2.6.25-rc5 mainline.

CCing a selection of IPv6 networking related maintainer addresses.
If you need more information or want me to test something, let me
know.

HTH
T.

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig7BEB4EC2850E682582E0D096
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH2YUcMdB4Whm86/kRAo6rAJ0QvX/WAuv5XvPjBuYcbZ2bHjc+cwCeMF6H
uaawCA5cg7/YRUGCCDZJNkY=
=1Drp
-----END PGP SIGNATURE-----

--------------enig7BEB4EC2850E682582E0D096--
