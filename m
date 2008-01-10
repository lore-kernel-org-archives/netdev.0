From: patnel972-linux@yahoo.fr
Subject: Re : Re : Re : Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Thu, 10 Jan 2008 23:01:13 +0000 (GMT)
Message-ID: <444507.9372.qm@web25705.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25705.mail.ukl.yahoo.com ([217.12.10.177]:46189 "HELO
	web25705.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753362AbYAJXBS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 18:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I try arp monitoring but it doesn't work! Test an ip, the interface mus=
t have an address, and the dhcpcd is launch by ifplugd if bond0 is link=
ed ... so it goes around in circles.
So i return to miimon, and i figured out that bond detect when wlan0 is=
 associated and set it active interface. But when i switch rf_kill it d=
on't react. So i try to deassociate and magic it detect interface off!!=
 I presume it is a bug of the wlan driver which not re-initialise the i=
nfo on the wlan. So i made a small script in acpi to provide that behav=
ior.



----- Message d'origine ----
De : Jay Vosburgh <fubar@us.ibm.com>
=C0 : patnel972-linux@yahoo.fr
Cc : netdev@vger.kernel.org
Envoy=E9 le : Jeudi, 10 Janvier 2008, 21h59mn 20s
Objet : Re: Re : Re : Re : Re : Bonding : Monitoring of 4965 wireless c=
ard=20

patnel972-linux@yahoo.fr wrote:

>Yes it's what i'm looking for. I don't understand how to change the
 arp_ip_target with the gateway, arp_ip_target is a module option.

    If you're running a relatively recent bonding driver (version
3.0.0 or later), the arp_ip_targets can be changed on the fly via
 sysfs,
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
>=C0 : patnel972-linux@yahoo.fr
>Cc : netdev@vger.kernel.org
>Envoy=E9 le : Jeudi, 10 Janvier 2008, 0h26mn 38s
>Objet : Re: Re : Re : Re : Bonding : Monitoring of 4965 wireless card=20
>
>patnel972-linux@yahoo.fr wrote:
>
>>I mean that instead of arp test an ip in lan or else, i want it to
> test 127.0.0.1 but in order to do this it must go out and re-enter
 and
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
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html





      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
