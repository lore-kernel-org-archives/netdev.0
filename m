From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: How device could assemble qdisc for self?
Date: Wed, 16 Jun 2004 23:57:41 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406162357.49366.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,
I am a bit confused looking at qdisc related stuff. Could someone please point 
me to right documentation, code to look for etc?

I'd like to employ NIC with many Tx DMA queues, designated for different types 
of traffic. Jamal pointed to qdiscs as a way to do it.

My current idea is as following:

I need to arrange the following qdisc structure:

- - total 6 queues (FIFO) maintained;

- - 4 queues get packets accordingly to 802.1D priority tags (some simple fixed 
mapping, actually those described in TGe - standard for wireless QoS)
Table follows, but really it does not matter.

802.1D   queue(access category)
1        AC_BK     Background
2        AC_BK   
0        AC_BE     Best effort
3        AC_BE
4        AC_VI     Video
5        AC_VI
6        AC_VO     Voice
7        AC_VO

- - 1 queue used for all bcast/mcast packets (wireless AP need it)

- - 1 queue used for packets marked by application in some specific way (don't 
know how exactly, long story, next time)

Each queue corresponds to one tx DMA queue within NIC. Each one should be 
stopped/started separately. Then, in hard_start_xmit, I will select proper 
DMA queue based on skb->priority. When DMA queue is full, I will stop 
corresponding qdisc.

Does this structure make sense? Could it be done easier?

Vladimir
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA0LRNqxdj7mhC6o0RAvaMAJ4kr7le3zZQbspb5biMsexbJSi/HwCgiwyJ
gDn2m3VujWZuoGgOhWClwhI=
=ygYp
-----END PGP SIGNATURE-----
