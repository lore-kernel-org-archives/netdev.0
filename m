From: Rob Townley <rob.townley@gmail.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 13:35:25 -0500
Message-ID: <7e84ed60910121135j656d1d9s8d84757e7e3d0078@mail.gmail.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009210909.GA9836@auslistsprd01.us.dell.com>
	 <20091009194401.036da080@nehalam>
	 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	 <20091010052308.GA12458@kroah.com>
	 <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
	 <20091012030008.GA8436@kroah.com>
Reply-To: Rob.Townley@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f203.google.com ([209.85.212.203]:52406 "EHLO
	mail-vw0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757688AbZJLSgC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 14:36:02 -0400
In-Reply-To: <20091012030008.GA8436@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2009 at 10:00 PM, Greg KH <greg@kroah.com> wrote:
> On Sun, Oct 11, 2009 at 04:10:03PM -0500, Rob Townley wrote:
>> So when an add-in PCI NIC has a lower MAC than the motherboard NICs,
>> the add-in cards will come before the motherboard NICs. =A0 i don't =
like it.
>
> Huh? =A0Have you used the MAC persistant rules? =A0If you add a new c=
ard,
> what does it pick for it?

i have a hp-dl360 (two nics) with a fibre optic add in nic.  On a
fresh install, the add-in is eth0.  i didn't like it, but ran it for
years.

>
>> But please whatever is done, make sure ping and tracert still works =
when
>> telling it to use a ethX source interface:
>>
>> eth0 =3D 4.3.2.8, the default gateway is thru eth1.
>> ping -I eth0 208.67.222.222 =A0 =A0 =A0 =A0 =A0 =A0 =A0FAILS
>> ping -I 4.3.2.8 208.67.222.222 =A0 =A0 =A0 =A0 =A0WORKS
>> tracert -i eth0 -I 208.67.222.222 =A0 =A0 =A0 =A0FAILS
>> tracert -s 4.3.2.8 -I 208.67.222.222 =A0 WORKS
>> tracert -i eth0 208.67.222.222 =A0 =A0 =A0 =A0 =A0 FAILS
>> tracert -s 4.3.2.8 208.67.222.222 =A0 =A0 =A0WORKS
>
> Again, is what we currently have broken? =A0I am confused as to what =
this
> is referring to.

Yes, ping and traceroute are broken at least on Fedora, CentOS, and bus=
ybox.
On a multinic, multigatewayed machine, passing ethX instead of the IP
address will give the false result: "Destination Host Unreachable"
when the machine's default gateway is reached thru the other nic.   In
the following example, the default gateway is thru eth1, not eth0.
Pay attention to the text between the '*****'.

ping -c 1 -B -I  eth0 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from ***** 4.3.2.8 eth0*****:
56(84) bytes of data.
=46rom 4.3.2.8 icmp_seq=3D1 Destination Host Unreachable

#ping -c 1 -B -I  4.3.2.8 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from ***** 4.3.2.8 *****: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D55 time=3D562 ms



>
> greg k-h
>
