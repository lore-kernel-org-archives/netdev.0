From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Mon, 19 May 2008 13:55:27 -0400
Message-ID: <9B610463-CF23-4D17-96D2-5AA2316B15E4@oracle.com>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net> <4830E24C.3020405@garzik.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:25384 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbYESR4f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 13:56:35 -0400
In-Reply-To: <4830E24C.3020405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 18, 2008, at 10:13 PM, Jeff Garzik wrote:
> Chuck Lever wrote:
>> Hi-
>> I'm interested in some review of the following four patches which =20
>> add to
>> the kernel's NFS client the ability to parse IPv6 addresses in =20
>> presentation
>> format.
>> Namely, it adds the following:
>> 1.  If the user passes in an IPv6 address as the server name, the =20
>> colons
>>    in the address will confuse the logic that splits the device name
>>    into a server hostname and an export path.   We'll use square =20
>> brackets
>>    around IPv6 server addresses to "escape" the colons, as does =20
>> Solaris.
>> 2.  If the user passes in a link-local IPv6 address as the server =20
>> name,
>>    an interface index is also necessary.  We'll use the "%id" =20
>> suffix on
>>    the address to pass in the index, and plant that in the sockaddr'=
s
>>    sin6_scope_id field.
>> In addition to the following patches in email, a git repo with these
>> same patches already applied can be found here:
>> 	linux-nfs.org:exports/cel-2.6.git
>> The basic questions:
>> Are these reasonable conventions to follow?  Is the parsing logic =20
>> adequate?
>> Is there anything I'm forgetting?
>
> I would take a look at the underlying components of glibc's =20
> getnameinfo(), which must parse IPv6 addresses according to POSIX =20
> specifications, IIRC.
>
> Comments:
>
> 1) bracket escaping seems reasonably common.  browsers and other =20
> apps sometimes use that convention too.
>
> 2) an interface name rather than index should be used

A few follow-up questions (for anyone, not just Jeff):

Should the kernel ignore any incoming scope/interface identifier =20
unless it verifies the address is link-local?

Do we really have to worry about the character set of incoming C =20
strings?

        NI_IDN If  this  flag is used, then the name found in the
               lookup process is converted from IDN format to the
               locale=92s encoding  if  necessary.  ASCII-only names
               are not affected by the conversion, which makes this
               flag usable in existing programs and environments.

        NI_IDN_ALLOW_UNASSIGNED, NI_IDN_USE_STD3_ASCII_RULES
               Setting these flags will enable the IDNA_ALLOW_UNASSIGNE=
D
               (allow unassigned  Unicode  code  points)  and
               IDNA_USE_STD3_ASCII_RULES (check output to make sure
               it is a  STD3  conforming  host  name) flags
               respectively to be used in the IDNA handling.

I would hope that this level of detail would be handled by utility =20
functions provided in net/core -- in6_pton, for example.

(Actually net/core should provide appropriate helpers for mapping =20
device names to scope_ids, but I didn't find anything like this).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com