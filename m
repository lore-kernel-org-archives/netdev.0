From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Re : Re : Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Thu, 10 Jan 2008 12:59:20 -0800
Message-ID: <30028.1199998760@death>
References: <722263.85774.qm@web25703.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: patnel972-linux@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:50824 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752820AbYAJU7Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 15:59:24 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0AKxMrI022371
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:59:22 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AKxM8i084642
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:59:22 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AKxLht018237
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:59:21 -0700
In-reply-to: <722263.85774.qm@web25703.mail.ukl.yahoo.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patnel972-linux@yahoo.fr wrote:

>Yes it's what i'm looking for. I don't understand how to change the ar=
p_ip_target with the gateway, arp_ip_target is a module option.

	If you're running a relatively recent bonding driver (version
3.0.0 or later), the arp_ip_targets can be changed on the fly via sysfs=
,
e.g.,

echo +10.0.0.1 > /sys/class/net/bond0/bonding/arp_ip_target
echo -20.0.0.1 > /sys/class/net/bond0/bonding/arp_ip_target

	You can check out Documentation/networking/bonding.txt (in the
kernel source code) for more details.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


>----- Message d'origine ----
>De : Jay Vosburgh <fubar@us.ibm.com>
>=C3=80 : patnel972-linux@yahoo.fr
>Cc : netdev@vger.kernel.org
>Envoy=C3=A9 le : Jeudi, 10 Janvier 2008, 0h26mn 38s
>Objet : Re: Re : Re : Re : Bonding : Monitoring of 4965 wireless card=20
>
>patnel972-linux@yahoo.fr wrote:
>
>>I mean that instead of arp test an ip in lan or else, i want it to
> test 127.0.0.1 but in order to do this it must go out and re-enter an=
d
> then use wlan0 to go out.
>
>    In other words, what I think you're saying (and I'm not entirely
>sure here) is that you want probes to go to a remote node on the
>network, and back, without having to actually know the identity of the
>remote node (because, presumably, on a roaming type of wireless
>configuration, your gateway and whatnot can change from time to time).
>
>    Is that what you're looking for?
>
>    That isn't available now, but might be straightforward to plug
>into the address update system to keep the arp_ip_target up to date as
>the current gateway as the gateway changes.  I haven't looked into the
>details of doing that, but in theory it sounds straightforward.
>
>    -J
>
>---
>    -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
