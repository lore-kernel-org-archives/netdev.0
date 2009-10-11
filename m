From: Rob Townley <rob.townley@gmail.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 16:10:03 -0500
Message-ID: <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009210909.GA9836@auslistsprd01.us.dell.com>
	 <20091009194401.036da080@nehalam>
	 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	 <20091010052308.GA12458@kroah.com>
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
Received: from mail-vw0-f203.google.com ([209.85.212.203]:53988 "EHLO
	mail-vw0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbZJKVKj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 17:10:39 -0400
In-Reply-To: <20091010052308.GA12458@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2009 at 12:23 AM, Greg KH <greg@kroah.com> wrote:
> On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
>> The fundamental roadblock to this is that enumeration !=3D naming,
>> except that it is for network devices, and we keep changing the
>> enumeration order.
>
> No, the hardware changes the enumeration order, it places _no_
> guarantees on what order stuff will be found in. =A0So this is not th=
e
> kernel changing, just to be clear.
>
> Again, I have a machine here that likes to reorder PCI devices every =
4th
> or so boot times, and that's fine according to the PCI spec. =A0Yeah,=
 it's
> a crappy BIOS, but the manufacturer rightly pointed out that it is no=
t
> in violation of anything.
>
>> Today, port naming is completely nondeterministic. =A0If you have bu=
t
>> one NIC, there are few chances to get the name wrong (it'll be eth0)=
=2E
>> If you have >1 NIC, chances increase to get it wrong.
>
> That is why all distros name network devices based on the only
> deterministic thing they have today, the MAC address. =A0I still fail=
 to
> see why you do not like this solution, it is honestly the only way to
> properly name network devices in a sane manner.
>
> All distros also provide a way to easily rename the network devices, =
to
> place a specific name on a specific MAC address, so again, this shoul=
d
> all be solved already.
>
> No matter how badly your BIOS teams mess up the PCI enumeration order=
 :)
>
> thanks,
>
> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

So when an add-in PCI NIC has a lower MAC than the motherboard NICs,
the add-in cards will come before the motherboard NICs.   i don't like =
it.

But please whatever is done, make sure ping and tracert still works whe=
n
telling it to use a ethX source interface:

eth0 =3D 4.3.2.8, the default gateway is thru eth1.
ping -I eth0 208.67.222.222              FAILS
ping -I 4.3.2.8 208.67.222.222          WORKS
tracert -i eth0 -I 208.67.222.222        FAILS
tracert -s 4.3.2.8 -I 208.67.222.222   WORKS
tracert -i eth0 208.67.222.222           FAILS
tracert -s 4.3.2.8 208.67.222.222      WORKS
