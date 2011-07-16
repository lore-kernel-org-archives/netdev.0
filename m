From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: recommended way to support duplicate IP addresses on different VLANs?
Date: Fri, 15 Jul 2011 17:24:54 -0700
Message-ID: <m1tyankr6x.fsf@fess.ebiederm.org>
References: <4E1B0F86.2040508@mail.usask.ca>
	<201107111804.26500.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <cbf123@mail.usask.ca>, netdev@vger.kernel.org
To: =?utf-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54528 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab1GPAZA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 20:25:00 -0400
In-Reply-To: <201107111804.26500.remi@remlab.net> (=?utf-8?Q?=22R=C3=A9mi?=
 Denis-Courmont"'s
	message of "Mon, 11 Jul 2011 18:04:25 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"R=C3=A9mi Denis-Courmont" <remi@remlab.net> writes:

> Le lundi 11 juillet 2011 17:58:14 Chris Friesen, vous avez =C3=A9crit=
 :
>> Hi all,
>>=20
>> We've got a server that sits on multiple VLANs.  Each VLAN is segreg=
ated
>> and doesn't know about the others.  The IP address ranges in each of=
 the
>> VLANs may overlap, and the server may be assigned the same IP addres=
s in
>> multiple VLANs.
>>=20
>> We've got a messy solution now involving unique internal addresses a=
nd
>> NATing between those and the duplicate external addresses, but I'm
>> wondering if there is a cleaner way to handle this.
>>=20
>> It seems like network namespaces would work, but it would require
>> multiple instances of our software which is a dealbreaker.
>>=20
>> Is there any other way to deal with this scenario?
>
> Namespace file descriptors if/when they get accepted.

=46or reference.

The namespace file descriptor code is in 3.0.  setns is present in the
latest glibc.  And the iproute support is just finishing up.

What doesn't exist at the moment is a handy socketat library
function to make it a userspace program that uses multiple network
namespaces trivial.  But that is only a few lines of code.

It sounds like you don't need the full generality of network
namespaces but if you do the functionality is present.

Eric
