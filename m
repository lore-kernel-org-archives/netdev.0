From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 16:07:58 -0500
Message-ID: <20090107210758.GH3164@didacte.laptop.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:49137 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761202AbZAGVH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 16:07:59 -0500
Received: from didacte.laptop.org (dhcp-47-72.media.mit.edu [18.85.47.72])
	by mail.laptop.org (Postfix) with SMTP id 3391AB96F6
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2009 16:08:00 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20090107114703.GB28161@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy,

=46irst, thanks very much for all your comments and questions.

On Wed, Jan 07, 2009 at 02:47:03PM +0300, Evgeniy Polyakov wrote:

>> +  * it's available to unprivileged programs
>> +
>
>It isn't, since it can not set rlimit, and if it can, it still can dro=
p
>it.

Some sample code will probably clarify the use of my patch:=20

   http://dev.laptop.org/git?p=3Dusers/mstone/test-rlimit-network;a=3Db=
lob;f=3Ddisable_network.c;hb=3DHEAD

This C code describes a 'disable_network' exec-chain script which, when=
 run as
any user, irrevocably disables network access as described in my previo=
us
emails.=20

As you can see, processes start with full access to the 'network' resou=
rce and
may, at any time, irrevocably (modulo CAP_SYS_RESOURCE) limit their and=
 their
future children's access to this resource by lowering both their soft a=
nd hard
limits to 0.

>Your code does not cover sendpage() interface (aka splice() and
>sendfile())=20

Nor should it. Applications should continue to be able to send data on =
any
sockets where were already connected and should be able to accept new
connections on sockets which were already bound.

I have done some primitive testing to ensure that the patch implements =
this
functionality by means of the test utilities provided here:

  http://dev.laptop.org/git?p=3Dusers/mstone/test-rlimit-network;a=3Dtr=
ee

Can you confirm my results?

> and with your approach application will suddenly stops sending data e=
ven into
> old sockets, but will be able to receive it from anywhere. Is it inte=
ntional?

Why do you think this would happen?=20

(My test results, e.g. via
    http://dev.laptop.org/git?p=3Dusers/mstone/test-rlimit-network;a=3D=
blob;f=3Dpositive_localhost_tcp;hb=3DHEAD
  show otherwise.)

>The same goal can be achieved with 'owner' iptables match module btw.

As R=E9mi explained, the iptables 'owner' match module solves a differe=
nt
problem.

> but when parent sets the rlimit it is not updated in the childs.

This is by design. Limiting my shell's networking privileges in prepara=
tion for
running an untrusted command should not limit the privileges of program=
s that I
have previously started running from the same shell process.

Regards,

Michael

P.S. - R=E9mi, Scott: Thanks very much for your supportive comments.

