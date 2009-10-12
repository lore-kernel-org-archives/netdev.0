From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 23:21:12 -0700
Message-ID: <4AD2CAD8.2040903@kadzban.is-a-geek.net>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <20091010124731.GA17218@mock.linuxdev.us.dell.com> <20091010162518.GA30354@kroah.com> <4AD0C598.4070403@kadzban.is-a-geek.net> <20091010211352.GC1927@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enigA5E81E5B00DFF3FE3466ABEA"
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:46982 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbZJLGV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 02:21:58 -0400
In-Reply-To: <20091010211352.GC1927@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA5E81E5B00DFF3FE3466ABEA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Greg KH wrote:
> On Sat, Oct 10, 2009 at 10:34:16AM -0700, Bryan Kadzban wrote:
>> Greg KH wrote:
>>> On Sat, Oct 10, 2009 at 07:47:32AM -0500, Matt Domsch wrote:
>>>> On Fri, Oct 09, 2009 at 10:23:08PM -0700, Greg KH wrote:
>>>>> On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
>>>>>> The fundamental roadblock to this is that enumeration !=3D=20
>>>>>> naming, except that it is for network devices, and we keep=20
>>>>>> changing the enumeration order.
>>>>> No, the hardware changes the enumeration order, it places
>>>>> _no_ guarantees on what order stuff will be found in.  So
>>>>> this is not the kernel changing, just to be clear.
>>>> Over time the kernel has changed its enumeration mechanisms,
>>>> and introduced parallelism into the process (which is a good
>>>> thing), which, from a user perspective, makes names
>>>> nondeterministic.  Yes, fixing this up by hard-coding MAC
>>>> addresses after install has been the traditional mechanism to
>>>> address this.  I think there's a better way.
>>> Ok, but that way can be done in userspace, without the need for
>>> this char device, right?
>> For the record -- when I tried to send a patch that did exactly
>> this (provided an option to use by-path persistence for network
>> drivers), it was rejected because "that doesn't work for USB".
>>=20
>> True, it doesn't.  But by-mac (what we have today) doesn't work for
>> replacing motherboards in a random home system (that can't override
>> the MAC address in the BIOS), either.
>=20
> If you replace a motherboard, you honestly expect no configuration to
> be needed to be changed?  If so, then don't use the MAC naming scheme
> for your systems.

What else is there?  biosdevname doesn't work with this BIOS.  It looks
like at least path_id has been updated to work with NICs now, so that
might work, with a bit of custom rule hacking.

Or at least, it won't work any more poorly than for disks, which seem to
work pretty well...  :-)

>>> But this code is not a requirement to "solve" the fact that
>>> network devices can show up in different order, that problem can
>>> be solved as long as the user picks a single way to name the
>>> devices, using tools that are already present today in distros.
>> This code is not a requirement, no.  But -- as you say -- it does=20
>> provide a halfway-decent way to assign multiple names to a NIC.
>> And that provides admins the choice to use a couple different
>> persistence schemes, depending on how they expect their hardware to
>> work.
>=20
> But the names need to then be resolved back to a "real" kernel name
> in order to do anything with that network connection, as the char
> devices are not real ones.  So that adds an additional layer of
> complexity on all of the system configuration tools.

Yes, that is true -- and no, this change isn't perfect.  But it lets me
have multiple "names" per interface, and have "names" that are longer
than IFNAMSIZ, though, which is why I like it.

(Now, if open() would return effectively a netlink socket bound to that
ifindex already, such that the program didn't need to fill in the
various ifindex fields for e.g. rtnetlink... but it's probably really
hard to do that, so this isn't a serious suggestion.)


--------------enigA5E81E5B00DFF3FE3466ABEA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrSyt4ACgkQYasYN+YI5W5a4wCff2TyI2MG1zh8QpMmcW9x4Uag
f+wAnRuY7z12h17EIVlMKIkHNNP4es2V
=idr4
-----END PGP SIGNATURE-----

--------------enigA5E81E5B00DFF3FE3466ABEA--
