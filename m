From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: AW: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Mon, 11 Feb 2008 15:26:44 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F0C@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:26556 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751322AbYBKO1Z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 09:27:25 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall=
 8.0, Stand G16
_______________________________________________________________________=
_


Hi David,

thanks for your help. Your input is always welcome ;-)

But according to Linux Programmer's Manual it should be OK to use ifind=
ex of 0
e.g. (http://www.rt.com/man/ip.4.html)
but maybe this document is depcecated/obsolte ...

Well anyway, i did what u suggested, used eth0.3 as interface (i'm usin=
g VLAN)
Setting ifindex to eth0 won't help .. strange, but well ...,=20
maybe receiving is blocked by the virtual interface somehow, should be.


The problem is, now i get unreliable results.

At first attempt, it always worked as before with ifindex=3D0, but now =
further attempts SOMETIMES works !!!
Every 3rd or forth attempt i can receive the packets. (this way maybe t=
he same with old method, i'll investigate further)

But netstat always shows the join (and the absence, if i close socket/l=
eave mc-group)

IPv6/IPv4 Group Memberships
Interface       RefCnt Group
--------------- ------ ---------------------
lo              1      224.0.0.1
eth0            1      224.0.0.1
eth0.3          1      224.1.9.0
eth0.3          1      224.0.0.1

Do u know a way to debug this further ?

It's not so easy for me to build a small app to show the faulty behav, =
but i'll try.

Robert


-----Urspr=FCngliche Nachricht-----
Von: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]Im Auftrag von David Stevens
Gesendet: Donnerstag, 07. Februar 2008 17:09
An: Reither Robert
Cc: netdev@vger.kernel.org
Betreff: Re: Problem receiving multicast/promiscuous-mode with
kernel.2.6.24


You need to join the multicast group on the interface you want
to receive it. If you're setting both imr_address and imr_index
to 0, you haven't specified an interface.

Instead of setting imr_ifindex to 0, try setting it like this:

imr.imr_ifindex =3D if_nametoindex("eth0");

 (or whatever interface you need).

You can verify that you've joined the group on the correct
interface with "netstat -g", also. Make sure that the interface
field is correct for the group you want.

And because I can't resist mentioning it, "inet_aton" is deprecated--
suggest inet_pton() with appropriate arguments and return value
checking instead.

There was a bug fix where the sense of promiscuous mode was
backwards for multicasting, which is probably why it was accidently
(and incorrectly) working in earlier kernels.

If that doesn't do it for you, let me know; better if you can post the
full code (or even better, the smallest subset that demonstrates the
problem).

                                                +-DLS

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
