From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Fri, 16 Jul 2004 19:06:41 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089990401.6114.2843.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
	 <1089983064.1060.1328.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2b92lDLt1Vcl4kBLFbER"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089983064.1060.1328.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-2b92lDLt1Vcl4kBLFbER
Content-Type: multipart/mixed; boundary="=-WV3BhdYCLmcV66kUoF4c"


--=-WV3BhdYCLmcV66kUoF4c
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-07-16 at 17:04, jamal wrote:

> > Has vrrp some authentification mechanism?
>=20
> They (at least used to) claim to be able to do so.

Hm... Quote from draft-ietf-vrrp-spec-v2-08.txt
5.3.6.1 Authentication Type 0
5.3.6.2 Authentication Type 1
5.3.6.3 Authentication Type 2

1. 8bit virtual host ID.
2. Plain password.
3. HMAC.

I think even 3 is not good.
They do strong signed digest, but it does not have any kind of counter
so i do not see replay attack prevention.

> > Can it be used over IPv6? (CARP also can't but it is _very_ easy to
> > add, I just don't have IPv6 network setup to test).
>=20
> Theres effort to have it do v6.
> http://www.ietf.org/internet-drafts/draft-ietf-vrrp-ipv6-spec-06.txt
> I agree its lame to have it as an after thought it seems

* VRRP for IPv6 does not currently include any type of authentication. *


> > > Can you explain a little more what you mean by "attching" to
> > > master/slave?
> >=20
> > Consider using some abstraction layer which makes some decisions based
> > on knowledge of current HA state.
>=20
> sure; make it an API/callback/event to/from the carp daemon to other
> applications.
>=20
> > It looks like we do not understand each other :)
> > Here is the explanation of the ct_sync:
> > http://cvs.netfilter.org/netfilter-ha/README?rev=3D1.2&content-type=3Dt=
ext/vnd.viewcvs-markup
> >=20
> > Harald Welte will have a talk about ct_sync at OLS.
>=20
>=20
> Ok, good. Maybe if you too come to OLS we can settle this ;->

:) Unfortunately no...

> Looking at what HArald has, the infrastructure seems to be the correct
> flavor. Seems something gets sent to user space via netlink and gets
> delivered via keepalived.
> I think the CARP loadbalancing feature is an improvement over what is
> being suggested by Harald.
> I have to say as well i am shocked that state is just being transfered
> blindly - but i will deal with Harald when he shows up in Ottawa ;->

Harald, sorry :)

> > > What do you mean realtime traffic?
> > > Is it something that can be achieved by qos prioritization?
> >=20
> > Yes it can. But who will control prioritization mechanism?
> > Maybe userspace.
> > But with such approach we need to create each time we need kernel acces=
s
> > a kernel agent with it's own kernel<->user protocol, it's own connect
> > to master/slave arbiter...
> > With CARP just create one function in kernelspace and register it in
> > CARP using provided mechanism.
>=20
> bah.
> Ok, now you are forcing me to draw diagrams.
>
> I attached to avouid it being mangled.

I will draw one too.

> > > In the end CISCO is going to be the loser in this of because=20
> > > something like CARP will take off and it cant talk to them. At the
> > > moment though they do have the market so interoping with them is
> > > valuable.
> >=20
> > It is just marketing...
> > The better software the more market it can eat. Theoretically...
>=20
> I am afraid even if that sounds logical it doesnt work like that.
> Too many stupid people. If it worked like that MS would be dead and
> buried a few years ago.

For those who cares they are already done.

> > I have great confidence that Theo de Raadt will not include non
> > patent-free code in OpenBSD.
>=20
> I hope he is a lawyer or has some good lawyer advising him;->

He is an OpenBSD creator, so he is just a bit more paranoidal than
others :)

> cheers,
> jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-WV3BhdYCLmcV66kUoF4c
Content-Disposition: attachment; filename=carp_diagram.1
Content-Transfer-Encoding: base64
Content-Type: text/plain; name=carp_diagram.1; charset=koi8-r

