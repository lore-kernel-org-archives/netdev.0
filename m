From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Thu, 13 Mar 2008 23:21:19 +0100
Message-ID: <47D9A8DF.30809@fr.ibm.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org> <47D98510.60801@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:17352 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbYCMWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 18:23:21 -0400
In-Reply-To: <47D98510.60801@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tilman Schmidt wrote:
> Am 11.03.2008 09:14 schrieb Andrew Morton:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25=
-rc5/2.6.25-rc5-mm1/
>=20
> I'm noticing a strange effect with this:
>=20
> On my openSUSE 10.3 development machine with SUSEs default MTA
> Postfix installed, I occasionally send a pre-formatted mail by
> feeding it directly into "/usr/sbin/sendmail -t". If I try that
> while running a 2.6.25-rc5-mm1 kernel, I get:
>=20
> ts@xenon:~/kernel> /usr/sbin/sendmail -t < patch-usb-reduce-syslog-cl=
utter-v3
> postdrop: warning: can't open /proc/net/if_inet6 (Permission denied) =
- skipping IPv6 configuration
> postdrop: fatal: parameter inet_interfaces: no local interface found =
for ::1
> sendmail: warning: command "/usr/sbin/postdrop -r" exited with status=
 1
> sendmail: fatal: ts(1000): unable to execute /usr/sbin/postdrop -r: S=
uccess
> ts@xenon:~/kernel>
>=20
> and unsurprisingly, the mail is not sent. If I do the same as root,
> everything works as usual, there is no console output from the
> sendmail command, and the mail goes out as it should. All other
> networking applications appear to be running normally.
>=20
> On a 2.6.25-rc5 (non-mm) kernel I do not need to run the sendmail
> command as root. It works just as well if I run it as myself.
>=20
> IPv6 is not in use on that machine. The Ethernet interface has
> just the link local IPv6 address. Possibly relevant information:
>=20
> ts@xenon:~> /sbin/ifconfig -a
> eth0      Protokoll:Ethernet  Hardware Adresse 00:19:D1:03:D8:FF
>           inet Adresse:192.168.59.102  Bcast:192.168.59.255  Maske:25=
5.255.255.0
>           inet6 Adresse: fe80::219:d1ff:fe03:d8ff/64 G=FCltigkeitsber=
eich:Verbindung
>           UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric=
:1
>           RX packets:78 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:145 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 Sendewarteschlangenl=E4nge:100
>           RX bytes:9547 (9.3 Kb)  TX bytes:17952 (17.5 Kb)
>           Speicher:92c00000-92c20000
>=20
> lo        Protokoll:Lokale Schleife
>           inet Adresse:127.0.0.1  Maske:255.0.0.0
>           inet6 Adresse: ::1/128 G=FCltigkeitsbereich:Maschine
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:2 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 Sendewarteschlangenl=E4nge:0
>           RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)
>=20
> ts@xenon:~/kernel> ls -l /proc/net/if_inet6
> -r--r--r-- 1 root root 0 13. M=E4r 19:26 /proc/net/if_inet6
> ts@xenon:~> cat /proc/net/if_inet6
> fe800000000000000219d1fffe03d8ff 02 40 20 80     eth0
> 00000000000000000000000000000001 01 80 10 80       lo
> ts@xenon:~> uname -a
> Linux xenon 2.6.25-rc5-mm1-testing #1 SMP PREEMPT Tue Mar 11 14:34:49=
 CET 2008 i686 i686 i386 GNU/Linux
>=20
> As you see, I can cat /proc/net/if_inet6 as regular (non-root) user
> just fine, even though Postfix complains it cannot access it.
> The content of /proc/net/if_inet6 is identical if I cat it on
> kernel 2.6.25-rc5 mainline.
>=20
> CCing a selection of IPv6 networking related maintainer addresses.
> If you need more information or want me to test something, let me
> know.

Hi Tilman,

Is it possible to have your config file used to compile the kernel ?
