From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 08:53:18 -0400
Message-ID: <CACP96tQMEQcTPZaCT7mehis-H5Sw_-74F6fSvZxB7Lr3Hqo0kQ@mail.gmail.com>
References: <6zlhtsvnqp.fsf@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: =?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:53697 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbaEWMxT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 08:53:19 -0400
Received: by mail-la0-f45.google.com with SMTP id gl10so4179408lab.4
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 05:53:18 -0700 (PDT)
In-Reply-To: <6zlhtsvnqp.fsf@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 5:38 AM, Niels M=C3=B6ller <nisse@southpole.se>=
 wrote:


> 1. Simply assign all addresses to be used to the interface, fixing an=
y
>    remaining performance problems.
>
>    I've done a simple benchmark with a script assigning n addresses
>    using "ip address add", and this seems to have O(n^2) complexity.
>    E.g, assigning n=3D25500 addresses took 26 s, and doubling n, assi=
gning
>    51000 addresses, took 122 s, 4.6 times longer. Which isn't
>    necessarily a problems once all the addresses are assigned, but it
>    sounds a bit like there's a linear datastructure in there, not
>    intended for a large number of addresses.

I think the issue here is the netlink API: if you try to do the same th=
ing
with ifconfig (instead of /sbin/ip), you'll find things are much faster=
,
which seems paradoxical because ip(7) and netlink sockets are the
recommended config paths. When I ran into this, it turned out that the
difference was due to the implementation- the ioctl path was able to
use the ifr_name efficiently to identify the target interface, unlike
the netlink config path.

But to solve  your specific problem, since you are implementing
a packet generator, wouldnt it be easier to craft the packet and feed
it over RAW or PF_PACKET sockets, allowing you more flexibility
(if you need it down the road) to set all fields, not just the
IP source address? Might mean a bit more work in your user-space,
to compute checksums etc. though.

--Sowmini
