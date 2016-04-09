From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Sat, 9 Apr 2016 11:32:09 -0700
Message-ID: <CAKgT0Uf8HNCY8=gg9oEA0jUstAxXFV2Yy9caimWCry=7Sirrpw@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
	<20160407223237.11142.33072.stgit@ahduyck-xeon-server>
	<CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
	<CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
	<CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com>
	<CAKgT0UcehJaKhEQCATuyp48Q0gqofk7JjwsakNo1KgJd2YH-TA@mail.gmail.com>
	<CAEh+42j5_SKku5EWexLi+1Ch4Eu=SoijMGSCYyZAd39GeMq8GQ@mail.gmail.com>
	<CAKgT0UdR863RBgkMMuT=Db1D1YQUpXOFLh6Bz7nVQxoMuDzuzQ@mail.gmail.com>
	<1460224948.6473.511.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36218 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759023AbcDIScL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 14:32:11 -0400
Received: by mail-io0-f169.google.com with SMTP id q128so166200626iof.3
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 11:32:10 -0700 (PDT)
In-Reply-To: <1460224948.6473.511.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 11:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-04-09 at 10:36 -0700, Alexander Duyck wrote:
>
>> For next version I plan to include a check in netif_skb_features that
>> will clear NETIF_F_TSO_MANGLEID if the DF bit is not set.
>
> So it looks like we slowly but surely make the whole stack damn slow, to
> support some extra features.
>
> How many instructions are needed nowadays for netif_skb_features()
> alone ?
>
> More than 120 if I am not mistaken, if we count fast path in
> skb_network_protocol()
>
> Note: I have a patch to remove the gso_min_segs thing, currently unused.
>
> 2 instructions saved ! Woo-hoo !

I was planning to drop the checks for TSO_MANGLEID and GSO_PARTIAL in
a if statment based on skb_is_gso() since I had both GSO_PARTIAL to
check for as well.

- Alex
