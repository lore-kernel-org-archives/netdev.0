From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: RFC 3484 support
Date: Thu, 13 Nov 2003 15:17:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB41109.60902@redhat.com>
References: <Pine.LNX.4.44.0311131517110.3196-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0311131517110.3196-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Pekka Savola wrote:

> Currently getaddrinfo picks the destination address in a round-robin=20
> fashion.

That's what could be done but isn't since I see little value.  We
currently return IPv6 address, if there are any and if they are wanted,
first, then the IPv4 addresses.  The order in which multiple IPv6 and/or
IPv4 addresses are returned depends on the order the server returns it
and eventually on artificial round-robin selection.

But the rest of your argumentation I fully support.  I'm no expert at
this, but all these possible IPv6 address uses can lead to big problems
if the wrong address is chosen at any one time.  Support for destination
address selection is needed.  And I really would like to avoid to
implement something which will inevitably fall short of the real
solution at userlevel.


I could image something like this: a syscall with

  int destination_addr_sort (size_t n, struct addrinfo addr[], size_t
reorder[])


n and addr are input parameters.  reorder is an output parameter, a
pointer to an array describing the transformation.  I.e., it is not
necessary for the kernel to shuffle the data around.  It's not needed
for getaddrinfo anyway.  It means less data has to be transported.

An alternative would be to pass something other than struct addrinfo
elements down.  That struct contains data the kernel doesn't need.  I'd
be fine with that, too.


I'm open to any reasonable solution.  If we cannot come to an agreement
I'll have to try a user-level solution.  But this will be slow[=C2=B9], a=
nd
suck big time.


[=C2=B9] BTW, it will be slow, among other things, because there is no wa=
y to
cache and netlink-provided data at userlevel.  For every name lookup we
have to re-read the data.  This already happens today to implement
AI_ADDRCONFIG.  I've mentioned to DaveM sometime back that I would love
to get a netlink command which allows me to query a timestamp for the
last interface configuration change.  Then I could perform this one
quick test and read the other data only if the timestamp changed.

- --=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/tBEJ2ijCOnn/RHQRAsbMAKCcQzX+GRBqA0O/nZzLfqw1Qko5ZACfe+P5
ODlgrjK3BcPqzjEWrSc6hIY=3D
=3D8/PO
-----END PGP SIGNATURE-----
