From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 22:25:46 +0200
Message-ID: <201009082225.47498.sven.eckelmann@gmx.de>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009082058.15533.sven.eckelmann@gmx.de>
	<AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8620099.O4X0t5WkED";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart8620099.O4X0t5WkED
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Jesse Gross wrote:
[...]
> >  * Does it propagate the information about the incoming device to the
> >   userspace in case of the not routed packets (everything which should
>=20
> I think the last part of your question got cut off.

Or I simple was distracted and didn't finish the sentence. :)

>  However, packets
> do include metadata about the input device.  Userspace would then be
> able to use the normal Linux mechanisms to find out whatever it needs
> (or look at its own information).
>=20
> >  * Does it allow to append extra header information to the packet?
> >  * Does it allow fragmentation of packets (not real fragmentation, but
> > more single split)?
>=20
> I'm assuming that both of these questions are for tunneling.  Open
> vSwitch currently supports a few different L2 over L3 tunneling
> mechanisms and has a tunnel library that makes adding additional
> protocols easy.  It probably can't do exactly what you need right now,
> but it should be fairly easy to extend.

Hm, low overhead tunneling is one of the main parts, but if you think that =
it=20
is easy to extend then fine.

> >  * Does it allow to define outgoing patterns (on which attached interfa=
ce
> >   goes the thing out again) on packet number or incoming device (the re=
al
> >   hardware device it was coming in)?
>=20
> I'm not sure what you mean by "packet number".  It does allow you to
> specify the output interface based on a number of factors, include the
> input device.

It would mean that for example 5 packets goes over device 1, the next 5=20
packets goes over=20

> > * directly influence the traffic flow, i.e., ARQ for broadcasts,

Could you please comment on that one (taken from Mareks mail). Think about=
=20
that one:
 * A Broadcast packet must be send over wifi (adhoc)
 * This packet is probably dropped due to some interferences. So each node
   must transmit the broadcast more than one time to be (with a good chance
   successful). This is quite essential on l2 based adhoc wifi mesh networks
   (as tests showed - but please ask Marek for the actual test setups)


> There are three basic components that you need running for Open
> vSwitch: the main daemon, ovs-vswitchd, a lightweight configuration
> manager, ovsdb-server, and the kernel module, openvswitch_mod.  You
> would then be able to write a userspace process to communicate with
> the daemons to handle the above.  As I mentioned, the encapsulation
> would likely require some small additions to the kernel module for
> your particular type of tunneling (unless you are flexible and can use
> one of the existing mechanisms).  However, that would be significantly
> less kernel code than this patch.  As a starting point, I would
> recommend playing around with Open vSwitch as a normal switch to get a
> feeling for its operation (see the INSTALL.Linux file in the source
> distribution for instructions).

Without checking any facts: This sounds a little bit heavy - does it only=20
sound heavy and in reality is extreme slim? The problem is that it must run=
 on=20
those low end, "please don't run code on me, because I cannot crunch number=
s=20
and have no ram" machines like the FON2100 or WRT54GL.

thanks,
	Sven

--nextPart8620099.O4X0t5WkED
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMh/FKAAoJEF2HCgfBJntGTCAQAKjwKIbMv2u5QuO0HNKwD58o
TMVufVBTTd2Q+KT+XkZt+wpyf1TMkfJBM6bs+8yjJhDxih+Pn0iu+YaGsmX4SzSc
Y/PUpZlfipualFxGK2yGIH59arK5NJ44BFMLAhub65OpfkjvOLTg0RFhdj0AOXmS
LAt/1tB+YWY0a2aboAsxgHvTsnb+7lTig4zGPhK2WonTXRCtY339siaIbh8XP6fd
4yxCrO8aw4JzIEMvH50RJbOocpmxsYpOK7IDfVM08uTGnPfQEYv35nHGjafGO/Wk
9dOQhPwZZhlwv1EQaPbP5X+/lhBdi0GgfvZgGtTiJ2ODue2S5EaI73eeJm1fyNqW
mavSl8EUzvIkEsmHHq141/aoekTLqoKXV5RD0PfpSgVKBku0YzUcQ8i7ZtD7SmzM
fNZgkxJV0fjDRJCwoBmkFEXcF5x/eh+inqTJUxz3uaQO3c5lk1sO6yeo6IgsKxIM
9FYLSVoX3M1WfLzY4kLo1M9Fr0h9yo6AQNz7MlEE4BxrK2Rl/gCncEGFRFvfMbys
Nlp2qVIXaHO9z/WwqftUbMmqPpVrDbeZfhnrl+arjasa43tN+MJ75poF+a1Ka9xd
Jbp/21DAyASqjof8oB4PBY/m8Qzb9dy28xQMd7ASNFXZDHlI9zY74uuEyOd5tdrc
Lg+ZGn4Q9qA4AYiFEGrH
=pi7Z
-----END PGP SIGNATURE-----

--nextPart8620099.O4X0t5WkED--