Tm8sIHlvdXIgZGlhZ3JhbSBzaG91bGQgbG9va3MgbGlrZSB0aGlzOg0KDQogICAgICAgICBVc2Vy
IHNwYWNlDQogICAgICAgICAgICAgICAgICAgICstLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKw0KCQkgICAgfCAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8DQogICAgICAgICAgICAg
ICAgICAgIHwgICstLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKyAgICAgICAg
ICAgICAgICAgfA0KCQkgICAgfCAgfCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICB8ICAgICAgICAgICAgICAgICB8DQorLS0tLS0tLSsgICAgICAgICArLS0tLS0tLSsgICAgICAg
ICArLS0tLS0tLS0tKyAgICAgICAgICstLS0tLS0tKyAgICAgICAgICArLS0tLS0tLSsgICAgICAg
ICAgDQp8IEFwcCNYIHwgPC0tLS0tPiB8IENBUlBkIHwgPC0tLS0tPiB8IGN0c3luY2QgfCA8LS0t
LS0+IHwgQXBwI1ggfCA8LS0tLS0+ICB8IEFwcCNYIHwgPC0tLS0tPiANCistLS0rLS0tKyAgICAg
ICAgICstLS0rLS0tKyAgICAgICAgICstLS0rLS0tLS0rICAgICAgICAgKy0tLSstLS0rICAgICAg
ICAgICstLS0rLS0tKyAgICAgICAgIA0KICAgICAgICAgICAgICAgICAgICAgIHwgICAgICAgICAg
ICAgICAgIHwgICAgICAgICAgICAgICAgICAgfCAgICAgICAgICAgICAgICAgIHwgICAgICAgICAg
ICAgIA0KICAgICAgICAgICAgICAgICAgICAgIHwgICAgICAgICAgICAgICAgIHwgICAgICAgICAg
ICAgICAgICAgfCAgICAgICAgICAgICAgICAgIHwgICAgICAgICAgICAgIA0KICAgLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogICAgICAgICAgIEtlcm5lbA0KICAgICAgICBuZXR3
b3JrIEkvTyBldGMNCg0KT3Igb25seSBoYXZlIG9uZSBCVVMoYW5kIGl0IGlzIGFjdHVhbGx5IGlt
cGxlbWVudGVkIHVzaW5nIG5ldGxpbmspLg0KDQpZb3UgbmVlZCB0byBjb25uZWN0IGVhY2ggYXBw
bGljYXRpb24gZGFlbW9uIHRvIGNhcnBkLCBldmVuIHVzaW5nIGJyb2FkY2FzdCBuZXRsaW5rLg0K
QW5kIGZvciBhbnkgaW4ta2VybmVsIGFjY2VzcyB5b3Ugd2lsbCBuZWVkIHRvIGNyZWF0ZSBuZXcg
QXBwIGFuZCBuZXcga2VybmVsIHBhcnQuDQoNCklmIHdlIHdpbGwgZXh0cmFwb2xhdGUgaXQgd2Ug
Y2FuIGNyZWF0ZSBmb2xsb3dpbmc6DQp1c2Vyc3BhY2UgY2FycCBkZXRlcm1pbmVzIHRoYXQgaXQg
aXMgYSBtYXN0ZXIsIGl0IHdpbGwgc3VzcGVuZCBhbGwga2VybmVsIG1lbW9yeSBvciBkdW1wIC9w
cm9jL2ttZW0NCmFuZCBiZWdpbnMgdG8gYWR2ZXJ0aXNlIGl0LiBSZW1vdGUgbm9kZSByZWNlaXZl
cyBpdCBhbmQgaGFzIHByZXR0eSB0aGUgc2FtZSBmaXJld2FsbCBzZXR0aW5ncywgDQpmbG93IGNv
bnRyb2xzIGFuZCBhbnkgaW4ta2VybmVsIHN0YXRlLg0KTm8gbWF0dGVyIHRoYXQgaXQgdGFrZXMg
YSBsb25nIHRpbWUuDQoNCg0KSXQgbWFrZSBzZW5jZSBpZiBBcHAjWCBuZWVkcyB1c2Vyc3BhY2Ug
YWNjZXNzIG9ubHkuDQpCdXQgaGVyZSBpcyBvdGhlciBkaWFncmFtOg0KDQogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgdXNlcnNwYWNlDQogICAgICAgICAgICAgICAgIHwN
Ci0tLS0tLS0tLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiAgICAg
ICAgICAgICAgICBDQVJQICAgICAgICAgICAgICAgICAga2VybmVsc3BhY2UNCiAgICAgICAgICAg
ICAgICAgfA0KICAgICAgICAgICAgICAgICB8DQorLS0tLS0tLS0tLSstLS0tLSstLS0tLSstLS0t
LS0tLS0rLS0tLS0tLQ0KfCAgICAgICAgICB8ICAgICAgICAgICB8ICAgICAgICAgfA0KY3Rfc3lu
YyAgaVNDU0kgICAgICAgZTEwMDAgICAgICBDUFUNCg0KDQpNeSBtYWluIGlkZWEgZm9yIGluLWtl
cm5lbCBDQVJQIHdhcyB0byBpbXBsZW1lbnQgaW52aXNpYmxlIEhBIG1lY2hhbmlzbSBzdWl0YWJs
ZSBmb3IgaW4ta2VybmVsIHVzZS4NCllvdSBkbyBub3QgbmVlZCB0byBjcmVhdGUgbmV0bGluayBw
cm90b2NvbCBwYXJzZXIsIHlvdSBkbyBub3QgbmVlZCB0byBjcmVhdGUgZXh0cmEgdXNlcnNwYWNl
IG92ZXJoZWFkLA0KeW91IGRvIG5vdCBuZWVkIHRvIGNyZWF0ZSBzdWl0YWJsZSBmb3IgdXNlcnNw
YWNlIGNvbnRyb2wgaG9va3MgaW4ga2VybmVsIGluZnJhc3RydWN0dXJlLg0KSnVzdCByZWdpc3Rl
ciBjYWxsYmFjay4NCkJ1dCBldmVuIHdpdGggc3VjaCBzaW1wbGUgYXBwcm9hY2ggeW91IGhhdmUg
b3Bwb3J0dW5pdHkgdG8gY29sbGFib3JhdGUgd2l0aCB1c2Vyc3BhY2UuIElmIHlvdSBuZWVkLg0K
DQpXaHkgY3JlYXRpbmcgYWxsIHVzZXJzcGFjZSBjcnVmdCBpZi93aGVuIHlvdSBuZWVkIG9ubHkg
a2VybmVsIG9uZT8NCg0KDQpSZXN1bWU6IA0KV2l0aCB5b3VyIGFwcHJvYWNoIGFueSBkYXRhIGZs
b3cgTVVTVCBnbyB0aHJvdWdoIHVzZXJzcGFjZSBhcmJpdGVycyB3aXRoIGFsbCBvdmVyaGVhZCBh
bmQgY29tcGxleGl0eS4NCldpdGggbXkgYXBwcm9hY2ggYW55IGRhdGEgZmxvdyBfTUFZXyBnbyB0
aHJvdWdoIHVzZXJzcGFjZSBhcmJpdGVycywgYnV0IGlmIHlvdSBkb19uZWVkL29ubHlfaGFzIA0K
aW4ta2VybmVsIGFjY2VzcyB0aGFuIHVzaW5nIGluLWtlcm5lbCBDQVJQIGlzIHRoZSBvbmx5IHNv
bHV0aW9uLg0K

--=-WV3BhdYCLmcV66kUoF4c--

--=-2b92lDLt1Vcl4kBLFbER
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9+8BIKTPhE+8wY0RAnt+AJ91oyr4of3i8A6cI0i3v/V2WSfgrACfS6ND
plBwcsbRmlvqcW19HhzRitc=
=NPUK
-----END PGP SIGNATURE-----

--=-2b92lDLt1Vcl4kBLFbER--
