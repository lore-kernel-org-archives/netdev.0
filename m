From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 10:34:16 -0700
Message-ID: <4AD0C598.4070403@kadzban.is-a-geek.net>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <20091010124731.GA17218@mock.linuxdev.us.dell.com> <20091010162518.GA30354@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig20B3CE2EECD3BF971B4F8C54"
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091010162518.GA30354@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig20B3CE2EECD3BF971B4F8C54
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Greg KH wrote:
> On Sat, Oct 10, 2009 at 07:47:32AM -0500, Matt Domsch wrote:
>> On Fri, Oct 09, 2009 at 10:23:08PM -0700, Greg KH wrote:
>>> On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
>>>> The fundamental roadblock to this is that enumeration !=3D
>>>> naming, except that it is for network devices, and we keep
>>>> changing the enumeration order.
>>> No, the hardware changes the enumeration order, it places _no_=20
>>> guarantees on what order stuff will be found in.  So this is not
>>> the kernel changing, just to be clear.
>> Over time the kernel has changed its enumeration mechanisms, and=20
>> introduced parallelism into the process (which is a good thing),=20
>> which, from a user perspective, makes names nondeterministic.  Yes,
>> fixing this up by hard-coding MAC addresses after install has been
>> the traditional mechanism to address this.  I think there's a
>> better way.
>=20
> Ok, but that way can be done in userspace, without the need for this=20
> char device, right?

For the record -- when I tried to send a patch that did exactly this
(provided an option to use by-path persistence for network drivers), it
was rejected because "that doesn't work for USB".

True, it doesn't.  But by-mac (what we have today) doesn't work for
replacing motherboards in a random home system (that can't override the
MAC address in the BIOS), either.

So why not provide both alternatives?

As you say below, it's up to the network devs whether this should be
allowed...

>> biosdevname can be used in udev rules to create multiple names for
>> a given device.  Rules such as:
>=20
> Yes, if you want multiple ways to name a network device, then you
> need the char nodes.  But without that, you can just pick "always use
> the biosdevname" type option from your distro setup screen and go
> with that. Then you have everything always working properly from the
> very beginning.

*If* biosdevname works on your system.  It doesn't on mine: this SMBIOS
extension doesn't exist.  :-)

> So you really want this for multiple ways to name the same network=20
> device.  That's a choice the network developers are going to have to=20
> make, as to if that is going to be a legal thing to have happen or
> not.

Yes.  So do I, actually (for what little that's worth)...

> But this code is not a requirement to "solve" the fact that network=20
> devices can show up in different order, that problem can be solved as
> long as the user picks a single way to name the devices, using tools
> that are already present today in distros.

This code is not a requirement, no.  But -- as you say -- it does
provide a halfway-decent way to assign multiple names to a NIC.  And
that provides admins the choice to use a couple different persistence
schemes, depending on how they expect their hardware to work.

(It *may* even be possible to use some kind of layer-2 traffic to see
what else is on the connected network and provide symlinks based on
that.  IPv6 autoconfig type of thing, maybe.  That's probably a *lot*
more complicated, and may be impossible, but would be even closer to
what I think Dell customers are asking for based on Matt's posts.)


--------------enig20B3CE2EECD3BF971B4F8C54
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrQxaAACgkQYasYN+YI5W4jHACcCYErkNQ2Yh2F/Ub/zPdYS52n
L/kAoK4j2h8Gn8s83z3uJivQxq9zlAwT
=Mg5r
-----END PGP SIGNATURE-----

--------------enig20B3CE2EECD3BF971B4F8C54--
