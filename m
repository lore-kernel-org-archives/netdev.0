From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 11:38:14 -0400
Message-ID: <CACP96tSF=3ogg+Gv6GiOuUxF=kL_6FE0f_P1Efcg7-RKWs++yA@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
	<CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
	<CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
	<CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
	<CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com>
	<CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
	<CAKD1Yr2YtX9eGeFOeMb=s3_yqhhJgWEb+G0JH26UPRDPfZ5MgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35913 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaEMPiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 11:38:16 -0400
Received: by mail-la0-f48.google.com with SMTP id mc6so426312lab.7
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 08:38:15 -0700 (PDT)
In-Reply-To: <CAKD1Yr2YtX9eGeFOeMb=s3_yqhhJgWEb+G0JH26UPRDPfZ5MgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 11:28 AM, Lorenzo Colitti <lorenzo@google.com> wrote:

> You can't use macvlan if you're not using interfaces that don't have
> MAC addresses such as tun devices, 4G interfaces, and so on.

So to repeat, "what problem do you need to solve?" You indicated
that
" As described in the patch cover letter, one of the things I'm trying
  to do is have fwmarks select between multiple separate networks, which
  may be on multiple physical interfaces. I also want applications to be
  able to listen for connections from all networks using a single
  listening socket. I don't care about network isolation."

To do that, you just have to bind() the under-socket to the desired address,
no need for macvlans etc.

You'd only need macvlans to solve the rest of the problems in your
list, such as getting ping to work right, which involves network isolation,
aka vrf. (fwiw, the ping etc will JustWork with network-namespaces)


> IMO forcing an application to open one socket per namespace, and
> constantly be listening for any namespace changes as networks come and
> go, is an unreasonable burden when all the application wants to do is

your typical network app is going to have to open a netlink socket
and listen for state changes (intf events, address events etc) anyway.
And once you receive a packet on your wildcard socket, I suspect that
youi need to do some extra work anyway to figure out which
vrf/netns/sock-mark/whatever it came in on.

But note that I'm not averse to optimizing some of this- it just
seems odd to me that you have vrfs-with-namespaces,
not-quite-vrfs-with-sock-marks,
multiple-routing-tables-for-pbr-but-we-are-not-vrfs etc.

ymmv.

--Sowmini
