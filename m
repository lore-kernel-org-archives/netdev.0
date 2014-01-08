From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Wed, 8 Jan 2014 08:29:45 -0800
Message-ID: <CA+mtBx8hnTtXD9ePSzcu2RGRghbmd4Wyu10HPmUu=gXcw5FaLA@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx_UDWVP2KEB04d-kS4fB1DyYX4m-sC8YOZDy-Wty3cmtA@mail.gmail.com>
	<CAJZOPZKecwB9S_+goH2SvcXS+03rYk=73eVNBUoEMz=M5484RA@mail.gmail.com>
	<CA+mtBx-HRi4ttijScF8DKtdooeOyjzPXwq7T69vNaPSodZh1dQ@mail.gmail.com>
	<52CD7899.5090707@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:42020 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbaAHQ3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 11:29:48 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so2223468ieb.4
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 08:29:46 -0800 (PST)
In-Reply-To: <52CD7899.5090707@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Tom,
>
> OK, so I understand that you want the infrastructure to allow for direct udp
> encapsulation in the sense that there is no specific encapsulation header
> following the udp header.
>
> Take for example encapsulating TCP over UDP port X, the layer/driver that
> wants to enable gro for such traffic will register a udp gro handler for
> port X and in their gro receive/complete
> callbacks would just assume that following the UDP header there's TCP header
> and they will then issue a lookup in the inet gro handlers array to get the
> TCP gro handler, problem solved, agree?
>
Yes, that could work, but except for specifying a different protocol
number, the code to do direct encapsulation with GRO would be
identical for TCP/UDP, GRE/UDP, IPIP/UDP, ... we should be able to
avoid redundancy.  Let's get the basic UDP GRO support in, and then I
think adding support for direct encapsulation can be done without API
change in your proposed scheme.

> Or.
