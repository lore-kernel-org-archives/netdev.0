From: "Subash Abhinov Kasiviswanathan" <subashab@codeaurora.org>
Subject: RE: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 1 Apr 2016 15:13:42 -0600
Message-ID: <003901d18c5b$5f6f5760$1e4e0620$@codeaurora.org>
References: <20160401175741.13882.24175.stgit@localhost.localdomain>	<20160401180531.13882.44793.stgit@localhost.localdomain>	<1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>	<20160401.152405.915323132719949585.davem@davemloft.net> <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"'Alex Duyck'" <aduyck@mirantis.com>,
	"'Herbert Xu'" <herbert@gondor.apana.org.au>,
	"'Tom Herbert'" <tom@herbertland.com>,
	"'Jesse Gross'" <jesse@kernel.org>,
	"'Eric Dumazet'" <edumazet@google.com>,
	"'Netdev'" <netdev@vger.kernel.org>
To: "'Alexander Duyck'" <alexander.duyck@gmail.com>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47666 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbcDAVNp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:13:45 -0400
In-Reply-To: <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|  For transmit we can leave the IP ID code as is.  For receive we should not be
|  snooping into the IP ID for any frames that have the DF bit set as devices
|  that have adopted RFC 6864 on their transmit path will end up causing issues.

Currently, GRO does not coalesce TCP packets originating from nodes which do IPv6 to IPv4 translation.
These packets have DF set to 1 and IP ID set 0 according to https://tools.ietf.org/html/rfc6145#page-17 

With this patch, we should be able to see coalescing happen for those cases as well.
