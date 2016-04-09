From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Sat, 9 Apr 2016 10:36:03 -0700
Message-ID: <CAKgT0UdR863RBgkMMuT=Db1D1YQUpXOFLh6Bz7nVQxoMuDzuzQ@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
	<20160407223237.11142.33072.stgit@ahduyck-xeon-server>
	<CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
	<CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
	<CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com>
	<CAKgT0UcehJaKhEQCATuyp48Q0gqofk7JjwsakNo1KgJd2YH-TA@mail.gmail.com>
	<CAEh+42j5_SKku5EWexLi+1Ch4Eu=SoijMGSCYyZAd39GeMq8GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35242 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbcDIRgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:36:05 -0400
Received: by mail-io0-f180.google.com with SMTP id g185so165515428ioa.2
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 10:36:04 -0700 (PDT)
In-Reply-To: <CAEh+42j5_SKku5EWexLi+1Ch4Eu=SoijMGSCYyZAd39GeMq8GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 8:52 AM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Apr 8, 2016 at 7:04 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Apr 8, 2016 at 2:40 PM, Jesse Gross <jesse@kernel.org> wrote:
>>> Maybe I missed it but I didn't see any checks for the DF bit being set
>>> when we transmit a packet with NETIF_F_TSO_MANGLEID. Even if I am
>>> comfortable mangling my IDs in the DF case, I don't think this would
>>> ever extend to non-DF packets. In the documentation you noted that it
>>> is the driver's responsibility to do this check but I couldn't find it
>>> in either ixgbe or igb. It would also be nice if the core stack could
>>> enforce it somehow as well rather than each driver.
>>
>> Yeah I had glossed over that in the igb and ixgbe patches.  A check is
>> only really needed for the incrementing to non-incrementing case and I
>> wasn't sure how common it was to have TCP with an IP header that
>> didn't set the DF bit.  In the case of the outer headers igb and ixgbe
>> will increment the IP ID always so we don't have to worry about if DF
>> is set of not there.  For the inner headers I had fudged it a bit and
>> didn't add the validation.  If needed I can see about adding that
>> shortly.
>
> TCP without the DF bit set is not the default but it is possible (it
> can be enabled by setting /proc/sys/net/ipv4/ip_no_pmtu_disc). I also
> did a quick check of some Internet services and at least some of them
> seem to return TCP without DF, so it's not too rare.

For next version I plan to include a check in netif_skb_features that
will clear NETIF_F_TSO_MANGLEID if the DF bit is not set.

- Alex
