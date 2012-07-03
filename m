From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Deleting an alias causes rest to get deleted
Date: Tue, 3 Jul 2012 09:34:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207030924300.1622@ja.ssi.bg>
References: <4FF1FC74.8080401@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1752084190-1341297295=:1622"
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Volkan_Yaz=C4=B1c=C4=B1?= <volkan.yazici@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46215 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932672Ab2GCG2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 02:28:38 -0400
In-Reply-To: <4FF1FC74.8080401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1752084190-1341297295=:1622
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Mon, 2 Jul 2012, Volkan Yazıcı wrote:

> Hi!
> 
> I observe an IP aliasing anomaly that occurs when I try to delete an IP alias
> from an interface. That is, when I delete the first address in a set of IP
> aliased addresses assigned according to a particular subnet, rest of the
> aliases get deleted as well. Check out the below snippet.

	This is in Linux may be from the 2.3/2.4 times

> 
>    $ *for I in `seq 1 6`; do sudo ip addr add 192.168.2.$I/29 dev eth0;
>    done*
>    $ ip addr list
>    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>         link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>         inet 127.0.0.1/8 scope host lo
>         inet6 ::1/128 scope host
>            valid_lft forever preferred_lft forever
>    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
>    state UP qlen 1000
>         link/ether 00:24:54:b9:1c:f8 brd ff:ff:ff:ff:ff:ff
>    *inet 192.168.1.200/24 brd 192.168.1.255 scope global eth0**
>         inet 192.168.2.1/29 scope global eth0
>         inet 192.168.2.2/29 scope global secondary eth0
>         inet 192.168.2.3/29 scope global secondary eth0
>         inet 192.168.2.4/29 scope global secondary eth0
>         inet 192.168.2.5/29 scope global secondary eth0
>         inet 192.168.2.6/29 scope global secondary eth0*
>         inet6 fe80::224:54ff:feb9:1cf8/64 scope link
>            valid_lft forever preferred_lft forever
>    3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>         link/ether e8:39:df:6a:21:2a brd ff:ff:ff:ff:ff:ff
>    $ *sudo ip addr del 192.168.2.1/29 dev eth0*
>    $ ip addr list
>    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>         link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>         inet 127.0.0.1/8 scope host lo
>         inet6 ::1/128 scope host
>            valid_lft forever preferred_lft forever
>    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
>    state UP qlen 1000
>         link/ether 00:24:54:b9:1c:f8 brd ff:ff:ff:ff:ff:ff
>    *inet 192.168.1.200/24 brd 192.168.1.255 scope global eth0*
>         inet6 fe80::224:54ff:feb9:1cf8/64 scope link
>            valid_lft forever preferred_lft forever
>    3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>         link/ether e8:39:df:6a:21:2a brd ff:ff:ff:ff:ff:ff
> 
> Per see, deleting 192.168.2.1/29 causes the rest of the aliased interfaces get
> deleted as well. This is something that is slightly documented in the ifconfig
> manual: /for every scope (i.e. same net with address/netmask combination) all
> aliases are deleted, if you delete the first (primary)/. So what is the right
> way of just deleting the first (primary) alias without affecting the rest? If
> this is a scoping issue, is it possible to assign each alias as primary within
> its own dedicated scope?

	There is (yet) undocumented feature for the
interfaces:

/proc/sys/net/ipv4/conf/*/promote_secondaries

	You set it for specific interface _or_ for "all".
It defaults to 0. When you enable it, deleting a primary
address will not delete all secondary addresses but will
change the next secondary as primary. The term alias may
refer for addresses on same interface while here the
problem is for a subset of addresses - from same subnet.
Primary is the first address added for the configured
subnet, all next addresses in subnet are added as
secondaries as shown by ip addr list.

> As a side note, when I first asked this question to Stephen Hemminger (he
> forwarded me to this mailing list) he also told me that "/In Linux the
> interface aliases are really a legacy from the BSD style addressing, and don't
> act the same. It is not common practice to use them./" Is that really the
> case? Because, as you know, IP aliasing is the heart of a majority of the
> high-availability and clustering solutions in Linux. Is IP aliasing a really
> deprecated technology in Linux? Should we avoid using it? If so, what do you
> recommend as an alternative?

	Please do not stop using aliases!

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1752084190-1341297295=:1622--
