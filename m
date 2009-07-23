From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: md5 on listening sockets
Date: Thu, 23 Jul 2009 19:16:13 +0000
Message-ID: <1248376573.7971.19.camel@Maple>
References: <aa9682190907230738y23636cc5yd8b4e7a854f7b59c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Martin =?ISO-8859-1?Q?Djern=E6s?= <mdjernaes@pulz8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:45511 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbZGWTQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 15:16:22 -0400
Received: by ewy26 with SMTP id 26so1251433ewy.37
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 12:16:21 -0700 (PDT)
In-Reply-To: <aa9682190907230738y23636cc5yd8b4e7a854f7b59c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-23 at 16:38 +0200, Martin Djern=C3=A6s wrote:
> I've been looking at using the md5 keys on a listening socket as one
> means of restricting access to the socket.=20

MD5 authentication is typically used for BGP sessions.  It is not a
particularly strong authentication mechanism, as discussed in RFC 4278,
and there are several better options available as long as you don't hav=
e
to be compatible with BGP peers.

> When I specify an md5 key
> (with or without a peer ip address in the option) any tcp connect fro=
m
> another IP address will be accepted by this connection if the source
> IP is not found in the "md5sig->keys4" array.

The current behavior is consistent with the way MD5 authentication work=
s
on OpenBSD, and perhaps other BSDs.  This behavior is expected by open
source routing applications.

I believe the intent is that the BGP well-known port must be able to
accept connections from both authenticated and non-authenticated peers.
It is up to the application to filter connections based on the address
of the connecting peer.

I agree that this behavior would be unfortunate for a general-purpose
authentication mechanism, but that is not what TCP MD5 authentication
is.

--=20
John Dykstra
voice:           +1 651 484-1098            Yahoo IM:  jdykstra72

LinkedIn:        http://www.linkedin.com/in/JohnDykstra
Blog:            http://johndykstra.blogspot.com/=20

