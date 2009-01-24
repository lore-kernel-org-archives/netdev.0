From: Michael Tokarev <mjt@tls.msk.ru>
Subject: IP address: property of host or interface?
Date: Sat, 24 Jan 2009 16:57:50 +0300
Message-ID: <497B1E5E.9050309@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:47341 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445AbZAXODl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jan 2009 09:03:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Long time ago there was an ifconfig command and
interface "aliases".  Now, thanks to new way of
doing things and to famous `ip' utility, we learned
that there's no such thing as INTERFACE alias and
an IP address belongs to whole interface, not to
some "alias" of it.  So far so good.

But now I'm asking if an IP really belongs to any
particular interface, instead of the whole HOST
in question.

For example, suppose we have two interfaces, eth0
and eth1, and two addresses/nets, A0/24 and A1/24,
configured.

Let's ping address A1 from segment 0: the host in
question will answer those pings, provided we've
routing on our "external" host set up to point to
A0.  The same is true when pinging A0 from segment 1.
So, it makes no difference which IP address to access,
a host will happily answer to any of them assigned to
it, *except* of 127/8 (which is a different story).
Note that this works regardless of ip_forward, because
it's not forwarding.

Now, I'm setting up the host interfaces somewhat
differently:

 ip addr add A0/32 dev lo
 ip route add A0/24 dev eth0 src A0
 ip addr add A1/32 dev lo
 ip route add A1/24 dev eth1 src A1

I.e., I'm assigning both addresses to loopback interface
and adding ROUTES to corresponding networks/interfaces.
And guess what?  This thing will work exactly the same
way as traditional setup.

In other words, I can assign all addresses that belongs
to the host to it's loopback interface, and only add
routes (which gets added automatically behind the scenes
when I configure ADDRESS with mask != 32 on a broadcast
iface) to corresponding "remote" (not belonging to the
host) addresses.

There's even more: think of peer-to-peer (not broadcast)
interfaces, such as tun or ppp.  Traditionally we used
to have "local IP" and "remote IP" or "peer IP", and
used to set up routes to that remote IP.  For example,

  ip addr add A peer R dev ppp0
  ip route add RS/M via R

but the same works without assigning any address at all
to ppp0 interface!

  ip route add R dev ppp0
  ip route add RS/M dev ppp0

(if A is not listed locally, it's possible to add it to
lo interface again).

So.. am I right that an IP address is a HOST property,
not an INTERFACE property, and that the traditional
way is just more convenient to set up?
And that all the tools that complains that "there's
no IP address assigned to this interface" (tcpdump)
are wrong? :)

Thanks!

/mjt
