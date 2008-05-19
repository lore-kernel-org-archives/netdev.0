From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Mon, 19 May 2008 14:58:31 -0400
Message-ID: <4831CDD7.2000507@garzik.org>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net> <4830E24C.3020405@garzik.org> <9B610463-CF23-4D17-96D2-5AA2316B15E4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58193 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbYESS6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 14:58:33 -0400
In-Reply-To: <9B610463-CF23-4D17-96D2-5AA2316B15E4@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> On May 18, 2008, at 10:13 PM, Jeff Garzik wrote:
>> Chuck Lever wrote:
>>> Hi-
>>> I'm interested in some review of the following four patches which a=
dd to
>>> the kernel's NFS client the ability to parse IPv6 addresses in=20
>>> presentation
>>> format.
>>> Namely, it adds the following:
>>> 1.  If the user passes in an IPv6 address as the server name, the c=
olons
>>>    in the address will confuse the logic that splits the device nam=
e
>>>    into a server hostname and an export path.   We'll use square=20
>>> brackets
>>>    around IPv6 server addresses to "escape" the colons, as does Sol=
aris.
>>> 2.  If the user passes in a link-local IPv6 address as the server n=
ame,
>>>    an interface index is also necessary.  We'll use the "%id" suffi=
x on
>>>    the address to pass in the index, and plant that in the sockaddr=
's
>>>    sin6_scope_id field.
>>> In addition to the following patches in email, a git repo with thes=
e
>>> same patches already applied can be found here:
>>>     linux-nfs.org:exports/cel-2.6.git
>>> The basic questions:
>>> Are these reasonable conventions to follow?  Is the parsing logic=20
>>> adequate?
>>> Is there anything I'm forgetting?
>>
>> I would take a look at the underlying components of glibc's=20
>> getnameinfo(), which must parse IPv6 addresses according to POSIX=20
>> specifications, IIRC.
>>
>> Comments:
>>
>> 1) bracket escaping seems reasonably common.  browsers and other app=
s=20
>> sometimes use that convention too.
>>
>> 2) an interface name rather than index should be used
>=20
> A few follow-up questions (for anyone, not just Jeff):
>=20
> Should the kernel ignore any incoming scope/interface identifier unle=
ss=20
> it verifies the address is link-local?
>=20
> Do we really have to worry about the character set of incoming C stri=
ngs?
>=20
>        NI_IDN If  this  flag is used, then the name found in the
>               lookup process is converted from IDN format to the
>               locale=92s encoding  if  necessary.  ASCII-only names
>               are not affected by the conversion, which makes this
>               flag usable in existing programs and environments.
>=20
>        NI_IDN_ALLOW_UNASSIGNED, NI_IDN_USE_STD3_ASCII_RULES
>               Setting these flags will enable the IDNA_ALLOW_UNASSIGN=
ED
>               (allow unassigned  Unicode  code  points)  and
>               IDNA_USE_STD3_ASCII_RULES (check output to make sure
>               it is a  STD3  conforming  host  name) flags
>               respectively to be used in the IDNA handling.
>=20
> I would hope that this level of detail would be handled by utility=20
> functions provided in net/core -- in6_pton, for example.

I don't think you need to worry about that?

getnameinfo() parses an IPv6 numeric address, and returns the name=20
associated with it.  You only need the first half, the IPv6 address=20
string parsing, correct?

If so, you don't need to care about the character sets of the returning=
=20
lookup data.

I presume you are not adding an in-kernel DNS resolver, so this is all=20
userspace details?

	Jeff




