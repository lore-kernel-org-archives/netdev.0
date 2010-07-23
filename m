From: Stuart Sheldon <stu@actusa.net>
Subject: Re: IPv6 Anycast?
Date: Fri, 23 Jul 2010 08:12:35 -0700
Message-ID: <4C49B163.8090400@actusa.net>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se> <4C491AD4.9070103@actusa.net> <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stuart Sheldon <stu@actusa.net>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:54475 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab0GWPMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 11:12:42 -0400
In-Reply-To: <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Mikael,

Thanks for stepping up and helping me with this... I am aware of the
method of using the loopback adapter. This method is suggested when
doing things like DNS in a Anycast setup, and also works well with IPv4.
Here is a more detailed explanation of what I'm trying to make work...
If this is better addressed by another kernel group, please let me know,
as I'm unsure where this should be directed.

Currently, when you enable IPv6 forwarding on Linux, Linux automatically
creates an Anycast address for each interface. Here is an example:

cat /proc/net/anycast6
<empty_file>

echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

cat /proc/net/anycast6
1    lo              00000000000000000000000000000001     1
2    eth0            2607ff38000000000000000000000000     1
2    eth0            fe800000000000000000000000000000     1
3    eth1            fe800000000000000000000000000000     1
3    eth1            2607ff38000000010000000000000000     1
4    eth2            fe800000000000000000000000000000     1
5    eth3            2607ff38000000020000000000000000     1
5    eth3            fe800000000000000000000000000000     1
6    eth4            fe800000000000000000000000000000     1

If you ping one of these auto configured Anycast addresses, let's say
eth0's 2607:ff38:: from another host on the eth0 network, you will get a
reply from the Linux route box. This allows you to set the default route
of that host to the Anycast address 2607:ff38:: and if you have multiple
routers on that LAN, it will add the one that responds first to it's
neighbor table. This way if one goes down, the host will automatically
swing over to another router (once the neighbor cache expires)...

Anycast addresses are addresses that are never used as a source address,
and are exempt from duplicate address detection (as per RFC 3513).

It would appear that the Linux kernel is automatically implementing the
reserved Anycast address referenced in RFC 2526. This would be cool,
except for a few things. what if you don't want the router to act as an
Anycast router on a particular network? How do you remove an Anycast
address? And, what if you want to use another address that isn't the
reserved address as your Anycast router address? How do you add / change
an Anycast address? The RFC regarding Anycast addresses is very clear
that it and be ANY unicast address.

What I'm looking for is an answer to how I can add/remove/change these
Anycast addresses.

Again, if I'm asking the wrong list, please point me in the right direction.

Thanks again!

Stu Sheldon
ACT USA




Mikael Abrahamsson wrote:
> On Thu, 22 Jul 2010, Stuart Sheldon wrote:
> 
>> Yea, I'm sure...
>>
>> We use Linux for routers as well as servers and workstations. Since I
>> sent this I've discovered that by default, when a Linux system has IPv6
>> forwarding turned on, it adds the <network>::/64 anycast router
>> addresses on all the interfaces (as per rfc 2526).
>>
>> What I'm actually looking to do is (change / add) other addresses the to
>> anycast6 list to work in an existing configuration that does not use the
>> rfc 2526 anycast router address.
>>
>> Is there a command line method of setting up these anycast addresses?
> 
> In routers, this is done by adding the IP address to a loopback
> interface and announcing the address using a routing protocol, I don't
> see why this can't be done on a linux box?
> 


- --
And you run and you run to catch up with the sun, but its sinking
And racing around to come up behind you again
The sun is the same in the relative way, but youre older
Shorter of breath and one day closer to death
               -- Pink Floyd - "Time Lyrics"
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAEBCAAGBQJMSbFfAAoJEFKVLITDJSGSmcYP/jdhuORDnqIY9+Z9tyKxgeIo
pC5I4PsIGM4ZQkHitkCnouB8Q42Ac9JDpip8wf3ViMm+yW5MC9wkEpWQHrFeHv8N
jO8AaJVG7BtP8bUUTRDYiEO+5A/U6ls6kf3bVAAvBMTNHVeiEtXY0Lqf1I9gA0gI
tB0Ozzsp38uJ0vAeIM7b30lM24+kwqAGWILf3+zNm/sHz+M2KXUJYZs0qen/fKYd
kJu35Rdj3fpg47Gz2QQwftVfE5MI7SnQ+BhxnSCriLEkLe5tGWOEFvt15VsLmWM+
akrJI/JJlm+vIyfMgSZU7BPoJQrQ2XCFf4XEyA8kiSHYNUHoReKzgPdft747Vfo9
ZTy8QhJURp/PNNoDYsPa98Y9A0eFUQh/9t4QHz+UcdgO9cC9hjGi/C5bWfAjnAwl
0lCTffYww9MdyoRTQypVs02+iypCLODFZvyf2pblXluciBiv3u+8vKdVEfidy6FM
QEfb02d8h2SUS3QKUdGDWwlS9FUU+MXDE6tGSwyxfKsne/rXkk5TvTKPie+wGKVu
X0308iA0F2sUZ71t8PGVgVsIbnda00e+8M+a89E1UPHAHe6XW2WvY3/3QOZo6FRD
yCcHhl0JaM5NBrMHQJElW2eEKLOZd1ITal2ZhXPNw2JvBM3cb4QnuSxZuhJ6jA9u
hy8zTkXmmVBJKNOqXsZZ
=fE94
-----END PGP SIGNATURE-----
